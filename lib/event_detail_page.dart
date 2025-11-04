import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'event.dart';
import 'events_notifier.dart';

/// Event detail page with booking functionality.
/// 
/// This page displays full event information and allows users to book tickets.
/// Uses ValueNotifier for the ticket count to minimize rebuilds - only the
/// ticket counter and price widgets rebuild when the count changes.
/// 
/// @Access-Agent: This page needs semantic labels for the booking form,
/// ticket counter buttons, and confirmation dialogs.
/// @Test-Agent: The booking logic in this widget requires widget tests
/// to verify user interactions and state updates.
class EventDetailPage extends StatefulWidget {
  const EventDetailPage({
    required this.event,
    required this.eventsNotifier,
    super.key,
  });

  final Event event;
  final EventsNotifier eventsNotifier;

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late final ValueNotifier<int> _ticketCountNotifier;

  @override
  void initState() {
    super.initState();
    _ticketCountNotifier = ValueNotifier<int>(1);
  }

  @override
  void dispose() {
    _ticketCountNotifier.dispose();
    super.dispose();
  }

  void _handleBooking() {
    final ticketCount = _ticketCountNotifier.value;
    final event = widget.eventsNotifier.findEventById(widget.event.id);

    if (event == null) {
      _showErrorDialog('Evento no encontrado');
      return;
    }

    if (ticketCount > event.availableTickets) {
      _showErrorDialog(
        'No hay suficientes entradas disponibles. Solo quedan ${event.availableTickets} entradas.',
      );
      return;
    }

    final success = widget.eventsNotifier.bookTickets(
      widget.event.id,
      ticketCount,
    );

    if (success) {
      _showSuccessDialog(ticketCount);
    } else {
      _showErrorDialog('Error al procesar la reserva. Inténtalo de nuevo.');
    }
  }

