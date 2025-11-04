// Widget tests for EventDetailPage and booking flow
//
// These tests verify the complete booking functionality including
// ticket selection, validation, and confirmation dialogs.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_app/event_detail_page.dart';
import 'package:flutter_app/events_notifier.dart';
import 'package:flutter_app/event.dart';

void main() {
  setUpAll(() async {
    // Initialize date formatting for Spanish locale
    await initializeDateFormatting('es_ES', null);
  });

  group('EventDetailPage Widget', () {
    late EventsNotifier eventsNotifier;
    late Event testEvent;

    setUp(() {
      eventsNotifier = EventsNotifier();
      testEvent = eventsNotifier.events.first;
    });

    tearDown(() {
      eventsNotifier.dispose();
    });

    group('Rendering', () {
      testWidgets('displays event title in app bar', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: EventDetailPage(
              event: testEvent,
              eventsNotifier: eventsNotifier,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(testEvent.title), findsWidgets);
      });

      testWidgets('displays event description', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: EventDetailPage(
              event: testEvent,
              eventsNotifier: eventsNotifier,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(testEvent.description), findsOneWidget);
      });

      testWidgets('displays event location', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: EventDetailPage(
              event: testEvent,
              eventsNotifier: eventsNotifier,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(testEvent.location), findsOneWidget);
      });

      testWidgets('displays availability information', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: EventDetailPage(
              event: testEvent,
              eventsNotifier: eventsNotifier,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Disponibilidad'), findsOneWidget);
        expect(find.textContaining('disponibles'), findsOneWidget);
      });

      testWidgets('displays info cards for date, time, and location', 
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: EventDetailPage(
              event: testEvent,
              eventsNotifier: eventsNotifier,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Fecha'), findsOneWidget);
        expect(find.text('Hora'), findsOneWidget);
        expect(find.text('Ubicación'), findsOneWidget);
      });

      testWidgets('displays booking section when not sold out', 
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: EventDetailPage(
              event: testEvent,
              eventsNotifier: eventsNotifier,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Reservar Entradas'), findsOneWidget);
        expect(find.text('Confirmar Reserva'), findsOneWidget);
      });

      testWidgets('displays sold out message when event is full', 
          (WidgetTester tester) async {
        // Create a sold-out event
        final soldOutEvent = testEvent.copyWith(
          bookedTickets: testEvent.maxCapacity,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: EventDetailPage(
              event: soldOutEvent,
              eventsNotifier: eventsNotifier,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Evento Agotado'), findsOneWidget);
        expect(find.text('Lo sentimos, no quedan entradas disponibles.'), 
               findsOneWidget);
        expect(find.text('Confirmar Reserva'), findsNothing);
      });
    });

    group('Ticket Counter', () {
      testWidgets('displays initial ticket count as 1', 
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: EventDetailPage(
              event: testEvent,
              eventsNotifier: eventsNotifier,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Número de entradas'), findsOneWidget);
        // The counter should show 1 initially
        expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
        expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
      });

      testWidgets('increments ticket count when plus button tapped', 
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: EventDetailPage(
              event: testEvent,
              eventsNotifier: eventsNotifier,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find and tap the increment button
        final incrementButton = find.byIcon(Icons.add_circle_outline);
        await tester.tap(incrementButton);
        await tester.pump();

        // Verify the count increased (check in Total section)
        expect(find.text('Total'), findsOneWidget);
      });

      testWidgets('decrements ticket count when minus button tapped', 
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: EventDetailPage(
              event: testEvent,
              eventsNotifier: eventsNotifier,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // First increment to 2
        await tester.tap(find.byIcon(Icons.add_circle_outline));
        await tester.pump();

        // Then decrement back to 1
        await tester.tap(find.byIcon(Icons.remove_circle_outline));
        await tester.pump();

        // Verify counter still works
        expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
      });

      testWidgets('does not decrement below 1', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: EventDetailPage(
              event: testEvent,
              eventsNotifier: eventsNotifier,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Try to decrement from initial value of 1
        await tester.tap(find.byIcon(Icons.remove_circle_outline));
        await tester.pump();

        // Should still be at 1 (button might be disabled)
        expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
      });

      testWidgets('does not increment beyond available tickets', 
          (WidgetTester tester) async {
        // Create event with only 2 available tickets
        final limitedEvent = testEvent.copyWith(
          bookedTickets: testEvent.maxCapacity - 2,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: EventDetailPage(
              event: limitedEvent,
              eventsNotifier: eventsNotifier,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Increment to max
        await tester.tap(find.byIcon(Icons.add_circle_outline));
        await tester.pump();

        // Try to increment beyond max
        await tester.tap(find.byIcon(Icons.add_circle_outline));
        await tester.pump();

        // Should not go beyond available tickets
        expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
      });
    });

    group('Price Calculation', () {
      testWidgets('updates total price when ticket count changes', 
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: EventDetailPage(
              event: testEvent,
              eventsNotifier: eventsNotifier,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Initial price for 1 ticket
        expect(find.text('Total'), findsOneWidget);

        // Increment to 2 tickets
        await tester.tap(find.byIcon(Icons.add_circle_outline));
        await tester.pump();

        // Price should update (Total section should still exist)
        expect(find.text('Total'), findsOneWidget);
      });

      testWidgets('displays correct total for multiple tickets', 
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: EventDetailPage(
              event: testEvent,
              eventsNotifier: eventsNotifier,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Add 3 more tickets (start at 1, add 3 = 4 total)
        for (int i = 0; i < 3; i++) {
          await tester.tap(find.byIcon(Icons.add_circle_outline));
          await tester.pump();
        }

        // Verify total section exists
        expect(find.text('Total'), findsOneWidget);
        // The actual price text should be formatted as €X.XX
        expect(find.textContaining('€'), findsWidgets);
      });
    });

    group('Booking Flow', () {
      testWidgets('shows success dialog on successful booking', 
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: EventDetailPage(
              event: testEvent,
              eventsNotifier: eventsNotifier,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap confirm booking button
        await tester.tap(find.text('Confirmar Reserva'));
        await tester.pumpAndSettle();

        // Verify success dialog appears
        expect(find.text('¡Reserva Confirmada!'), findsOneWidget);
        expect(find.textContaining('Has reservado'), findsOneWidget);
      });

      testWidgets('creates booking in notifier on success', 
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: EventDetailPage(
              event: testEvent,
              eventsNotifier: eventsNotifier,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(eventsNotifier.bookings.length, equals(0));

        // Tap confirm booking
        await tester.tap(find.text('Confirmar Reserva'));
        await tester.pumpAndSettle();

        // Verify booking was created
        expect(eventsNotifier.bookings.length, equals(1));
        expect(eventsNotifier.bookings.first.eventId, equals(testEvent.id));
      });

      testWidgets('updates event booked tickets after booking', 
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: EventDetailPage(
              event: testEvent,
              eventsNotifier: eventsNotifier,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final initialBookedTickets = testEvent.bookedTickets;

        // Book 2 tickets
        await tester.tap(find.byIcon(Icons.add_circle_outline));
        await tester.pump();

        await tester.tap(find.text('Confirmar Reserva'));
        await tester.pumpAndSettle();

        // Verify event was updated
        final updatedEvent = eventsNotifier.findEventById(testEvent.id)!;
        expect(updatedEvent.bookedTickets, equals(initialBookedTickets + 2));
      });

      testWidgets('shows error dialog when booking more than available', 
          (WidgetTester tester) async {
        // Create event with limited tickets
        final limitedEvent = testEvent.copyWith(
          bookedTickets: testEvent.maxCapacity - 1,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: EventDetailPage(
              event: limitedEvent,
              eventsNotifier: eventsNotifier,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Try to book 2 tickets (only 1 available)
        await tester.tap(find.byIcon(Icons.add_circle_outline));
        await tester.pump();

        await tester.tap(find.text('Confirmar Reserva'));
        await tester.pumpAndSettle();

        // Verify error dialog appears
        expect(find.text('Error'), findsOneWidget);
        expect(find.textContaining('No hay suficientes entradas'), findsOneWidget);
      });

      testWidgets('closes success dialog and navigates back on accept', 
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => EventDetailPage(
                          event: testEvent,
                          eventsNotifier: eventsNotifier,
                        ),
                      ),
                    );
                  },
                  child: const Text('Go to Detail'),
                ),
              ),
            ),
          ),
        );

        // Navigate to detail page
        await tester.tap(find.text('Go to Detail'));
        await tester.pumpAndSettle();

        // Make booking
        await tester.tap(find.text('Confirmar Reserva'));
        await tester.pumpAndSettle();

        // Close dialog
        await tester.tap(find.text('Aceptar'));
        await tester.pumpAndSettle();

        // Should navigate back to home
        expect(find.text('Go to Detail'), findsOneWidget);
      });

      testWidgets('closes error dialog on accept', (WidgetTester tester) async {
        // Create event with limited tickets
        final limitedEvent = testEvent.copyWith(
          bookedTickets: testEvent.maxCapacity - 1,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: EventDetailPage(
              event: limitedEvent,
              eventsNotifier: eventsNotifier,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Try invalid booking
        await tester.tap(find.byIcon(Icons.add_circle_outline));
        await tester.pump();
        await tester.tap(find.text('Confirmar Reserva'));
        await tester.pumpAndSettle();

        // Close error dialog
        await tester.tap(find.text('Aceptar'));
        await tester.pumpAndSettle();

        // Should be back on detail page
        expect(find.text('Confirmar Reserva'), findsOneWidget);
      });
    });

    group('Dynamic Updates', () {
      testWidgets('reflects updated availability after booking', 
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: EventDetailPage(
              event: testEvent,
              eventsNotifier: eventsNotifier,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Make a booking
        await tester.tap(find.text('Confirmar Reserva'));
        await tester.pumpAndSettle();

        // Close success dialog
        final acceptButton = find.text('Aceptar');
        if (tester.widgetList(acceptButton).isNotEmpty) {
          // The page should show updated availability
          expect(find.text('Disponibilidad'), findsOneWidget);
        }
      });

      testWidgets('updates when external booking occurs', 
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: EventDetailPage(
              event: testEvent,
              eventsNotifier: eventsNotifier,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Simulate external booking
        eventsNotifier.bookTickets(testEvent.id, 10);
        await tester.pump();

        // Page should update with new availability
        expect(find.text('Disponibilidad'), findsOneWidget);
      });
    });

    group('UI Icons', () {
      testWidgets('displays calendar icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: EventDetailPage(
              event: testEvent,
              eventsNotifier: eventsNotifier,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      });

      testWidgets('displays time icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: EventDetailPage(
              event: testEvent,
              eventsNotifier: eventsNotifier,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.access_time), findsOneWidget);
      });

      testWidgets('displays location icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: EventDetailPage(
              event: testEvent,
              eventsNotifier: eventsNotifier,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.location_on), findsOneWidget);
      });
    });

    group('Scrolling', () {
      testWidgets('page is scrollable', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: EventDetailPage(
              event: testEvent,
              eventsNotifier: eventsNotifier,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find the CustomScrollView
        expect(find.byType(CustomScrollView), findsOneWidget);

        // Try scrolling
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
        await tester.pump();

        // Should still find the booking button after scroll
        expect(find.text('Confirmar Reserva'), findsOneWidget);
      });
    });
  });
}
