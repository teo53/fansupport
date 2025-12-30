import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { CreateIdolProfileDto } from './dto/create-idol-profile.dto';
import { UserRole } from '@prisma/client';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      include: {
        wallet: true,
        idolProfile: true,
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const { password, ...result } = user;
    return result;
  }

  async findByEmail(email: string) {
    return this.prisma.user.findUnique({
      where: { email },
    });
  }

  async updateProfile(userId: string, updateUserDto: UpdateUserDto) {
    const user = await this.prisma.user.update({
      where: { id: userId },
      data: updateUserDto,
    });

    const { password, ...result } = user;
    return result;
  }

  async createIdolProfile(userId: string, createIdolProfileDto: CreateIdolProfileDto) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { idolProfile: true },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (user.idolProfile) {
      throw new Error('Idol profile already exists');
    }

    const [updatedUser, idolProfile] = await this.prisma.$transaction([
      this.prisma.user.update({
        where: { id: userId },
        data: { role: UserRole.IDOL },
      }),
      this.prisma.idolProfile.create({
        data: {
          userId,
          ...createIdolProfileDto,
        },
      }),
    ]);

    return idolProfile;
  }

  async getIdolProfile(userId: string) {
    const profile = await this.prisma.idolProfile.findUnique({
      where: { userId },
      include: {
        user: {
          select: {
            id: true,
            email: true,
            nickname: true,
            profileImage: true,
          },
        },
        schedules: {
          where: { startTime: { gte: new Date() } },
          orderBy: { startTime: 'asc' },
          take: 10,
        },
        tiers: {
          where: { isActive: true },
          orderBy: { price: 'asc' },
        },
      },
    });

    if (!profile) {
      throw new NotFoundException('Idol profile not found');
    }

    return profile;
  }

  async getIdolsList(options: {
    category?: string;
    page?: number;
    limit?: number;
    sortBy?: 'ranking' | 'totalSupport' | 'supporterCount';
  }) {
    const { category, page = 1, limit = 20, sortBy = 'ranking' } = options;

    const where = category ? { category: category as any } : {};

    const [profiles, total] = await Promise.all([
      this.prisma.idolProfile.findMany({
        where,
        include: {
          user: {
            select: {
              id: true,
              nickname: true,
              profileImage: true,
            },
          },
        },
        orderBy: { [sortBy]: sortBy === 'ranking' ? 'asc' : 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.idolProfile.count({ where }),
    ]);

    return {
      data: profiles,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getRanking(limit: number = 100) {
    return this.prisma.idolProfile.findMany({
      where: { isVerified: true },
      include: {
        user: {
          select: {
            id: true,
            nickname: true,
            profileImage: true,
          },
        },
      },
      orderBy: { totalSupport: 'desc' },
      take: limit,
    });
  }
}
