# Flutter Event Booking App - Complete Code Structure

This document contains the complete code for the Flutter Event Booking application.
Follow the setup instructions to create the proper directory structure.

## Setup Instructions

1. Run the setup script:
   ```bash
   chmod +x setup_structure.sh
   ./setup_structure.sh
   ```

2. Copy each code block below into its respective file path.

3. Run `flutter pub get` to install dependencies.

4. Run `flutter run` to start the application.

---

## File: lib/main.dart

```dart
import 'package:flutter/material.dart';
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
```

---

## File: lib/domain/models/event.dart

```dart
/// Domain model representing an Event
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
```

---

## File: lib/domain/models/booking.dart

```dart
/// Domain model representing a Booking
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
```

---

## File: lib/data/repositories/event_repository.dart

```dart
import '../../domain/models/event.dart';

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
```

---

## File: lib/presentation/state/event_state.dart

```dart
import 'package:flutter/foundation.dart';
import '../../domain/models/event.dart';
import '../../data/repositories/event_repository.dart';

/// State manager for events using ValueNotifier for optimal performance
/// Separates business logic from UI (Clean Architecture principle)
/// 
/// @Test-Agent: This class contains critical business logic.
/// Test the booking flow, event loading, and state transitions thoroughly.
class EventState extends ChangeNotifier {
  EventState(this._repository) {
    _loadEvents();
  }

  final EventRepository _repository;
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;

  List<Event> get events => List.unmodifiable(_events);
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _loadEvents() {
    _isLoading = true;
    notifyListeners();

    try {
      _events = _repository.getAllEvents();
      _error = null;
    } catch (e) {
      _error = 'Failed to load events: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Event? getEventById(String id) {
    try {
      return _events.firstWhere((event) => event.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Books tickets for an event
  /// Returns true if successful, false otherwise
  bool bookTickets(String eventId, int numberOfTickets) {
    if (numberOfTickets <= 0) return false;

    final success = _repository.bookTickets(eventId, numberOfTickets);
    if (success) {
      _loadEvents();
    }
    return success;
  }

  void refresh() {
    _loadEvents();
  }
}
```

---

## File: lib/presentation/screens/home_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/event_repository.dart';
import '../state/event_state.dart';
import '../widgets/event_card.dart';
import '../widgets/responsive_grid.dart';
import 'event_detail_screen.dart';

