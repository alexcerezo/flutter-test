/// Domain model representing a Booking.
/// 
/// This model is immutable for thread-safety and uses const constructor
/// for performance optimization.
/// 
/// @Test-Agent: This model requires unit tests for validation logic.
class Booking {
  const Booking({
    required this.id,
    required this.eventId,
    required this.numberOfTickets,
    required this.totalPrice,
    required this.bookingDate,
  });

  final String id;
  final String eventId;
  final int numberOfTickets;
  final double totalPrice;
  final DateTime bookingDate;
}
