#!/usr/bin/env python3
"""
Flutter Event Booking App Setup Script
This script creates the complete directory structure and source files
for the Flutter event booking application.
"""

import os
from pathlib import Path

# Define the project structure with file contents
FILES = {
    'lib/main.dart': '''import 'package:flutter/material.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  runApp(const EventBookingApp());
}

/// Root application widget
/// Uses MaterialApp for Material Design implementation
class EventBookingApp extends StatelessWidget {
  const EventBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Booking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
''',

    'lib/domain/models/event.dart': '''/// Domain model representing an Event
/// Immutable and follows value object pattern for clean architecture
/// 
/// @Test-Agent: This model is pure and easily testable.
/// Consider testing the hasAvailableTickets getter and copyWith method.
class Event {
  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.price,
    required this.availableTickets,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final double price;
  final int availableTickets;
  final String imageUrl;

  bool get hasAvailableTickets => availableTickets > 0;

  /// Creates a copy with updated fields
  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? location,
    double? price,
    int? availableTickets,
    String? imageUrl,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      price: price ?? this.price,
      availableTickets: availableTickets ?? this.availableTickets,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
''',

    'lib/domain/models/booking.dart': '''/// Domain model representing a Booking
/// Immutable and follows value object pattern
/// 
/// @Test-Agent: Simple value object, consider testing equality and construction.
class Booking {
  const Booking({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.numberOfTickets,
    required this.totalPrice,
    required this.bookingDate,
  });

  final String id;
  final String eventId;
  final String eventTitle;
  final int numberOfTickets;
  final double totalPrice;
  final DateTime bookingDate;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Booking && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
''',

    'lib/data/repositories/event_repository.dart': '''import '../../domain/models/event.dart';

/// Repository for managing Event data
/// In-memory implementation for simplicity
/// Could be extended to use actual backend services
/// 
/// @Test-Agent: Consider mocking this repository for widget tests.
/// The business logic here is minimal but the state management is crucial.
class EventRepository {
  EventRepository() {
    _initializeMockEvents();
  }

  final List<Event> _events = [];

  /// Returns all available events
  List<Event> getAllEvents() => List.unmodifiable(_events);

  /// Returns a specific event by ID
  Event? getEventById(String id) {
    try {
      return _events.firstWhere((event) => event.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Books tickets for an event
  /// Returns true if booking was successful
  bool bookTickets(String eventId, int numberOfTickets) {
    final eventIndex = _events.indexWhere((e) => e.id == eventId);
    if (eventIndex == -1) return false;

    final event = _events[eventIndex];
    if (event.availableTickets < numberOfTickets) return false;

    _events[eventIndex] = event.copyWith(
      availableTickets: event.availableTickets - numberOfTickets,
    );
    return true;
  }

  void _initializeMockEvents() {
    _events.addAll([
      Event(
        id: '1',
        title: 'Flutter Forward 2024',
        description: 'Join us for the biggest Flutter conference of the year! '
            'Learn about the latest updates, best practices, and connect with '
            'the Flutter community. Amazing speakers and workshops await.',
        date: DateTime(2024, 12, 15, 9, 0),
        location: 'San Francisco, CA',
        price: 299.99,
        availableTickets: 150,
        imageUrl: 'https://via.placeholder.com/400x200/5C6BC0/FFFFFF?text=Flutter+Forward',
      ),
      Event(
        id: '2',
        title: 'Dart Summit 2024',
        description: 'Deep dive into Dart language features, performance '
            'optimization, and advanced programming techniques. Perfect for '
            'developers who want to master Dart.',
        date: DateTime(2024, 11, 20, 10, 0),
        location: 'New York, NY',
        price: 199.99,
        availableTickets: 200,
        imageUrl: 'https://via.placeholder.com/400x200/42A5F5/FFFFFF?text=Dart+Summit',
      ),
      Event(
        id: '3',
        title: 'Mobile Dev Meetup',
        description: 'Monthly meetup for mobile developers. Share experiences, '
            'network with peers, and learn about the latest trends in mobile '
            'development. Free pizza and drinks!',
        date: DateTime(2024, 11, 10, 18, 30),
        location: 'Austin, TX',
        price: 0.0,
        availableTickets: 50,
        imageUrl: 'https://via.placeholder.com/400x200/66BB6A/FFFFFF?text=Mobile+Meetup',
      ),
      Event(
        id: '4',
        title: 'UI/UX Workshop',
        description: 'Hands-on workshop on creating beautiful and functional '
            'user interfaces with Flutter. Learn about Material Design, '
            'responsive layouts, and animation best practices.',
        date: DateTime(2024, 12, 1, 13, 0),
        location: 'Seattle, WA',
        price: 149.99,
        availableTickets: 30,
        imageUrl: 'https://via.placeholder.com/400x200/AB47BC/FFFFFF?text=UI+UX+Workshop',
      ),
      Event(
        id: '5',
        title: 'Backend with Dart',
        description: 'Explore server-side Dart development with frameworks like '
            'Shelf and Serverpod. Build scalable backends for your Flutter apps.',
        date: DateTime(2024, 11, 25, 14, 0),
        location: 'Chicago, IL',
        price: 249.99,
        availableTickets: 75,
        imageUrl: 'https://via.placeholder.com/400x200/EF5350/FFFFFF?text=Backend+Dart',
      ),
      Event(
        id: '6',
        title: 'State Management Masterclass',
        description: 'Master all state management solutions in Flutter: '
            'Provider, Riverpod, BLoC, GetX, and more. Understand when to use each.',
        date: DateTime(2024, 12, 8, 11, 0),
        location: 'Boston, MA',
        price: 179.99,
        availableTickets: 100,
        imageUrl: 'https://via.placeholder.com/400x200/FFA726/FFFFFF?text=State+Management',
      ),
    ]);
  }
}
''',
}

def create_files():
    """Create all project files with proper directory structure"""
    project_root = Path(__file__).parent
    
    print("Creating Flutter project structure...")
    
    for file_path, content in FILES.items():
        full_path = project_root / file_path
        
        # Create parent directories
        full_path.parent.mkdir(parents=True, exist_ok=True)
        
        # Write file content
        full_path.write_text(content)
        print(f"✓ Created {file_path}")
    
    # Create empty test directories
    (project_root / 'test').mkdir(exist_ok=True)
    (project_root / 'integration_test').mkdir(exist_ok=True)
    
    print("\n✓ Project structure created successfully!")
    print("\nNext steps:")
    print("1. Run: flutter pub get")
    print("2. Run: flutter run")

if __name__ == '__main__':
    create_files()
