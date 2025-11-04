// Unit tests for EventsNotifier business logic
//
// These tests verify the critical booking functionality, state management,
// and validation logic of the EventsNotifier class.
// Using TDD principles: test the behavior, not the implementation.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/events_notifier.dart';
import 'package:flutter_app/event.dart';
import 'package:flutter_app/booking.dart';

void main() {
  group('EventsNotifier', () {
    late EventsNotifier notifier;

    setUp(() {
      notifier = EventsNotifier();
    });

    tearDown(() {
      notifier.dispose();
    });

    group('Initialization', () {
      test('loads mock events on initialization', () {
        expect(notifier.events, isNotEmpty);
        expect(notifier.events.length, equals(6));
      });

      test('starts with empty bookings list', () {
        expect(notifier.bookings, isEmpty);
      });

      test('events list is read-only (unmodifiable)', () {
        final eventsList = notifier.events;
        expect(() => eventsList.add(Event(
          id: 'new',
          title: 'New Event',
          description: 'Test',
          date: DateTime.now(),
          location: 'Test',
          imageUrl: 'test.jpg',
          price: 50.0,
          maxCapacity: 100,
        )), throwsUnsupportedError);
      });

      test('bookings list is read-only (unmodifiable)', () {
        final bookingsList = notifier.bookings;
        expect(() => bookingsList.add(Booking(
          id: '1',
          eventId: '1',
          numberOfTickets: 1,
          totalPrice: 50.0,
          bookingDate: DateTime.now(),
        )), throwsUnsupportedError);
      });
    });

    group('findEventById', () {
      test('finds an existing event by ID', () {
        final event = notifier.findEventById('1');
        
        expect(event, isNotNull);
        expect(event!.id, equals('1'));
        expect(event.title, contains('Flutter Conference'));
      });

      test('returns null for non-existent event ID', () {
        final event = notifier.findEventById('non-existent-id');
        
        expect(event, isNull);
      });

      test('returns null for empty string ID', () {
        final event = notifier.findEventById('');
        
        expect(event, isNull);
      });

      test('finds all mock events by their IDs', () {
        for (int i = 1; i <= 6; i++) {
          final event = notifier.findEventById(i.toString());
          expect(event, isNotNull);
          expect(event!.id, equals(i.toString()));
        }
      });
    });

    group('bookTickets - Successful Bookings', () {
      test('books tickets successfully with valid data', () {
        final event = notifier.findEventById('1')!;
        final initialBookedTickets = event.bookedTickets;
        
        final result = notifier.bookTickets('1', 2);
        
        expect(result, isTrue);
        expect(notifier.bookings.length, equals(1));
        
        final booking = notifier.bookings.first;
        expect(booking.eventId, equals('1'));
        expect(booking.numberOfTickets, equals(2));
        expect(booking.totalPrice, equals(event.price * 2));
        
        final updatedEvent = notifier.findEventById('1')!;
        expect(updatedEvent.bookedTickets, equals(initialBookedTickets + 2));
      });

      test('books single ticket successfully', () {
        final event = notifier.findEventById('2')!;
        final initialBookedTickets = event.bookedTickets;
        
        final result = notifier.bookTickets('2', 1);
        
        expect(result, isTrue);
        expect(notifier.bookings.length, equals(1));
        expect(notifier.bookings.first.numberOfTickets, equals(1));
        
        final updatedEvent = notifier.findEventById('2')!;
        expect(updatedEvent.bookedTickets, equals(initialBookedTickets + 1));
      });

      test('books maximum available tickets', () {
        final event = notifier.findEventById('3')!;
        final availableTickets = event.availableTickets;
        
        final result = notifier.bookTickets('3', availableTickets);
        
        expect(result, isTrue);
        
        final updatedEvent = notifier.findEventById('3')!;
        expect(updatedEvent.isSoldOut, isTrue);
        expect(updatedEvent.availableTickets, equals(0));
      });

      test('creates multiple separate bookings', () {
        notifier.bookTickets('1', 2);
        notifier.bookTickets('2', 3);
        notifier.bookTickets('3', 1);
        
        expect(notifier.bookings.length, equals(3));
        expect(notifier.bookings[0].eventId, equals('1'));
        expect(notifier.bookings[1].eventId, equals('2'));
        expect(notifier.bookings[2].eventId, equals('3'));
      });

      test('creates booking with correct total price', () {
        final event = notifier.findEventById('1')!;
        final numberOfTickets = 5;
        
        notifier.bookTickets('1', numberOfTickets);
        
        final booking = notifier.bookings.first;
        expect(booking.totalPrice, equals(event.price * numberOfTickets));
      });

      test('generates unique booking ID', () {
        notifier.bookTickets('1', 1);
        final firstBookingId = notifier.bookings.first.id;
        
        // Wait a tiny bit to ensure different timestamp
        Future.delayed(const Duration(milliseconds: 1));
        
        notifier.bookTickets('2', 1);
        final secondBookingId = notifier.bookings[1].id;
        
        expect(firstBookingId, isNot(equals(secondBookingId)));
      });
    });

    group('bookTickets - Validation Failures', () {
      test('fails when event ID does not exist', () {
        final result = notifier.bookTickets('non-existent', 1);
        
        expect(result, isFalse);
        expect(notifier.bookings, isEmpty);
      });

      test('fails when booking zero tickets', () {
        final result = notifier.bookTickets('1', 0);
        
        expect(result, isFalse);
        expect(notifier.bookings, isEmpty);
      });

      test('fails when booking negative tickets', () {
        final result = notifier.bookTickets('1', -5);
        
        expect(result, isFalse);
        expect(notifier.bookings, isEmpty);
      });

      test('fails when booking more tickets than available', () {
        final event = notifier.findEventById('1')!;
        final availableTickets = event.availableTickets;
        
        final result = notifier.bookTickets('1', availableTickets + 1);
        
        expect(result, isFalse);
        expect(notifier.bookings, isEmpty);
      });

      test('fails when event is sold out', () {
        final event = notifier.findEventById('1')!;
        
        // Book all available tickets
        notifier.bookTickets('1', event.availableTickets);
        
        // Try to book one more
        final result = notifier.bookTickets('1', 1);
        
        expect(result, isFalse);
        expect(notifier.bookings.length, equals(1)); // Only the first booking
      });

      test('does not update event when booking fails', () {
        final event = notifier.findEventById('1')!;
        final initialBookedTickets = event.bookedTickets;
        
        // Try to book more than available
        notifier.bookTickets('1', event.availableTickets + 100);
        
        final unchangedEvent = notifier.findEventById('1')!;
        expect(unchangedEvent.bookedTickets, equals(initialBookedTickets));
      });
    });

    group('State Management and Notifications', () {
      test('notifies listeners when booking is successful', () {
        var notificationCount = 0;
        notifier.addListener(() {
          notificationCount++;
        });
        
        notifier.bookTickets('1', 2);
        
        expect(notificationCount, equals(1));
      });

      test('does not notify listeners when booking fails', () {
        var notificationCount = 0;
        notifier.addListener(() {
          notificationCount++;
        });
        
        notifier.bookTickets('non-existent', 1);
        
        expect(notificationCount, equals(0));
      });

      test('updates state correctly after multiple bookings', () {
        final event1 = notifier.findEventById('1')!;
        final event2 = notifier.findEventById('2')!;
        
        final initialBookedTickets1 = event1.bookedTickets;
        final initialBookedTickets2 = event2.bookedTickets;
        
        notifier.bookTickets('1', 3);
        notifier.bookTickets('2', 5);
        notifier.bookTickets('1', 2);
        
        expect(notifier.bookings.length, equals(3));
        
        final updatedEvent1 = notifier.findEventById('1')!;
        final updatedEvent2 = notifier.findEventById('2')!;
        
        expect(updatedEvent1.bookedTickets, equals(initialBookedTickets1 + 3 + 2));
        expect(updatedEvent2.bookedTickets, equals(initialBookedTickets2 + 5));
      });
    });

    group('Edge Cases and Boundary Conditions', () {
      test('handles booking exactly one ticket remaining', () {
        final event = notifier.findEventById('4')!;
        final availableTickets = event.availableTickets;
        
        // Book all but one ticket
        notifier.bookTickets('4', availableTickets - 1);
        
        // Book the last ticket
        final result = notifier.bookTickets('4', 1);
        
        expect(result, isTrue);
        final updatedEvent = notifier.findEventById('4')!;
        expect(updatedEvent.isSoldOut, isTrue);
      });

      test('handles rapid successive bookings for same event', () {
        final event = notifier.findEventById('5')!;
        final initialAvailable = event.availableTickets;
        
        final result1 = notifier.bookTickets('5', 10);
        final result2 = notifier.bookTickets('5', 20);
        final result3 = notifier.bookTickets('5', 5);
        
        expect(result1, isTrue);
        expect(result2, isTrue);
        expect(result3, isTrue);
        
        final updatedEvent = notifier.findEventById('5')!;
        expect(updatedEvent.bookedTickets, 
               equals(event.bookedTickets + 10 + 20 + 5));
      });

      test('maintains data consistency after failed booking attempt', () {
        final event = notifier.findEventById('6')!;
        final initialState = {
          'bookedTickets': event.bookedTickets,
          'availableTickets': event.availableTickets,
          'bookingsCount': notifier.bookings.length,
        };
        
        // Attempt invalid booking
        notifier.bookTickets('6', -1);
        notifier.bookTickets('6', 0);
        notifier.bookTickets('6', event.availableTickets + 1000);
        
        final unchangedEvent = notifier.findEventById('6')!;
        expect(unchangedEvent.bookedTickets, equals(initialState['bookedTickets']));
        expect(unchangedEvent.availableTickets, equals(initialState['availableTickets']));
        expect(notifier.bookings.length, equals(initialState['bookingsCount']));
      });
    });

    group('Booking Date', () {
      test('sets booking date to current time', () {
        final beforeBooking = DateTime.now();
        
        notifier.bookTickets('1', 1);
        
        final afterBooking = DateTime.now();
        final booking = notifier.bookings.first;
        
        expect(booking.bookingDate.isAfter(beforeBooking.subtract(const Duration(seconds: 1))), isTrue);
        expect(booking.bookingDate.isBefore(afterBooking.add(const Duration(seconds: 1))), isTrue);
      });
    });
  });
}
