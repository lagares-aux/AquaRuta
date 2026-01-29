import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:aquaruta/core/utils/date_formatter.dart';
import '../../data/models/trip_model.dart';
import '../providers/trips_provider.dart';

class TripDetailsPage extends ConsumerWidget {
  const TripDetailsPage({super.key, required this.trip});

  final TripModel trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingControllerProvider);
    final isLoading = bookingState.isLoading;
    final colorScheme = Theme.of(context).colorScheme;

    Future<void> onBook() async {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Debes iniciar sesión para reservar.'),
            backgroundColor: colorScheme.error,
          ),
        );
        return;
      }

      await ref
          .read(bookingControllerProvider.notifier)
          .bookTrip(tripId: trip.id, userId: user.id);

      final state = ref.read(bookingControllerProvider);
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al reservar: ${state.error}'),
            backgroundColor: colorScheme.error,
          ),
        );
        return;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Reserva exitosa!'),
            backgroundColor: colorScheme.secondary,
          ),
        );
        context.pop();
      }
    }

    final origin = trip.origin.replaceAll('_', ' ');
    final destination = trip.destination.replaceAll('_', ' ');
    final formattedTime = formatTime(trip.departureTime);
    final boatName = trip.boatName ?? 'Lancha';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del viaje'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$origin → $destination',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.access_time),
                        const SizedBox(width: 8),
                        Text('Hora de salida: $formattedTime'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.directions_boat),
                        const SizedBox(width: 8),
                        Text('Lancha: $boatName'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.event_seat),
                        const SizedBox(width: 8),
                        Text('Cupos disponibles: ${trip.availableSeats}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed:
                    isLoading || trip.availableSeats == 0 ? null : onBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        trip.availableSeats == 0
                            ? 'Sin cupos disponibles'
                            : 'Reservar Cupo',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
