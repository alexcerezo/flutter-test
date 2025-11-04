import 'package:flutter/material.dart';

import 'event.dart';
import 'events_home_page.dart';
import 'events_notifier.dart';

/// Main entry point of the Event Booking application.
/// 
/// This application follows Clean Architecture principles:
/// - Domain models (Event, Booking) are immutable
/// - Business logic is separated in EventsNotifier
/// - UI is decoupled from business logic
/// - State management uses ChangeNotifier for performance
/// 
/// Architecture decisions:
/// - ChangeNotifier for simplicity and performance
/// - Const constructors throughout for optimization
/// - Responsive design using MediaQuery and LayoutBuilder
/// - Pure build methods that don't perform side effects
void main() {
  runApp(const EventBookingApp());
}

/// Root application widget
class EventBookingApp extends StatefulWidget {
  const EventBookingApp({super.key});

  @override
  State<EventBookingApp> createState() => _EventBookingAppState();
}

class _EventBookingAppState extends State<EventBookingApp> {
  late final EventsNotifier _eventsNotifier;

  @override
  void initState() {
    super.initState();
    _eventsNotifier = EventsNotifier();
  }

  @override
  void dispose() {
    _eventsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reserva de Eventos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: EventsHomePage(eventsNotifier: _eventsNotifier),
    );
  }
}
