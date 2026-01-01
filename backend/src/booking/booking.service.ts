import { Injectable, NotFoundException, BadRequestException, ForbiddenException, InternalServerErrorException, Logger } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { CreateBookingDto } from './dto/create-booking.dto';
import { BookingStatus } from '@prisma/client';
import { v4 as uuidv4 } from 'uuid';

const MAX_GUESTS_PER_BOOKING = 10;
const MIN_GUESTS_PER_BOOKING = 1;
const MAX_ADVANCE_BOOKING_DAYS = 90; // Maximum days in advance for booking

@Injectable()
export class BookingService {
  private readonly logger = new Logger(BookingService.name);

  constructor(private readonly prisma: PrismaService) {}

  async createBooking(userId: string, createBookingDto: CreateBookingDto) {
    const { cafeName, cafeAddress, date, timeSlot, numberOfGuests, specialRequest } = createBookingDto;

    // Validate user ID
    if (!userId) {
      throw new BadRequestException('User ID is required');
    }

    // Validate required fields
    if (!cafeName || cafeName.trim().length === 0) {
      throw new BadRequestException('Cafe name is required');
    }

    if (!cafeAddress || cafeAddress.trim().length === 0) {
      throw new BadRequestException('Cafe address is required');
    }

    if (!date) {
      throw new BadRequestException('Booking date is required');
    }

    if (!timeSlot || timeSlot.trim().length === 0) {
      throw new BadRequestException('Time slot is required');
    }

    // Validate time slot format (HH:MM)
    const timeSlotRegex = /^([01]?[0-9]|2[0-3]):[0-5][0-9]$/;
    if (!timeSlotRegex.test(timeSlot)) {
      throw new BadRequestException('Invalid time slot format. Use HH:MM format');
    }

    // Validate number of guests
    if (numberOfGuests < MIN_GUESTS_PER_BOOKING) {
      throw new BadRequestException(`Minimum ${MIN_GUESTS_PER_BOOKING} guest is required`);
    }

    if (numberOfGuests > MAX_GUESTS_PER_BOOKING) {
      throw new BadRequestException(`Maximum ${MAX_GUESTS_PER_BOOKING} guests allowed per booking`);
    }

    // Validate special request length
    if (specialRequest && specialRequest.length > 500) {
      throw new BadRequestException('Special request cannot exceed 500 characters');
    }

    // Parse and validate booking date
    let bookingDate: Date;
    try {
      bookingDate = new Date(date);
      if (isNaN(bookingDate.getTime())) {
        throw new Error('Invalid date');
      }
    } catch {
      throw new BadRequestException('Invalid date format. Please provide a valid date');
    }

    // Check if booking is for a past date
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    if (bookingDate < today) {
      throw new BadRequestException('Cannot book for past dates');
    }

    // Check if booking is too far in advance
    const maxBookingDate = new Date();
    maxBookingDate.setDate(maxBookingDate.getDate() + MAX_ADVANCE_BOOKING_DAYS);
    if (bookingDate > maxBookingDate) {
      throw new BadRequestException(`Cannot book more than ${MAX_ADVANCE_BOOKING_DAYS} days in advance`);
    }

    // Verify user exists
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('User not found');
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
      throw new BadRequestException('You already have a booking at this cafe for this time slot');
    }

    try {
      const confirmationCode = this.generateConfirmationCode();

      const booking = await this.prisma.booking.create({
        data: {
          userId,
          cafeName: cafeName.trim(),
          cafeAddress: cafeAddress.trim(),
          date: bookingDate,
          timeSlot,
          numberOfGuests,
          specialRequest: specialRequest?.trim(),
          confirmationCode,
        },
      });

      this.logger.log(`Booking created: user=${userId}, cafe=${cafeName}, date=${bookingDate.toISOString()}, slot=${timeSlot}`);
      return booking;
    } catch (error) {
      this.logger.error(`Booking creation failed: ${error.message}`, error.stack);
      throw new InternalServerErrorException('Failed to create booking. Please try again later.');
    }
  }

  async getMyBookings(userId: string, options: { status?: BookingStatus; page?: number; limit?: number }) {
    const { status, page = 1, limit = 20 } = options;

    const where: any = { userId };
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
    if (!cafeName || cafeName.trim().length === 0) {
      throw new BadRequestException('Cafe name is required');
    }

    if (!date) {
      throw new BadRequestException('Date is required');
    }

    // Parse and validate date
    let bookingDate: Date;
    try {
      bookingDate = new Date(date);
      if (isNaN(bookingDate.getTime())) {
        throw new Error('Invalid date');
      }
    } catch {
      throw new BadRequestException('Invalid date format. Please provide a valid date');
    }

    // Check if date is in the past
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    if (bookingDate < today) {
      throw new BadRequestException('Cannot check availability for past dates');
    }

    const allSlots = [
      '11:00', '11:30', '12:00', '12:30', '13:00', '13:30',
      '14:00', '14:30', '15:00', '15:30', '16:00', '16:30',
      '17:00', '17:30', '18:00', '18:30', '19:00', '19:30',
      '20:00', '20:30', '21:00',
    ];

    try {
      const bookedSlots = await this.prisma.booking.findMany({
        where: {
          cafeName,
          date: bookingDate,
          status: { in: [BookingStatus.PENDING, BookingStatus.CONFIRMED] },
        },
        select: { timeSlot: true },
      });

      const bookedSlotSet = new Set(bookedSlots.map((b) => b.timeSlot));

      // If checking today, filter out past time slots
      const now = new Date();
      const isToday = bookingDate.toDateString() === now.toDateString();

      return allSlots.map((slot) => {
        let available = !bookedSlotSet.has(slot);

        // If today, mark past slots as unavailable
        if (isToday && available) {
          const [hours, minutes] = slot.split(':').map(Number);
          const slotTime = new Date(bookingDate);
          slotTime.setHours(hours, minutes, 0, 0);
          if (slotTime <= now) {
            available = false;
          }
        }

        return {
          time: slot,
          available,
        };
      });
    } catch (error) {
      this.logger.error(`Failed to get available time slots: ${error.message}`, error.stack);
      throw new InternalServerErrorException('Failed to retrieve available time slots. Please try again later.');
    }
  }

  private generateConfirmationCode(): string {
    return `BK-${uuidv4().substring(0, 8).toUpperCase()}`;
  }
}
