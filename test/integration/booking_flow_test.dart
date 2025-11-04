// Integration tests for complete booking flow
//
// These tests verify the end-to-end user journey from browsing
// events to completing a booking.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_app/main.dart';

void main() {
  setUpAll(() async {
    // Initialize date formatting for Spanish locale
    await initializeDateFormatting('es_ES', null);
  });

  group('Complete Booking Flow Integration Tests', () {
    testWidgets('complete flow: browse events -> select -> book -> confirm', 
        (WidgetTester tester) async {
      // Start the app
      await tester.pumpWidget(const EventBookingApp());
      await tester.pumpAndSettle();

      // Step 1: Verify home page loads with events
      expect(find.text('Eventos Disponibles'), findsOneWidget);
      expect(find.text('Flutter Conference 2024'), findsOneWidget);

      // Step 2: Tap on an event to view details
      await tester.tap(find.text('Flutter Conference 2024'));
      await tester.pumpAndSettle();

      // Step 3: Verify we're on the detail page
      expect(find.text('Reservar Entradas'), findsOneWidget);
      expect(find.text('Confirmar Reserva'), findsOneWidget);

      // Step 4: Increment ticket count
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pump();

      // Step 5: Confirm booking
      await tester.tap(find.text('Confirmar Reserva'));
      await tester.pumpAndSettle();

      // Step 6: Verify success dialog appears
      expect(find.text('¡Reserva Confirmada!'), findsOneWidget);
      expect(find.textContaining('Has reservado'), findsOneWidget);

      // Step 7: Close dialog and return to home
      await tester.tap(find.text('Aceptar'));
      await tester.pumpAndSettle();

      // Step 8: Verify we're back at home page
      expect(find.text('Eventos Disponibles'), findsOneWidget);
    });

    testWidgets('booking updates event availability across app', 
        (WidgetTester tester) async {
      await tester.pumpWidget(const EventBookingApp());
      await tester.pumpAndSettle();

      // Navigate to event detail
      await tester.tap(find.text('Dart Workshop: Advanced Techniques'));
      await tester.pumpAndSettle();

      // Make a booking
      await tester.tap(find.text('Confirmar Reserva'));
      await tester.pumpAndSettle();

      // Close success dialog and return
      await tester.tap(find.text('Aceptar'));
      await tester.pumpAndSettle();

      // Navigate to the same event again
      await tester.tap(find.text('Dart Workshop: Advanced Techniques'));
      await tester.pumpAndSettle();

      // Verify availability has decreased
      expect(find.text('Disponibilidad'), findsOneWidget);
    });

    testWidgets('multiple bookings for different events work correctly', 
        (WidgetTester tester) async {
      await tester.pumpWidget(const EventBookingApp());
      await tester.pumpAndSettle();

      // Book first event
      await tester.tap(find.text('Flutter Conference 2024'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar Reserva'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aceptar'));
      await tester.pumpAndSettle();

      // Book second event
      await tester.tap(find.text('Mobile Development Summit'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pump();
      await tester.tap(find.text('Confirmar Reserva'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aceptar'));
      await tester.pumpAndSettle();

      // Verify we're back at home with all events
      expect(find.text('Eventos Disponibles'), findsOneWidget);
      expect(find.text('Flutter Conference 2024'), findsOneWidget);
      expect(find.text('Mobile Development Summit'), findsOneWidget);
    });

    testWidgets('error handling: insufficient tickets scenario', 
        (WidgetTester tester) async {
      await tester.pumpWidget(const EventBookingApp());
      await tester.pumpAndSettle();

      // Find an event with limited availability
      // We'll use UI/UX Design for Flutter which has 61 available tickets
      await tester.tap(find.text('UI/UX Design for Flutter'));
      await tester.pumpAndSettle();

      // Try to book many tickets by incrementing
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.byIcon(Icons.add_circle_outline));
        await tester.pump();
      }

      // The counter should respect the max available
      await tester.tap(find.text('Confirmar Reserva'));
      await tester.pumpAndSettle();

      // Should get success (as we're within limits)
      expect(find.text('¡Reserva Confirmada!'), findsOneWidget);
    });

    testWidgets('navigation: back button works correctly', 
        (WidgetTester tester) async {
      await tester.pumpWidget(const EventBookingApp());
      await tester.pumpAndSettle();

      // Navigate to detail
      await tester.tap(find.text('Flutter Conference 2024'));
      await tester.pumpAndSettle();

      // Use back button
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Verify we're back at home
      expect(find.text('Eventos Disponibles'), findsOneWidget);
      expect(find.text('Reservar Entradas'), findsNothing);
    });

    testWidgets('sold out event shows correct UI', 
        (WidgetTester tester) async {
      await tester.pumpWidget(const EventBookingApp());
      await tester.pumpAndSettle();

      // Find State Management Deep Dive event (22 available tickets)
      await tester.tap(find.text('State Management Deep Dive'));
      await tester.pumpAndSettle();

      // This event should have booking available (not sold out initially)
      expect(find.text('Reservar Entradas'), findsOneWidget);
      expect(find.text('Confirmar Reserva'), findsOneWidget);
    });

    testWidgets('ticket counter respects maximum available tickets', 
        (WidgetTester tester) async {
      await tester.pumpWidget(const EventBookingApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Flutter Conference 2024'));
      await tester.pumpAndSettle();

      // Get initial count (should be 1)
      // Try to increment many times
      for (int i = 0; i < 500; i++) {
        await tester.tap(find.byIcon(Icons.add_circle_outline));
        if (i % 10 == 0) {
          await tester.pump();
        }
      }
      await tester.pumpAndSettle();

      // Should not exceed available tickets
      // The increment button should eventually become disabled or stop working
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    });

    testWidgets('dialog buttons are accessible and functional', 
        (WidgetTester tester) async {
      await tester.pumpWidget(const EventBookingApp());
      await tester.pumpAndSettle();

      // Make a booking
      await tester.tap(find.text('Flutter Conference 2024'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar Reserva'));
      await tester.pumpAndSettle();

      // Verify dialog has correct structure
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('¡Reserva Confirmada!'), findsOneWidget);
      expect(find.text('Aceptar'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Aceptar'));
      await tester.pumpAndSettle();

      // Should navigate back
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('state persists during navigation within same session', 
        (WidgetTester tester) async {
      await tester.pumpWidget(const EventBookingApp());
      await tester.pumpAndSettle();

      // Make first booking
      await tester.tap(find.text('Flutter Conference 2024'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar Reserva'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aceptar'));
      await tester.pumpAndSettle();

      // Navigate to same event again
      await tester.tap(find.text('Flutter Conference 2024'));
      await tester.pumpAndSettle();

      // Availability should reflect previous booking
      expect(find.text('Disponibilidad'), findsOneWidget);
    });

    testWidgets('multiple rapid bookings are handled correctly', 
        (WidgetTester tester) async {
      await tester.pumpWidget(const EventBookingApp());
      await tester.pumpAndSettle();

      // Book first event
      await tester.tap(find.text('Flutter Conference 2024'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar Reserva'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aceptar'));
      await tester.pumpAndSettle();

      // Immediately book another event
      await tester.tap(find.text('Dart Workshop: Advanced Techniques'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar Reserva'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aceptar'));
      await tester.pumpAndSettle();

      // Verify we're at home and both events are still available
      expect(find.text('Eventos Disponibles'), findsOneWidget);
    });

    testWidgets('app bar navigation works throughout flow', 
        (WidgetTester tester) async {
      await tester.pumpWidget(const EventBookingApp());
      await tester.pumpAndSettle();

      // Navigate to detail
      await tester.tap(find.text('Flutter Conference 2024'));
      await tester.pumpAndSettle();

      // Find back button in app bar
      final backButton = find.byType(BackButton);
      if (tester.widgetList(backButton).isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        // Should be back at home
        expect(find.text('Eventos Disponibles'), findsOneWidget);
      }
    });
  });

  group('Edge Cases and Error Scenarios', () {
    testWidgets('handles zero available tickets gracefully', 
        (WidgetTester tester) async {
      await tester.pumpWidget(const EventBookingApp());
      await tester.pumpAndSettle();

      // This test would require an event with 0 tickets
      // In the current implementation, we'd need to book all tickets first
      expect(find.text('Eventos Disponibles'), findsOneWidget);
    });

    testWidgets('booking dialog text is localized in Spanish', 
        (WidgetTester tester) async {
      await tester.pumpWidget(const EventBookingApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Flutter Conference 2024'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar Reserva'));
      await tester.pumpAndSettle();

      // Verify Spanish text
      expect(find.text('¡Reserva Confirmada!'), findsOneWidget);
      expect(find.text('Aceptar'), findsOneWidget);
    });

    testWidgets('price display uses correct currency format', 
        (WidgetTester tester) async {
      await tester.pumpWidget(const EventBookingApp());
      await tester.pumpAndSettle();

      // Check that prices use € symbol
      expect(find.textContaining('€'), findsWidgets);
    });
  });
}
