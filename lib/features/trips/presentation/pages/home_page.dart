import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_formatter.dart';
import '../providers/trips_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AquaRuta 🌊'),
      ),
      body: tripsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error al cargar viajes: $error',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
        data: (trips) {
          if (trips.isEmpty) {
            return const Center(
              child: Text('No hay viajes programados por el momento.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];

              Color seatsColor;
              if (trip.availableSeats < 5) {
                seatsColor = Colors.redAccent;
              } else {
                seatsColor = Colors.greenAccent[400] ?? Colors.greenAccent;
              }

              String capitalize(String value) {
                if (value.isEmpty) return value;
                return value[0].toUpperCase() + value.substring(1).toLowerCase();
              }

              final origin = capitalize(trip.origin.replaceAll('_', ' '));
              final destination = capitalize(trip.destination.replaceAll('_', ' '));
              final formattedTime = formatTime(trip.departureTime);
              final status = capitalize(trip.status.replaceAll('_', ' '));

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.directions_boat),
                  title: Text('$origin -> $destination'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Salida: $formattedTime'),
                      Text('Estado: $status'),
                    ],
                  ),
                  trailing: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: seatsColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${trip.availableSeats}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
