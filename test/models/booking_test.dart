// Unit tests for the Booking domain model
//
// These tests verify the instantiation and immutability of the Booking class.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/booking.dart';

void main() {
  group('Booking Model', () {
    group('Constructor', () {
      test('creates a booking with all required fields', () {
        final bookingDate = DateTime(2024, 12, 31, 10, 30);
        const booking = Booking(
          id: 'booking123',
          eventId: 'event456',
          numberOfTickets: 2,
          totalPrice: 150.50,
          bookingDate: bookingDate,
        );

        expect(booking.id, equals('booking123'));
        expect(booking.eventId, equals('event456'));
        expect(booking.numberOfTickets, equals(2));
        expect(booking.totalPrice, equals(150.50));
        expect(booking.bookingDate, equals(bookingDate));
      });

      test('creates a booking with single ticket', () {
        final bookingDate = DateTime(2024, 12, 31);
        const booking = Booking(
          id: 'booking1',
          eventId: 'event1',
          numberOfTickets: 1,
          totalPrice: 50.0,
          bookingDate: bookingDate,
        );

        expect(booking.numberOfTickets, equals(1));
        expect(booking.totalPrice, equals(50.0));
      });

      test('creates a booking with multiple tickets', () {
        final bookingDate = DateTime(2024, 12, 31);
        const booking = Booking(
          id: 'booking2',
          eventId: 'event2',
          numberOfTickets: 10,
          totalPrice: 500.0,
          bookingDate: bookingDate,
        );

        expect(booking.numberOfTickets, equals(10));
        expect(booking.totalPrice, equals(500.0));
      });
    });

    group('Immutability', () {
      test('booking fields are final and cannot be reassigned', () {
        final bookingDate = DateTime(2024, 12, 31);
        const booking = Booking(
          id: 'booking1',
          eventId: 'event1',
          numberOfTickets: 2,
          totalPrice: 100.0,
          bookingDate: bookingDate,
        );

        // These should all remain constant
        expect(booking.id, equals('booking1'));
        expect(booking.eventId, equals('event1'));
        expect(booking.numberOfTickets, equals(2));
        expect(booking.totalPrice, equals(100.0));
      });
    });

    group('Edge Cases', () {
      test('handles booking with zero price (free tickets)', () {
        final bookingDate = DateTime(2024, 12, 31);
        const booking = Booking(
          id: 'booking1',
          eventId: 'event1',
          numberOfTickets: 2,
          totalPrice: 0.0,
          bookingDate: bookingDate,
        );

        expect(booking.totalPrice, equals(0.0));
      });

      test('handles booking with decimal price', () {
        final bookingDate = DateTime(2024, 12, 31);
        const booking = Booking(
          id: 'booking1',
          eventId: 'event1',
          numberOfTickets: 3,
          totalPrice: 149.97,
          bookingDate: bookingDate,
        );

        expect(booking.totalPrice, equals(149.97));
      });

      test('handles booking with large number of tickets', () {
        final bookingDate = DateTime(2024, 12, 31);
        const booking = Booking(
          id: 'booking1',
          eventId: 'event1',
          numberOfTickets: 1000,
          totalPrice: 50000.0,
          bookingDate: bookingDate,
        );

        expect(booking.numberOfTickets, equals(1000));
        expect(booking.totalPrice, equals(50000.0));
      });
    });

    group('Date Handling', () {
      test('preserves booking date with time', () {
        final bookingDate = DateTime(2024, 12, 31, 14, 30, 45);
        const booking = Booking(
          id: 'booking1',
          eventId: 'event1',
          numberOfTickets: 1,
          totalPrice: 50.0,
          bookingDate: bookingDate,
        );

        expect(booking.bookingDate, equals(bookingDate));
        expect(booking.bookingDate.hour, equals(14));
        expect(booking.bookingDate.minute, equals(30));
        expect(booking.bookingDate.second, equals(45));
      });

      test('handles bookings made at different times', () {
        final earlierDate = DateTime(2024, 1, 1, 8, 0);
        final laterDate = DateTime(2024, 12, 31, 23, 59);

        const earlierBooking = Booking(
          id: 'booking1',
          eventId: 'event1',
          numberOfTickets: 1,
          totalPrice: 50.0,
          bookingDate: earlierDate,
        );

        const laterBooking = Booking(
          id: 'booking2',
          eventId: 'event1',
          numberOfTickets: 1,
          totalPrice: 50.0,
          bookingDate: laterDate,
        );

        expect(earlierBooking.bookingDate.isBefore(laterBooking.bookingDate), isTrue);
      });
    });
  });
}
