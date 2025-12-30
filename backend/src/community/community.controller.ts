import { Controller, Post, Get, Put, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { CommunityService } from './community.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { CreatePostDto } from './dto/create-post.dto';
import { CreateCommentDto } from './dto/create-comment.dto';
import { PostVisibility } from '@prisma/client';

@ApiTags('community')
@Controller('community')
export class CommunityController {
  constructor(private readonly communityService: CommunityService) {}

  @Post('posts')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create a new post' })
  async createPost(
    @CurrentUser('id') userId: string,
    @Body() createPostDto: CreatePostDto,
  ) {
    return this.communityService.createPost(userId, createPostDto);
  }

  @Get('posts')
  @ApiOperation({ summary: 'Get all posts' })
  @ApiQuery({ name: 'authorId', required: false })
  @ApiQuery({ name: 'visibility', required: false, enum: PostVisibility })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  async getPosts(
    @Query('authorId') authorId?: string,
    @Query('visibility') visibility?: PostVisibility,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    return this.communityService.getPosts({ authorId, visibility, page, limit });
  }

  @Get('feed')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get personalized feed' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  async getFeed(
    @CurrentUser('id') userId: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    return this.communityService.getFeed(userId, page, limit);
  }

  @Get('posts/:id')
  @ApiOperation({ summary: 'Get post by ID' })
  async getPost(
    @Param('id') postId: string,
    @CurrentUser('id') userId?: string,
  ) {
    return this.communityService.getPostById(postId, userId);
  }

  @Put('posts/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update post' })
  async updatePost(
    @CurrentUser('id') userId: string,
    @Param('id') postId: string,
    @Body() updatePostDto: Partial<CreatePostDto>,
  ) {
    return this.communityService.updatePost(userId, postId, updatePostDto);
  }

  @Delete('posts/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete post' })
  async deletePost(
    @CurrentUser('id') userId: string,
    @Param('id') postId: string,
  ) {
    return this.communityService.deletePost(userId, postId);
  }

  @Post('posts/:id/like')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Like/unlike a post' })
  async likePost(
    @CurrentUser('id') userId: string,
    @Param('id') postId: string,
  ) {
    return this.communityService.likePost(userId, postId);
  }

  @Post('posts/:postId/comments')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Add comment to a post' })
  async createComment(
    @CurrentUser('id') userId: string,
    @Param('postId') postId: string,
    @Body() createCommentDto: CreateCommentDto,
  ) {
    return this.communityService.createComment(userId, postId, createCommentDto);
  }

  @Delete('comments/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete comment' })
  async deleteComment(
    @CurrentUser('id') userId: string,
    @Param('id') commentId: string,
  ) {
    return this.communityService.deleteComment(userId, commentId);
  }
}
