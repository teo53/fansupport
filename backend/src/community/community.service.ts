import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { CreatePostDto } from './dto/create-post.dto';
import { CreateCommentDto } from './dto/create-comment.dto';
import { PostVisibility } from '@prisma/client';

@Injectable()
export class CommunityService {
  constructor(private readonly prisma: PrismaService) {}

  async createPost(authorId: string, createPostDto: CreatePostDto) {
    const { title, content, images, visibility } = createPostDto;

    return this.prisma.post.create({
      data: {
        authorId,
        title,
        content,
        images: images || [],
        visibility: visibility || PostVisibility.PUBLIC,
      },
      include: {
        author: {
          select: { id: true, nickname: true, profileImage: true, role: true },
        },
      },
    });
  }

  async getPosts(options: {
    authorId?: string;
    visibility?: PostVisibility;
    page?: number;
    limit?: number;
  }) {
    const { authorId, visibility, page = 1, limit = 20 } = options;

    const where: any = { deletedAt: null };
    if (authorId) where.authorId = authorId;
    if (visibility) where.visibility = visibility;

    const [posts, total] = await Promise.all([
      this.prisma.post.findMany({
        where,
        include: {
          author: {
            select: { id: true, nickname: true, profileImage: true, role: true },
          },
          _count: { select: { comments: true, likes: true } },
        },
        orderBy: [{ isPinned: 'desc' }, { createdAt: 'desc' }],
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.post.count({ where }),
    ]);

    return {
      data: posts,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getPostById(postId: string, userId?: string) {
    const post = await this.prisma.post.findUnique({
      where: { id: postId },
      include: {
        author: {
          select: { id: true, nickname: true, profileImage: true, role: true },
        },
        comments: {
          where: { deletedAt: null, parentId: null },
          include: {
            author: {
              select: { id: true, nickname: true, profileImage: true },
            },
            replies: {
              where: { deletedAt: null },
              include: {
                author: {
                  select: { id: true, nickname: true, profileImage: true },
                },
              },
              orderBy: { createdAt: 'asc' },
            },
          },
          orderBy: { createdAt: 'desc' },
          take: 20,
        },
        _count: { select: { comments: true, likes: true } },
      },
    });

    if (!post || post.deletedAt) {
      throw new NotFoundException('Post not found');
    }

    let isLiked = false;
    if (userId) {
      const like = await this.prisma.like.findUnique({
        where: { postId_userId: { postId, userId } },
      });
      isLiked = !!like;
    }

    return { ...post, isLiked };
  }

  async updatePost(authorId: string, postId: string, updateData: Partial<CreatePostDto>) {
    const post = await this.prisma.post.findUnique({
      where: { id: postId },
    });

    if (!post) {
      throw new NotFoundException('Post not found');
    }

    if (post.authorId !== authorId) {
      throw new ForbiddenException('Not authorized to update this post');
    }

    return this.prisma.post.update({
      where: { id: postId },
      data: updateData,
      include: {
        author: {
          select: { id: true, nickname: true, profileImage: true },
        },
      },
    });
  }

  async deletePost(authorId: string, postId: string) {
    const post = await this.prisma.post.findUnique({
      where: { id: postId },
    });

    if (!post) {
      throw new NotFoundException('Post not found');
    }

    if (post.authorId !== authorId) {
      throw new ForbiddenException('Not authorized to delete this post');
    }

    return this.prisma.post.update({
      where: { id: postId },
      data: { deletedAt: new Date() },
    });
  }

  async likePost(userId: string, postId: string) {
    const post = await this.prisma.post.findUnique({
      where: { id: postId },
    });

    if (!post || post.deletedAt) {
      throw new NotFoundException('Post not found');
    }

    const existingLike = await this.prisma.like.findUnique({
      where: { postId_userId: { postId, userId } },
    });

    if (existingLike) {
      // Unlike
      await this.prisma.$transaction([
        this.prisma.like.delete({ where: { id: existingLike.id } }),
        this.prisma.post.update({
          where: { id: postId },
          data: { likeCount: { decrement: 1 } },
        }),
      ]);
      return { liked: false };
    } else {
      // Like
      await this.prisma.$transaction([
        this.prisma.like.create({ data: { postId, userId } }),
        this.prisma.post.update({
          where: { id: postId },
          data: { likeCount: { increment: 1 } },
        }),
      ]);
      return { liked: true };
    }
  }

  async createComment(authorId: string, postId: string, createCommentDto: CreateCommentDto) {
    const post = await this.prisma.post.findUnique({
      where: { id: postId },
    });

    if (!post || post.deletedAt) {
      throw new NotFoundException('Post not found');
    }

    const { content, parentId } = createCommentDto;

    if (parentId) {
      const parentComment = await this.prisma.comment.findUnique({
        where: { id: parentId },
      });
      if (!parentComment || parentComment.postId !== postId) {
        throw new NotFoundException('Parent comment not found');
      }
    }

    const comment = await this.prisma.comment.create({
      data: {
        postId,
        authorId,
        content,
        parentId,
      },
      include: {
        author: {
          select: { id: true, nickname: true, profileImage: true },
        },
      },
    });

    await this.prisma.post.update({
      where: { id: postId },
      data: { commentCount: { increment: 1 } },
    });

    return comment;
  }

  async deleteComment(authorId: string, commentId: string) {
    const comment = await this.prisma.comment.findUnique({
      where: { id: commentId },
    });

    if (!comment) {
      throw new NotFoundException('Comment not found');
    }

    if (comment.authorId !== authorId) {
      throw new ForbiddenException('Not authorized to delete this comment');
    }

    await this.prisma.$transaction([
      this.prisma.comment.update({
        where: { id: commentId },
        data: { deletedAt: new Date() },
      }),
      this.prisma.post.update({
        where: { id: comment.postId },
        data: { commentCount: { decrement: 1 } },
      }),
    ]);

    return { deleted: true };
  }

  async getFeed(userId: string, page: number = 1, limit: number = 20) {
    // Get posts from subscribed creators + public posts
    const subscriptions = await this.prisma.subscription.findMany({
      where: { subscriberId: userId, status: 'ACTIVE' },
      select: { creatorId: true, tierId: true },
    });

    const subscribedCreatorIds = subscriptions.map((s) => s.creatorId);

    const where = {
      deletedAt: null,
      OR: [
        { visibility: PostVisibility.PUBLIC },
        { authorId: { in: subscribedCreatorIds } },
        { authorId: userId },
      ],
    };

    const [posts, total] = await Promise.all([
      this.prisma.post.findMany({
        where,
        include: {
          author: {
            select: { id: true, nickname: true, profileImage: true, role: true },
          },
          _count: { select: { comments: true, likes: true } },
        },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.post.count({ where }),
    ]);

    return {
      data: posts,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }
}
