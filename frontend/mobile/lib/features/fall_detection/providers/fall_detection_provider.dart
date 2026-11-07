import 'package:flutter_riverpod/flutter_riverpod.dart';

class FallDetectionState {
  final bool isMonitoring;
  FallDetectionState({this.isMonitoring = true});
}

final fallDetectionProvider =
    StateNotifierProvider<FallNotifier, FallDetectionState>(
        (ref) => FallNotifier());

class FallNotifier extends StateNotifier<FallDetectionState> {
  FallNotifier() : super(FallDetectionState());
  void toggle() =>
      state = FallDetectionState(isMonitoring: !state.isMonitoring);
}