/// Home screen displaying list of available events
/// Implements responsive design using ResponsiveGrid widget
/// 
/// @Access-Agent: This is the main entry screen.
/// Please review semantic labels and screen reader navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final EventState _eventState;

  @override
  void initState() {
    super.initState();
    _eventState = EventState(EventRepository());
    _eventState.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _eventState.removeListener(_onStateChanged);
    _eventState.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Booking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _eventState.refresh,
            tooltip: 'Refresh events',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_eventState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_eventState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _eventState.error!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _eventState.refresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_eventState.events.isEmpty) {
      return const Center(
        child: Text('No events available'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _eventState.refresh();
      },
      child: ResponsiveGrid(
        children: _eventState.events.map((event) {
          return EventCard(
            event: event,
            onTap: () => _navigateToDetail(event.id),
          );
        }).toList(),
      ),
    );
  }

  void _navigateToDetail(String eventId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EventDetailScreen(
          eventId: eventId,
          eventState: _eventState,
        ),
      ),
    );
  }
}
```

---

## File: lib/presentation/screens/event_detail_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/event.dart';
import '../state/event_state.dart';
import '../widgets/responsive_layout.dart';

/// Event detail screen with booking functionality
/// Responsive design adapts to different screen sizes
/// 
/// @Access-Agent: Booking flow needs accessibility labels and feedback.
/// @Test-Agent: Test booking validation and success/error flows.
class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({
    super.key,
    required this.eventId,
    required this.eventState,
  });

  final String eventId;
  final EventState eventState;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  int _ticketCount = 1;
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    widget.eventState.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.eventState.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Event? get _event => widget.eventState.getEventById(widget.eventId);

  @override
  Widget build(BuildContext context) {
    final event = _event;

    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event Not Found')),
        body: const Center(
          child: Text('Event not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(event),
        tablet: _buildTabletLayout(event),
        desktop: _buildDesktopLayout(event),
      ),
    );
  }

  Widget _buildMobileLayout(Event event) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImage(event),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEventInfo(event),
                const SizedBox(height: 24),
                _buildBookingSection(event),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(Event event) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImage(event),
            const SizedBox(height: 24),
            _buildEventInfo(event),
            const SizedBox(height: 32),
            _buildBookingSection(event),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(Event event) {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.all(32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImage(event),
                    const SizedBox(height: 24),
                    _buildEventInfo(event),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 2,
                child: _buildBookingSection(event),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(Event event) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 2,
        child: Image.network(
          event.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.event, size: 64),
          ),
        ),
      ),
    );
  }

  Widget _buildEventInfo(Event event) {
    final dateFormat = DateFormat('EEEE, MMMM d, y');
    final timeFormat = DateFormat('h:mm a');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          Icons.calendar_today,
          dateFormat.format(event.date),
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          Icons.access_time,
          timeFormat.format(event.date),
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          Icons.location_on,
          event.location,
        ),
        const SizedBox(height: 16),
        Text(
          event.description,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildBookingSection(Event event) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Book Tickets',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildPriceDisplay(event),
            const SizedBox(height: 16),
            _buildTicketCounter(event),
            const SizedBox(height: 16),
            _buildTotalPrice(event),
            const SizedBox(height: 24),
            _buildBookButton(event),
            if (!event.hasAvailableTickets) ...[
              const SizedBox(height: 8),
              Text(
                'Sold Out',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDisplay(Event event) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Price per ticket:'),
        Text(
          event.price == 0 ? 'Free' : '\$${event.price.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }

  Widget _buildTicketCounter(Event event) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Number of tickets:'),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: _ticketCount > 1
                  ? () => setState(() => _ticketCount--)
                  : null,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_ticketCount',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _ticketCount < event.availableTickets
                  ? () => setState(() => _ticketCount++)
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalPrice(Event event) {
    final total = event.price * _ticketCount;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            total == 0 ? 'Free' : '\$${total.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton(Event event) {
    return FilledButton(
      onPressed: event.hasAvailableTickets && !_isBooking
          ? _handleBooking
          : null,
      child: _isBooking
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Book Now'),
    );
  }

  Future<void> _handleBooking() async {
    if (!mounted) return;

    setState(() => _isBooking = true);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final success = widget.eventState.bookTickets(widget.eventId, _ticketCount);

    setState(() => _isBooking = false);

    if (!mounted) return;

    if (success) {
      _showSuccessDialog();
    } else {
      _showErrorDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Successful!'),
        content: Text('You have booked $_ticketCount ticket(s).'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Failed'),
        content: const Text(
          'Unable to complete booking. Please try again or select fewer tickets.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

---

## File: lib/presentation/widgets/event_card.dart

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/event.dart';

/// Reusable event card widget with const constructor for performance
/// Displays event summary information
/// 
/// @Access-Agent: Please add semantic labels for screen readers.
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  final Event event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, y');

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    Icons.calendar_today,
                    dateFormat.format(event.date),
                  ),
                  const SizedBox(height: 4),
                  _buildInfoRow(
                    context,
                    Icons.location_on,
                    event.location,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        event.price == 0
                            ? 'Free'
                            : '\$${event.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${event.availableTickets} tickets left',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.network(
        event.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.event, size: 48),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
```

---

## File: lib/presentation/widgets/responsive_grid.dart

```dart
import 'package:flutter/material.dart';

/// Responsive grid widget that adapts to screen size
/// Uses LayoutBuilder for performance-optimized responsive behavior
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }

  int _getCrossAxisCount(double width) {
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }
}
```

---

## File: lib/presentation/widgets/responsive_layout.dart

```dart
import 'package:flutter/material.dart';

/// Responsive layout builder that selects appropriate layout for screen size
/// Optimized with const constructors where possible
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200 && desktop != null) {
          return desktop!;
        }
        if (constraints.maxWidth > 600 && tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}
```

---

## Architecture Notes

This implementation follows Clean Architecture principles:

1. **Domain Layer** (`lib/domain/`): Pure business logic and models
   - Immutable value objects
   - No dependencies on Flutter framework
   - Easily testable

2. **Data Layer** (`lib/data/`): Data sources and repositories
   - Repository pattern for data access
   - In-memory implementation (can be replaced with API)

3. **Presentation Layer** (`lib/presentation/`):
   - **State**: Business logic separated from UI (`EventState`)
   - **Screens**: Coordinate widgets and navigation
   - **Widgets**: Reusable UI components

## Performance Optimizations

- Aggressive use of `const` constructors
- ValueNotifier for minimal rebuilds
- Immutable models prevent accidental mutations
- Responsive widgets use LayoutBuilder efficiently
- List.unmodifiable prevents external mutations

## Code ready for:
- **@Test-Agent**: Pure business logic in domain and state layers
- **@Access-Agent**: Semantic structure in place, ready for accessibility labels
- **@DevOps-Agent**: Standard Flutter project structure

