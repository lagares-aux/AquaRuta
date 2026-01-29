import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/trip_model.dart';

class TripsRepository {
  TripsRepository(this._client);

  final SupabaseClient _client;

  Stream<List<TripModel>> getTripsStream() {
    return _client
        .from('trips')
        .stream(primaryKey: ['id'])
        .order('departure_time')
        .map((rows) => rows.map((row) => TripModel.fromJson(row)).toList());
  }

  Future<void> bookTrip({
    required String tripId,
    required String userId,
    int seats = 1,
  }) async {
    try {
      await _client.from('bookings').insert({
        'trip_id': tripId,
        'user_id': userId,
        'passenger_count': seats,
      });
    } catch (e) {
      throw Exception('No se pudo completar la reserva. Intenta de nuevo.');
    }
  }
}
