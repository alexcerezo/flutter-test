// Unit tests for the Event domain model
//
// These tests verify the business logic of the Event class,
// including computed properties, edge cases, and the copyWith method.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/event.dart';

void main() {
  group('Event Model', () {
    group('availableTickets', () {
      test('returns correct number of available tickets', () {
        final event = Event(
          id: '1',
          title: 'Test Event',
          description: 'Test Description',
          date: DateTime(2024, 12, 31),
          location: 'Test Location',
          imageUrl: 'test.jpg',
          price: 50.0,
          maxCapacity: 100,
          bookedTickets: 30,
        );

        expect(event.availableTickets, equals(70));
      });

      test('returns 0 when event is fully booked', () {
        final event = Event(
          id: '1',
          title: 'Test Event',
          description: 'Test Description',
          date: DateTime(2024, 12, 31),
          location: 'Test Location',
          imageUrl: 'test.jpg',
          price: 50.0,
          maxCapacity: 100,
          bookedTickets: 100,
        );

        expect(event.availableTickets, equals(0));
      });

      test('returns maxCapacity when no tickets are booked', () {
        final event = Event(
          id: '1',
          title: 'Test Event',
          description: 'Test Description',
          date: DateTime(2024, 12, 31),
          location: 'Test Location',
          imageUrl: 'test.jpg',
          price: 50.0,
          maxCapacity: 100,
          bookedTickets: 0,
        );

        expect(event.availableTickets, equals(100));
      });
    });

    group('isSoldOut', () {
      test('returns true when all tickets are booked', () {
        final event = Event(
          id: '1',
          title: 'Test Event',
          description: 'Test Description',
          date: DateTime(2024, 12, 31),
          location: 'Test Location',
          imageUrl: 'test.jpg',
          price: 50.0,
          maxCapacity: 100,
          bookedTickets: 100,
        );

        expect(event.isSoldOut, isTrue);
      });

      test('returns false when tickets are available', () {
        final event = Event(
          id: '1',
          title: 'Test Event',
          description: 'Test Description',
          date: DateTime(2024, 12, 31),
          location: 'Test Location',
          imageUrl: 'test.jpg',
          price: 50.0,
          maxCapacity: 100,
          bookedTickets: 50,
        );

        expect(event.isSoldOut, isFalse);
      });

      test('returns false when no tickets are booked', () {
        final event = Event(
          id: '1',
          title: 'Test Event',
          description: 'Test Description',
          date: DateTime(2024, 12, 31),
          location: 'Test Location',
          imageUrl: 'test.jpg',
          price: 50.0,
          maxCapacity: 100,
          bookedTickets: 0,
        );

        expect(event.isSoldOut, isFalse);
      });
    });

    group('copyWith', () {
      test('creates a new event with updated bookedTickets', () {
        final originalDate = DateTime(2024, 12, 31);
        final event = Event(
          id: '1',
          title: 'Test Event',
          description: 'Test Description',
          date: originalDate,
          location: 'Test Location',
          imageUrl: 'test.jpg',
          price: 50.0,
          maxCapacity: 100,
          bookedTickets: 30,
        );

        final updatedEvent = event.copyWith(bookedTickets: 45);

        expect(updatedEvent.bookedTickets, equals(45));
        expect(updatedEvent.id, equals(event.id));
        expect(updatedEvent.title, equals(event.title));
        expect(updatedEvent.maxCapacity, equals(event.maxCapacity));
      });

      test('creates a new event with multiple updated fields', () {
        final originalDate = DateTime(2024, 12, 31);
        final newDate = DateTime(2025, 1, 15);
        final event = Event(
          id: '1',
          title: 'Test Event',
          description: 'Test Description',
          date: originalDate,
          location: 'Test Location',
          imageUrl: 'test.jpg',
          price: 50.0,
          maxCapacity: 100,
          bookedTickets: 30,
        );

        final updatedEvent = event.copyWith(
          title: 'Updated Event',
          date: newDate,
          price: 75.0,
          bookedTickets: 50,
        );

        expect(updatedEvent.title, equals('Updated Event'));
        expect(updatedEvent.date, equals(newDate));
        expect(updatedEvent.price, equals(75.0));
        expect(updatedEvent.bookedTickets, equals(50));
        // Verify unchanged fields remain the same
        expect(updatedEvent.id, equals(event.id));
        expect(updatedEvent.location, equals(event.location));
        expect(updatedEvent.maxCapacity, equals(event.maxCapacity));
      });

      test('creates a new event when no parameters are provided', () {
        final date = DateTime(2024, 12, 31);
        final event = Event(
          id: '1',
          title: 'Test Event',
          description: 'Test Description',
          date: date,
          location: 'Test Location',
          imageUrl: 'test.jpg',
          price: 50.0,
          maxCapacity: 100,
          bookedTickets: 30,
        );

        final copiedEvent = event.copyWith();

        expect(copiedEvent.id, equals(event.id));
        expect(copiedEvent.title, equals(event.title));
        expect(copiedEvent.bookedTickets, equals(event.bookedTickets));
        expect(copiedEvent.maxCapacity, equals(event.maxCapacity));
      });
    });

    group('Edge Cases', () {
      test('handles event with zero capacity', () {
        final event = Event(
          id: '1',
          title: 'Test Event',
          description: 'Test Description',
          date: DateTime(2024, 12, 31),
          location: 'Test Location',
          imageUrl: 'test.jpg',
          price: 50.0,
          maxCapacity: 0,
          bookedTickets: 0,
        );

        expect(event.availableTickets, equals(0));
        expect(event.isSoldOut, isTrue);
      });

      test('handles event with large capacity', () {
        final event = Event(
          id: '1',
          title: 'Test Event',
          description: 'Test Description',
          date: DateTime(2024, 12, 31),
          location: 'Test Location',
          imageUrl: 'test.jpg',
          price: 50.0,
          maxCapacity: 100000,
          bookedTickets: 50000,
        );

        expect(event.availableTickets, equals(50000));
        expect(event.isSoldOut, isFalse);
      });

      test('handles free event (price = 0)', () {
        final event = Event(
          id: '1',
          title: 'Free Event',
          description: 'Test Description',
          date: DateTime(2024, 12, 31),
          location: 'Test Location',
          imageUrl: 'test.jpg',
          price: 0.0,
          maxCapacity: 100,
          bookedTickets: 30,
        );

        expect(event.price, equals(0.0));
        expect(event.availableTickets, equals(70));
      });
    });
  });
}
