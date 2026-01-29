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
    return TripModel(
      id: json['id'] as String,
      boatId: json['boat_id'] as String,
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      departureTime: DateTime.parse(json['departure_time'] as String),
      status: json['status'] as String,
      availableSeats: (json['available_seats'] as num).toInt(),
      boatName: json['boat_name'] as String?,
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
