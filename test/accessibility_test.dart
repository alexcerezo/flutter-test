// Accessibility tests to verify semantic labels and screen reader support
//
// These tests verify that all interactive elements have proper semantic labels
// according to WCAG guidelines.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/main.dart';
import 'package:flutter_app/events_notifier.dart';
import 'package:flutter_app/events_home_page.dart';
import 'package:flutter_app/event_detail_page.dart';

void main() {
  group('Home Page Accessibility', () {
    testWidgets('Event cards have semantic labels', (WidgetTester tester) async {
      await tester.pumpWidget(const EventBookingApp());
      await tester.pumpAndSettle();

      // Find a Semantics widget with button role and event label
      final semanticsFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.button == true &&
            widget.properties.label != null &&
            widget.properties.label!.contains('Evento:'),
      );

      expect(semanticsFinder, findsWidgets);
    });

    testWidgets('AppBar has semantic header', (WidgetTester tester) async {
      await tester.pumpWidget(const EventBookingApp());
      await tester.pumpAndSettle();

      // Find a Semantics widget with header role
      final headerFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.header == true &&
            widget.properties.label == 'Eventos Disponibles',
      );

      expect(headerFinder, findsOneWidget);
    });

    testWidgets('Event images have semantic labels', (WidgetTester tester) async {
      await tester.pumpWidget(const EventBookingApp());
      await tester.pumpAndSettle();

      // Find Semantics widgets with image role
      final imageFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.image == true &&
            widget.properties.label != null &&
            widget.properties.label!.contains('Imagen del evento'),
      );

      expect(imageFinder, findsWidgets);
    });

    testWidgets('Event cards have value with date, location, and price', 
        (WidgetTester tester) async {
      await tester.pumpWidget(const EventBookingApp());
      await tester.pumpAndSettle();

      // Find a Semantics widget with complete event information
      final semanticsFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.value != null &&
            widget.properties.value!.contains('Fecha:') &&
            widget.properties.value!.contains('Ubicación:') &&
            widget.properties.value!.contains('Precio:'),
      );

      expect(semanticsFinder, findsWidgets);
    });
  });

  group('Event Detail Page Accessibility', () {
    late EventsNotifier eventsNotifier;

    setUp(() {
      eventsNotifier = EventsNotifier();
    });

    tearDown(() {
      eventsNotifier.dispose();
    });

    testWidgets('Ticket counter buttons have semantic labels',
        (WidgetTester tester) async {
      final event = eventsNotifier.events.first;

      await tester.pumpWidget(
        MaterialApp(
          home: EventDetailPage(
            event: event,
            eventsNotifier: eventsNotifier,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find decrease button
      final decreaseFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.button == true &&
            widget.properties.label == 'Disminuir número de entradas',
      );
      expect(decreaseFinder, findsOneWidget);

      // Find increase button
      final increaseFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.button == true &&
            widget.properties.label == 'Aumentar número de entradas',
      );
      expect(increaseFinder, findsOneWidget);
    });

    testWidgets('Ticket count has live region for screen readers',
        (WidgetTester tester) async {
      final event = eventsNotifier.events.first;

      await tester.pumpWidget(
        MaterialApp(
          home: EventDetailPage(
            event: event,
            eventsNotifier: eventsNotifier,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find ticket count with live region
      final countFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.liveRegion == true &&
            widget.properties.label != null &&
            widget.properties.label!.contains('entradas seleccionadas'),
      );

      expect(countFinder, findsOneWidget);
    });

    testWidgets('Total price has live region for screen readers',
        (WidgetTester tester) async {
      final event = eventsNotifier.events.first;

      await tester.pumpWidget(
        MaterialApp(
          home: EventDetailPage(
            event: event,
            eventsNotifier: eventsNotifier,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find total price with live region
      final priceFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.liveRegion == true &&
            widget.properties.label != null &&
            widget.properties.label!.startsWith('€'),
      );

      expect(priceFinder, findsOneWidget);
    });

    testWidgets('Info cards have semantic labels',
        (WidgetTester tester) async {
      final event = eventsNotifier.events.first;

      await tester.pumpWidget(
        MaterialApp(
          home: EventDetailPage(
            event: event,
            eventsNotifier: eventsNotifier,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find info cards with semantic labels
      final infoCardFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label != null &&
            (widget.properties.label!.startsWith('Fecha:') ||
                widget.properties.label!.startsWith('Hora:') ||
                widget.properties.label!.startsWith('Ubicación:')),
      );

      expect(infoCardFinder, findsWidgets);
    });

    testWidgets('Confirm booking button has semantic label and hint',
        (WidgetTester tester) async {
      final event = eventsNotifier.events.first;

      await tester.pumpWidget(
        MaterialApp(
          home: EventDetailPage(
            event: event,
            eventsNotifier: eventsNotifier,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find confirm button
      final buttonFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.button == true &&
            widget.properties.label == 'Confirmar Reserva' &&
            widget.properties.hint != null,
      );

      expect(buttonFinder, findsOneWidget);
    });

    testWidgets('Event header has semantic label',
        (WidgetTester tester) async {
      final event = eventsNotifier.events.first;

      await tester.pumpWidget(
        MaterialApp(
          home: EventDetailPage(
            event: event,
            eventsNotifier: eventsNotifier,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find header with event title
      final headerFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.header == true &&
            widget.properties.label == event.title,
      );

      expect(headerFinder, findsOneWidget);
    });

    testWidgets('Event image has semantic label',
        (WidgetTester tester) async {
      final event = eventsNotifier.events.first;

      await tester.pumpWidget(
        MaterialApp(
          home: EventDetailPage(
            event: event,
            eventsNotifier: eventsNotifier,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find event image with semantic label
      final imageFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.image == true &&
            widget.properties.label != null &&
            widget.properties.label!.contains('Imagen del evento'),
      );

      expect(imageFinder, findsOneWidget);
    });

    testWidgets('Availability info has semantic label',
        (WidgetTester tester) async {
      final event = eventsNotifier.events.first;

      await tester.pumpWidget(
        MaterialApp(
          home: EventDetailPage(
            event: event,
            eventsNotifier: eventsNotifier,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find availability info with semantic label
      final availabilityFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label != null &&
            widget.properties.label!.contains('Disponibilidad:'),
      );

      expect(availabilityFinder, findsOneWidget);
    });

    testWidgets('Sold out event has semantic label',
        (WidgetTester tester) async {
      // Find or create a sold out event
      var soldOutEvent = eventsNotifier.events.firstWhere(
        (e) => e.isSoldOut,
        orElse: () => eventsNotifier.events.first.copyWith(
          bookedTickets: eventsNotifier.events.first.maxCapacity,
        ),
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

      // Find sold out message with semantic label
      final soldOutFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label != null &&
            widget.properties.label!.contains('Evento Agotado'),
      );

      expect(soldOutFinder, findsOneWidget);
    });
  });

  group('Dialog Accessibility', () {
    late EventsNotifier eventsNotifier;

    setUp(() {
      eventsNotifier = EventsNotifier();
    });

    tearDown(() {
      eventsNotifier.dispose();
    });

    testWidgets('Success dialog has semantic labels',
        (WidgetTester tester) async {
      final event = eventsNotifier.events.first;

      await tester.pumpWidget(
        MaterialApp(
          home: EventDetailPage(
            event: event,
            eventsNotifier: eventsNotifier,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap confirm booking button
      await tester.tap(find.text('Confirmar Reserva'));
      await tester.pumpAndSettle();

      // Find dialog with semantic label
      final dialogFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.namesRoute == true &&
            widget.properties.label == 'Reserva Confirmada',
      );

      expect(dialogFinder, findsOneWidget);

      // Find button with semantic label
      final buttonFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.button == true &&
            widget.properties.label == 'Aceptar' &&
            widget.properties.hint != null,
      );

      expect(buttonFinder, findsOneWidget);
    });
  });

  group('Semantic Exclusion', () {
    testWidgets('Visual text is excluded when semantic label is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(const EventBookingApp());
      await tester.pumpAndSettle();

      // Find ExcludeSemantics widgets
      final excludeFinder = find.byWidgetPredicate(
        (widget) => widget is ExcludeSemantics,
      );

      // Should have ExcludeSemantics to prevent redundant announcements
      expect(excludeFinder, findsWidgets);
    });
  });
}
