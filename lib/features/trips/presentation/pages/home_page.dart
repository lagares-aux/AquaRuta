import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Asegúrate de tener intl en pubspec.yaml
import 'package:google_fonts/google_fonts.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import '../../data/models/trip_model.dart';
import '../providers/trips_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error al cargar perfil: $error')),
      ),
      data: (userProfile) {
        final tripsAsync = ref.watch(tripsStreamProvider);
        final isOperator = userProfile.role == 'operator';

        String initialsFromName(String name) {
          if (name.trim().isEmpty) return '?';
          final parts = name.trim().split(' ');
          if (parts.length == 1) {
            return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '?';
          }
          return (parts[0].isNotEmpty ? parts[0][0] : '') +
              (parts[1].isNotEmpty ? parts[1][0] : '');
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA), // Fondo gris muy claro
          appBar: AppBar(
            title: Text(
              'AquaRuta 🌊',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Text('Mi Perfil'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userProfile.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(userProfile.email),
                            ],
                          ),
                          actions: [
                            TextButton.icon(
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await ref
                                    .read(authRepositoryProvider)
                                    .signOut();
                              },
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.red,
                              ),
                              label: const Text(
                                'Cerrar sesión',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFF006994),
                    child: Text(
                      initialsFromName(userProfile.fullName).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: tripsAsync.when(
            data: (trips) {
              if (trips.isEmpty) {
                return const Center(child: Text("No hay viajes programados hoy."));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: trips.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final trip = trips[index];
                  return TripCard(
                    trip: trip,
                    isOperator: isOperator,
                  );
                },
              );
            },
            error: (err, stack) => Center(child: Text('Error: $err')),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
          floatingActionButton: isOperator
              ? FloatingActionButton.extended(
                  onPressed: () {
                    // TODO: Implementar creación de viaje
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Crear viaje (Próximamente)')),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo Viaje'),
                )
              : null,
        );
      },
    );
  }
}

class TripCard extends StatelessWidget {
  final TripModel trip;
  final bool isOperator;

  const TripCard({
    super.key,
    required this.trip,
    required this.isOperator,
  });

  // Helper para el color del semáforo
  Color _getSeatsColor(int seats) {
    if (seats == 0) return Colors.redAccent;
    if (seats <= 5) return Colors.orangeAccent;
    if (seats <= 10) return Colors.amber; // Amarillo oscuro
    return const Color(0xFF00C853); // Verde fuerte
  }

  // Helper para formatear hora
  String _formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos llegada estimada (30 min viaje promedio)
    final arrivalTime = trip.departureTime.add(const Duration(minutes: 30));
    final seatsColor = _getSeatsColor(trip.availableSeats);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Encabezado: Perfil Lanchero y Ruta
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Foto Lanchero (Placeholder)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                    image: const DecorationImage(
                      image: NetworkImage('https://i.pravatar.cc/150?img=11'), // Foto random
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Información de Ruta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // Capitalizar origen y destino
                        '${_capitalize(trip.origin)} ➝ ${_capitalize(trip.destination)}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3436),
                        ),
                      ),
                      Text(
                        trip.boatName ?? 'Lancha Rápida',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Estado (Badge)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF90CAF9)),
                  ),
                  child: Text(
                    trip.status.toUpperCase(), // Ej: SCHEDULED
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Línea divisoria punteada o sólida suave
          Divider(height: 1, color: Colors.grey[100]),

          // 2. Horarios (Salida -> Llegada)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _TimeColumn(
                  label: 'Salida',
                  time: _formatTime(trip.departureTime),
                  icon: Icons.departure_board,
                  color: const Color(0xFF006994),
                ),
                const Icon(Icons.arrow_forward_rounded, color: Colors.grey, size: 20),
                _TimeColumn(
                  label: 'Llegada',
                  time: _formatTime(arrivalTime),
                  icon: Icons.directions_boat_filled,
                  color: const Color(0xFF40E0D0),
                ),
              ],
            ),
          ),

          // 3. Footer: Cupos y Acciones
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Indicador de Cupos (Semáforo)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: seatsColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: seatsColor.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.people_alt_rounded, size: 18, color: seatsColor),
                      const SizedBox(width: 6),
                      Text(
                        '${trip.availableSeats} Cupos',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: seatsColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Acciones (Depende del Rol)
                if (isOperator)
                  // Modo Lanchero: Editar Cupos
                  Row(
                    children: [
                      _CircleBtn(
                        icon: Icons.remove,
                        color: Colors.redAccent,
                        onTap: () {
                          // TODO: Lógica restar cupo
                        },
                      ),
                      const SizedBox(width: 10),
                      _CircleBtn(
                        icon: Icons.add,
                        color: Colors.green,
                        onTap: () {
                          // TODO: Lógica sumar cupo
                        },
                      ),
                    ],
                  )
                else
                  // Modo Pasajero: Botón Reservar
                  ElevatedButton(
                    onPressed: trip.availableSeats > 0
                        ? () => context.push('/trip-details', extra: trip)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006994),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      elevation: 0,
                    ),
                    child: const Text('Reservar'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
}

// Widget auxiliar para las columnas de hora
class _TimeColumn extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;
  final Color color;

  const _TimeColumn({
    required this.label,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

// Widget auxiliar para botones redondos del lanchero
class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: color.withOpacity(0.3)),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}