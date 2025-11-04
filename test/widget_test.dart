// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/main.dart';

void main() {
  testWidgets('Event Booking App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EventBookingApp());

    // Verify that the app shows the events page title.
    expect(find.text('Eventos Disponibles'), findsOneWidget);

    // Wait for the events to load
    await tester.pumpAndSettle();

    // Verify that at least one event is displayed
    // (Looking for one of our mock events)
    expect(find.text('Flutter Conference 2024'), findsOneWidget);
  });
}

