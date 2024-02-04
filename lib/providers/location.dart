import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/location.dart';

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) => LocationNotifier(),
);

class LocationState {
  final Location? origin;
  final Location? destination;

  LocationState({this.origin, this.destination});

  LocationState copyWith({Location? origin, Location? destination}) {
    return LocationState(
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(LocationState());

  void updateOrigin(Location newOrigin) {
    state = state.copyWith(origin: newOrigin);
  }

  void updateDestination(Location newDestination) {
    state = state.copyWith(destination: newDestination);
  }
}
