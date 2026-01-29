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

@riverpod
class BookingController extends _$BookingController {
  @override
  FutureOr<void> build() async {
    // Estado inicial sin operación en curso
  }

  Future<void> bookTrip({
    required String tripId,
    required String userId,
    int seats = 1,
  }) async {
    state = const AsyncLoading();
    final repository = ref.read(tripsRepositoryProvider);

    state = await AsyncValue.guard(() async {
      await repository.bookTrip(
        tripId: tripId,
        userId: userId,
        seats: seats,
      );
    });
  }
}
