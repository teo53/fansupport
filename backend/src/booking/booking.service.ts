import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { CreateBookingDto } from './dto/create-booking.dto';
import { BookingStatus, Prisma } from '@prisma/client';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class BookingService {
  constructor(private readonly prisma: PrismaService) {}

  async createBooking(userId: string, createBookingDto: CreateBookingDto) {
    const { cafeName, cafeAddress, date, timeSlot, numberOfGuests, specialRequest } = createBookingDto;

    const bookingDate = new Date(date);
    if (bookingDate < new Date()) {
      throw new BadRequestException('Cannot book for past dates');
    }

    // Check for existing bookings at same time
    const existingBooking = await this.prisma.booking.findFirst({
      where: {
        userId,
        cafeName,
        date: bookingDate,
        timeSlot,
        status: { in: [BookingStatus.PENDING, BookingStatus.CONFIRMED] },
      },
    });

    if (existingBooking) {
      throw new BadRequestException('You already have a booking at this time');
    }

    const confirmationCode = this.generateConfirmationCode();

    const booking = await this.prisma.booking.create({
      data: {
        userId,
        cafeName,
        cafeAddress,
        date: bookingDate,
        timeSlot,
        numberOfGuests,
        specialRequest,
        confirmationCode,
      },
    });

    return booking;
  }

  async getMyBookings(userId: string, options: { status?: BookingStatus; page?: number; limit?: number }) {
    const { status, page = 1, limit = 20 } = options;

    const where: Prisma.BookingWhereInput = { userId };
    if (status) where.status = status;

    const [bookings, total] = await Promise.all([
      this.prisma.booking.findMany({
        where,
        orderBy: { date: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.booking.count({ where }),
    ]);

    return {
      data: bookings,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getBookingById(userId: string, bookingId: string) {
    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
    });

    if (!booking) {
      throw new NotFoundException('Booking not found');
    }

    if (booking.userId !== userId) {
      throw new ForbiddenException('Not authorized to view this booking');
    }

    return booking;
  }

  async cancelBooking(userId: string, bookingId: string) {
    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
    });

    if (!booking) {
      throw new NotFoundException('Booking not found');
    }

    if (booking.userId !== userId) {
      throw new ForbiddenException('Not authorized to cancel this booking');
    }

    if (booking.status === BookingStatus.CANCELLED) {
      throw new BadRequestException('Booking is already cancelled');
    }

    if (booking.status === BookingStatus.COMPLETED) {
      throw new BadRequestException('Cannot cancel a completed booking');
    }

    // Check if cancellation is at least 24 hours before
    const hoursUntilBooking = (new Date(booking.date).getTime() - Date.now()) / (1000 * 60 * 60);
    if (hoursUntilBooking < 24) {
      throw new BadRequestException('Cannot cancel booking less than 24 hours before');
    }

    return this.prisma.booking.update({
      where: { id: bookingId },
      data: { status: BookingStatus.CANCELLED },
    });
  }

  async getUpcomingBookings(userId: string) {
    return this.prisma.booking.findMany({
      where: {
        userId,
        date: { gte: new Date() },
        status: { in: [BookingStatus.PENDING, BookingStatus.CONFIRMED] },
      },
      orderBy: { date: 'asc' },
      take: 5,
    });
  }

  async getAvailableTimeSlots(cafeName: string, date: string) {
    const bookingDate = new Date(date);
    const allSlots = [
      '11:00', '11:30', '12:00', '12:30', '13:00', '13:30',
      '14:00', '14:30', '15:00', '15:30', '16:00', '16:30',
      '17:00', '17:30', '18:00', '18:30', '19:00', '19:30',
      '20:00', '20:30', '21:00',
    ];

    const bookedSlots = await this.prisma.booking.findMany({
      where: {
        cafeName,
        date: bookingDate,
        status: { in: [BookingStatus.PENDING, BookingStatus.CONFIRMED] },
      },
      select: { timeSlot: true },
    });

    const bookedSlotSet = new Set(bookedSlots.map((b) => b.timeSlot));

    return allSlots.map((slot) => ({
      time: slot,
      available: !bookedSlotSet.has(slot),
    }));
  }

  private generateConfirmationCode(): string {
    return `BK-${uuidv4().substring(0, 8).toUpperCase()}`;
  }
}
