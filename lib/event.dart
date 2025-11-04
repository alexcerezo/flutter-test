/// Domain model representing an Event.
/// 
/// This model is immutable and uses const constructor for performance.
/// All fields are final to ensure immutability.
/// 
/// @Test-Agent: This model requires unit tests for validation logic
/// and edge cases (e.g., maxCapacity bounds, date validation).
class Event {
  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.imageUrl,
    required this.price,
    required this.maxCapacity,
    this.bookedTickets = 0,
  });

  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String imageUrl;
  final double price;
  final int maxCapacity;
  final int bookedTickets;

  /// Returns the number of available tickets
  int get availableTickets => maxCapacity - bookedTickets;

  /// Returns true if the event is sold out
  bool get isSoldOut => availableTickets <= 0;

  /// Creates a copy of this event with updated booked tickets
  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? location,
    String? imageUrl,
    double? price,
    int? maxCapacity,
    int? bookedTickets,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      bookedTickets: bookedTickets ?? this.bookedTickets,
    );
  }
}
