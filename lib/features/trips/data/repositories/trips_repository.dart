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
}
