import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/trip_model.dart';
import '../../data/repositories/trips_repository.dart';

part 'trips_provider.g.dart';

@riverpod
TripsRepository tripsRepository(TripsRepositoryRef ref) {
  final client = Supabase.instance.client;
  return TripsRepository(client);
}

@riverpod
Stream<List<TripModel>> tripsStream(TripsStreamRef ref) {
  final repository = ref.watch(tripsRepositoryProvider);
  return repository.getTripsStream();
}
