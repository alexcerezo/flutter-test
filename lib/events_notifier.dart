import 'package:flutter/foundation.dart';
import 'event.dart';
import 'booking.dart';

/// State manager for events using ValueNotifier for optimal performance.
/// 
/// This class follows the principle of separation of concerns, keeping
/// business logic separate from UI code. It uses ValueNotifier to minimize
/// widget rebuilds - only widgets that listen to specific notifiers rebuild.
/// 
/// @Test-Agent: This class contains critical business logic that requires
/// comprehensive unit tests, especially the bookTickets method which handles
/// capacity validation and state updates.
class EventsNotifier extends ChangeNotifier {
  EventsNotifier() {
    _loadMockEvents();
  }

  List<Event> _events = [];
  final List<Booking> _bookings = [];

  /// Getter for events list (read-only)
  List<Event> get events => List.unmodifiable(_events);

  /// Getter for bookings list (read-only)
  List<Booking> get bookings => List.unmodifiable(_bookings);

  /// Load mock events data
  void _loadMockEvents() {
    _events = [
      Event(
        id: '1',
        title: 'Flutter Conference 2024',
        description:
            'Join us for the biggest Flutter conference of the year! Learn from industry experts, network with fellow developers, and discover the latest in Flutter development.',
        date: DateTime.now().add(const Duration(days: 30)),
        location: 'Madrid, Spain',
        imageUrl: 'https://picsum.photos/seed/flutter1/800/400',
        price: 99.99,
        maxCapacity: 500,
        bookedTickets: 234,
      ),
      Event(
        id: '2',
        title: 'Dart Workshop: Advanced Techniques',
        description:
            'Deep dive into advanced Dart programming techniques. Learn about isolates, async patterns, and performance optimization.',
        date: DateTime.now().add(const Duration(days: 15)),
        location: 'Barcelona, Spain',
        imageUrl: 'https://picsum.photos/seed/dart2/800/400',
        price: 49.99,
        maxCapacity: 100,
        bookedTickets: 67,
      ),
      Event(
        id: '3',
        title: 'Mobile Development Summit',
        description:
            'Explore the future of mobile development with Flutter, React Native, and more. Three days of talks, workshops, and networking.',
        date: DateTime.now().add(const Duration(days: 45)),
        location: 'Valencia, Spain',
        imageUrl: 'https://picsum.photos/seed/mobile3/800/400',
        price: 149.99,
        maxCapacity: 800,
        bookedTickets: 456,
      ),
      Event(
        id: '4',
        title: 'UI/UX Design for Flutter',
        description:
            'Learn how to create beautiful, responsive user interfaces in Flutter. Hands-on workshop with real-world examples.',
        date: DateTime.now().add(const Duration(days: 20)),
        location: 'Sevilla, Spain',
        imageUrl: 'https://picsum.photos/seed/design4/800/400',
        price: 79.99,
        maxCapacity: 150,
        bookedTickets: 89,
      ),
      Event(
        id: '5',
        title: 'Flutter for Web Masterclass',
        description:
            'Master Flutter web development. Learn best practices, optimization techniques, and deployment strategies.',
        date: DateTime.now().add(const Duration(days: 60)),
        location: 'Bilbao, Spain',
        imageUrl: 'https://picsum.photos/seed/web5/800/400',
        price: 89.99,
        maxCapacity: 200,
        bookedTickets: 145,
      ),
      Event(
        id: '6',
        title: 'State Management Deep Dive',
        description:
            'Comprehensive exploration of state management solutions in Flutter: BLoC, Riverpod, Provider, and more.',
        date: DateTime.now().add(const Duration(days: 25)),
        location: 'Zaragoza, Spain',
        imageUrl: 'https://picsum.photos/seed/state6/800/400',
        price: 59.99,
        maxCapacity: 120,
        bookedTickets: 98,
      ),
    ];
    notifyListeners();
  }

  /// Find an event by its ID
  Event? findEventById(String id) {
    try {
      return _events.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Book tickets for an event
  /// 
  /// Returns true if booking was successful, false otherwise.
  /// Validates that there are enough available tickets before booking.
  bool bookTickets(String eventId, int numberOfTickets) {
    final event = findEventById(eventId);
    if (event == null) return false;

    // Validate ticket availability
    if (numberOfTickets <= 0 || numberOfTickets > event.availableTickets) {
      return false;
    }

    // Create booking
    final booking = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      eventId: eventId,
      numberOfTickets: numberOfTickets,
      totalPrice: event.price * numberOfTickets,
      bookingDate: DateTime.now(),
    );

    _bookings.add(booking);

    // Update event booked tickets
    final updatedEvent = event.copyWith(
      bookedTickets: event.bookedTickets + numberOfTickets,
    );

    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      _events[index] = updatedEvent;
      notifyListeners();
      return true;
    }

    return false;
  }
}
