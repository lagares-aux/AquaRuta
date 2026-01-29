class TripModel {
  final String id;
  final String boatId;
  final String origin;
  final String destination;
  final DateTime departureTime;
  final String status;
  final int availableSeats;
  final String? boatName;

  const TripModel({
    required this.id,
    required this.boatId,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.status,
    required this.availableSeats,
    this.boatName,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    // Campos obligatorios básicos: se asume que vienen siempre desde Supabase.
    final id = json['id']?.toString() ?? '';
    final boatId = json['boat_id']?.toString() ?? '';
    final origin = json['origin']?.toString() ?? '';
    final destination = json['destination']?.toString() ?? '';

    // departure_time: puede venir como String o ya como DateTime según el cliente.
    final rawDepartureTime = json['departure_time'];
    final DateTime departureTime;
    if (rawDepartureTime is String) {
      departureTime = DateTime.tryParse(rawDepartureTime) ?? DateTime.now();
    } else if (rawDepartureTime is DateTime) {
      departureTime = rawDepartureTime;
    } else {
      departureTime = DateTime.now();
    }

    // status con valor por defecto.
    final status = (json['status'] ?? 'scheduled').toString();

    // available_seats con valor por defecto 0 si viene nulo o en formato extraño.
    final dynamic rawSeats = json['available_seats'];
    final int availableSeats;
    if (rawSeats is num) {
      availableSeats = rawSeats.toInt();
    } else if (rawSeats is String) {
      availableSeats = int.tryParse(rawSeats) ?? 0;
    } else {
      availableSeats = 0;
    }

    // boat_name: no viene en la tabla trips básica; usar valor por defecto si falta.
    final String boatName =
        (json.containsKey('boat_name') && json['boat_name'] != null)
            ? json['boat_name'].toString()
            : 'Lancha';

    return TripModel(
      id: id,
      boatId: boatId,
      origin: origin,
      destination: destination,
      departureTime: departureTime,
      status: status,
      availableSeats: availableSeats,
      boatName: boatName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'boat_id': boatId,
      'origin': origin,
      'destination': destination,
      'departure_time': departureTime.toIso8601String(),
      'status': status,
      'available_seats': availableSeats,
      if (boatName != null) 'boat_name': boatName,
    };
  }
}
