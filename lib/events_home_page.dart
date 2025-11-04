import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'event.dart';
import 'event_detail_page.dart';
import 'events_notifier.dart';

/// Home page displaying a responsive list of events.
/// 
/// This widget uses a responsive grid layout that adapts to screen size.
/// Follows Flutter best practices:
/// - Uses const constructors where possible for performance
/// - Separates UI from business logic
/// - Implements responsive design using MediaQuery and crossAxisCount
/// 
/// @Access-Agent: This page needs semantic labels and screen reader support
/// for the event cards and navigation actions.
class EventsHomePage extends StatelessWidget {
  const EventsHomePage({
    required this.eventsNotifier,
    super.key,
  });

  final EventsNotifier eventsNotifier;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          header: true,
          label: 'Eventos Disponibles',
          child: const ExcludeSemantics(
            child: Text('Eventos Disponibles'),
          ),
        ),
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: eventsNotifier,
        builder: (context, _) {
          final events = eventsNotifier.events;

          if (events.isEmpty) {
            return Semantics(
              label: 'Cargando eventos',
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return _ResponsiveEventGrid(
            events: events,
            onEventTap: (event) {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => EventDetailPage(
                    event: event,
                    eventsNotifier: eventsNotifier,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Responsive grid that adapts to screen size
class _ResponsiveEventGrid extends StatelessWidget {
  const _ResponsiveEventGrid({
    required this.events,
    required this.onEventTap,
  });

  final List<Event> events;
  final void Function(Event) onEventTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid columns based on screen width
        final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: events.length,
          itemBuilder: (context, index) {
            return _EventCard(
              event: events[index],
              onTap: () => onEventTap(events[index]),
            );
          },
        );
      },
    );
  }

  /// Calculate optimal number of columns based on screen width
  int _calculateCrossAxisCount(double width) {
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }
}

/// Event card widget displaying event information
/// 
/// @Access-Agent: This card needs semantic labels for images and interactive
/// elements to support screen readers.
class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.onTap,
  });

  final Event event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'es_ES');
    final theme = Theme.of(context);

    final availabilityText = event.isSoldOut 
      ? 'Agotado' 
      : '${event.availableTickets} entradas disponibles';
    
    final semanticValue = 'Fecha: ${dateFormat.format(event.date)}. '
        'Ubicación: ${event.location}. '
        'Precio: €${event.price.toStringAsFixed(2)}. '
        '$availabilityText.';

    return Semantics(
      button: true,
      label: 'Evento: ${event.title}',
      value: semanticValue,
      hint: 'Toca para ver detalles y reservar entradas',
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event image
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  color: theme.colorScheme.surfaceVariant,
                  child: Semantics(
                    image: true,
                    label: 'Imagen del evento ${event.title}',
                    child: ExcludeSemantics(
                      child: Image.network(
                        event.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.event,
                              size: 48,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            // Event details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ExcludeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateFormat.format(event.date),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '€${event.price.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (event.isSoldOut)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'AGOTADO',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onError,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            Text(
                              '${event.availableTickets} disponibles',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