  void _showSuccessDialog(int ticketCount) {
    showDialog<void>(
      context: context,
      builder: (context) => Semantics(
        namesRoute: true,
        label: 'Reserva Confirmada',
        child: AlertDialog(
          title: const Text('¡Reserva Confirmada!'),
          content: Text(
            'Has reservado $ticketCount ${ticketCount == 1 ? "entrada" : "entradas"} para ${widget.event.title}.',
          ),
          actions: [
            Semantics(
              button: true,
              label: 'Aceptar',
              hint: 'Cierra el diálogo y vuelve a la pantalla de eventos',
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Return to home
                },
                child: const ExcludeSemantics(
                  child: Text('Aceptar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => Semantics(
        namesRoute: true,
        label: 'Error',
        child: AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            Semantics(
              button: true,
              label: 'Aceptar',
              hint: 'Cierra el diálogo de error',
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const ExcludeSemantics(
                  child: Text('Aceptar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: widget.eventsNotifier,
        builder: (context, _) {
          // Get the latest event data in case it was updated
          final currentEvent =
              widget.eventsNotifier.findEventById(widget.event.id) ??
                  widget.event;

          return CustomScrollView(
            slivers: [
              _EventDetailAppBar(event: currentEvent),
              SliverToBoxAdapter(
                child: _EventDetailContent(
                  event: currentEvent,
                  ticketCountNotifier: _ticketCountNotifier,
                  onBook: _handleBooking,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Collapsible app bar with event image
class _EventDetailAppBar extends StatelessWidget {
  const _EventDetailAppBar({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Semantics(
          header: true,
          label: event.title,
          child: ExcludeSemantics(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                event.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        background: Semantics(
          image: true,
          label: 'Imagen del evento ${event.title}',
          child: ExcludeSemantics(
            child: Image.network(
              event.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Icon(
                    Icons.event,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Main content of the event detail page
class _EventDetailContent extends StatelessWidget {
  const _EventDetailContent({
    required this.event,
    required this.ticketCountNotifier,
    required this.onBook,
  });

  final Event event;
  final ValueNotifier<int> ticketCountNotifier;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'es_ES');
    final timeFormat = DateFormat('HH:mm', 'es_ES');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event info cards
          _InfoCard(
            icon: Icons.calendar_today,
            title: 'Fecha',
            content: dateFormat.format(event.date),
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.access_time,
            title: 'Hora',
            content: timeFormat.format(event.date),
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.location_on,
            title: 'Ubicación',
            content: event.location,
          ),
          const SizedBox(height: 24),

          // Description
          Text(
            'Descripción',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event.description,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          // Availability info
          _AvailabilityInfo(event: event),
          const SizedBox(height: 32),

          // Booking section (only if not sold out)
          if (!event.isSoldOut) ...[
            Text(
              'Reservar Entradas',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _TicketCounter(
              ticketCountNotifier: ticketCountNotifier,
              maxTickets: event.availableTickets,
            ),
            const SizedBox(height: 16),
            _TotalPrice(
              ticketCountNotifier: ticketCountNotifier,
              pricePerTicket: event.price,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Semantics(
                button: true,
                label: 'Confirmar Reserva',
                hint: 'Confirma la reserva de las entradas seleccionadas',
                child: FilledButton(
                  onPressed: onBook,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const ExcludeSemantics(
                    child: Text(
                      'Confirmar Reserva',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            Semantics(
              label: 'Evento Agotado. Lo sentimos, no quedan entradas disponibles.',
              child: ExcludeSemantics(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Evento Agotado',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lo sentimos, no quedan entradas disponibles.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// Info card displaying event details
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  final IconData icon;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: '$title: $content',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      content,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget displaying ticket availability
class _AvailabilityInfo extends StatelessWidget {
  const _AvailabilityInfo({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availabilityPercentage =
        (event.availableTickets / event.maxCapacity * 100).round();

    return Semantics(
      label: 'Disponibilidad: ${event.availableTickets} de ${event.maxCapacity} entradas disponibles, $availabilityPercentage por ciento',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Disponibilidad',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${event.availableTickets} / ${event.maxCapacity}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: event.availableTickets / event.maxCapacity,
                  minHeight: 8,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$availabilityPercentage% de entradas disponibles',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ticket counter widget with increment/decrement buttons
/// 
/// Uses ValueNotifier to minimize rebuilds - only this widget and
/// the total price widget rebuild when the count changes.
class _TicketCounter extends StatelessWidget {
  const _TicketCounter({
    required this.ticketCountNotifier,
    required this.maxTickets,
  });

  final ValueNotifier<int> ticketCountNotifier;
  final int maxTickets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Semantics(
            label: 'Número de entradas',
            child: const ExcludeSemantics(
              child: Text(
                'Número de entradas',
                style: null,
              ),
            ),
          ),
          Row(
            children: [
              Semantics(
                button: true,
                label: 'Disminuir número de entradas',
                enabled: ticketCountNotifier.value > 1,
                child: IconButton(
                  onPressed: () {
                    if (ticketCountNotifier.value > 1) {
                      ticketCountNotifier.value--;
                    }
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                  color: theme.colorScheme.primary,
                ),
              ),
              ValueListenableBuilder<int>(
                valueListenable: ticketCountNotifier,
                builder: (context, count, _) {
                  return Semantics(
                    label: '$count entradas seleccionadas',
                    liveRegion: true,
                    child: ExcludeSemantics(
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 40),
                        child: Text(
                          count.toString(),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
              Semantics(
                button: true,
                label: 'Aumentar número de entradas',
                enabled: ticketCountNotifier.value < maxTickets,
                child: IconButton(
                  onPressed: () {
                    if (ticketCountNotifier.value < maxTickets) {
                      ticketCountNotifier.value++;
                    }
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Total price display widget
/// 
/// Uses ValueListenableBuilder to rebuild only when ticket count changes.
class _TotalPrice extends StatelessWidget {
  const _TotalPrice({
    required this.ticketCountNotifier,
    required this.pricePerTicket,
  });

  final ValueNotifier<int> ticketCountNotifier;
  final double pricePerTicket;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Semantics(
            label: 'Total a pagar',
            child: const ExcludeSemantics(
              child: Text(
                'Total',
                style: null,
              ),
            ),
          ),
          ValueListenableBuilder<int>(
            valueListenable: ticketCountNotifier,
            builder: (context, count, _) {
              final total = count * pricePerTicket;
              return Semantics(
                label: '€${total.toStringAsFixed(2)}',
                liveRegion: true,
                child: ExcludeSemantics(
                  child: Text(
                    '€${total.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
