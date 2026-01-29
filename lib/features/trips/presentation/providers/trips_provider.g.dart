// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trips_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tripsRepositoryHash() => r'c45373df04ad3b12194eca0eefd38d156d3eecad';

/// See also [tripsRepository].
@ProviderFor(tripsRepository)
final tripsRepositoryProvider = AutoDisposeProvider<TripsRepository>.internal(
  tripsRepository,
  name: r'tripsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tripsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TripsRepositoryRef = AutoDisposeProviderRef<TripsRepository>;
String _$tripsStreamHash() => r'4053431739431e254efd44332181413c798049e3';

/// See also [tripsStream].
@ProviderFor(tripsStream)
final tripsStreamProvider = AutoDisposeStreamProvider<List<TripModel>>.internal(
  tripsStream,
  name: r'tripsStreamProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tripsStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TripsStreamRef = AutoDisposeStreamProviderRef<List<TripModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
