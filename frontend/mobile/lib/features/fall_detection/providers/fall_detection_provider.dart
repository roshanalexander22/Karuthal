import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/fall_repository.dart';

class FallDetectionState {
  final bool isMonitoring;
  final String sensitivity;
  final bool countdownActive;
  final int remainingSeconds;
  final String? currentEventId;
  final bool sosDispatched;

  const FallDetectionState({
    this.isMonitoring = true,
    this.sensitivity = 'MEDIUM',
    this.countdownActive = false,
    this.remainingSeconds = 30,
    this.currentEventId,
    this.sosDispatched = false,
  });

  FallDetectionState copyWith({
    bool? isMonitoring,
    String? sensitivity,
    bool? countdownActive,
    int? remainingSeconds,
    String? currentEventId,
    bool? sosDispatched,
  }) {
    return FallDetectionState(
      isMonitoring: isMonitoring ?? this.isMonitoring,
      sensitivity: sensitivity ?? this.sensitivity,
      countdownActive: countdownActive ?? this.countdownActive,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      currentEventId: currentEventId ?? this.currentEventId,
      sosDispatched: sosDispatched ?? this.sosDispatched,
    );
  }
}

class FallNotifier extends StateNotifier<FallDetectionState> {
  final FallRepository _repository;
  Timer? _countdownTimer;

  FallNotifier(this._repository) : super(const FallDetectionState());

  void toggle() {
    state = state.copyWith(isMonitoring: !state.isMonitoring);
    _repository.updateSettings({'is_enabled': state.isMonitoring});
  }

  void setSensitivity(String sensitivity) {
    state = state.copyWith(sensitivity: sensitivity);
    _repository.updateSettings({'sensitivity': sensitivity});
  }

  /// Trigger simulated or sensor-detected fall event
  void onFallDetected({String? eventId}) {
    if (!state.isMonitoring) return;

    _countdownTimer?.cancel();
    state = state.copyWith(
      countdownActive: true,
      remainingSeconds: 30,
      currentEventId:
          eventId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      sosDispatched: false,
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 1) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        timer.cancel();
        // Time expired! Dispatch automatic emergency SOS!
        _dispatchAutomaticSOS();
      }
    });
  }

  /// Senior confirms they are safe -> cancels countdown and marks false alarm
  Future<void> cancelCountdownAndMarkSafe() async {
    _countdownTimer?.cancel();
    final eventId = state.currentEventId;
    state = state.copyWith(
      countdownActive: false,
      remainingSeconds: 30,
      sosDispatched: false,
    );

    if (eventId != null) {
      await _repository.cancelFallEvent(eventId);
    }
  }

  Future<void> _dispatchAutomaticSOS() async {
    state = state.copyWith(
      countdownActive: false,
      sosDispatched: true,
    );
    try {
      await _repository.reportFall(
        confidence: 0.96,
        wasCancelledByUser: false,
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}

final fallDetectionProvider =
    StateNotifierProvider<FallNotifier, FallDetectionState>((ref) {
  final repo = ref.watch(fallRepositoryProvider);
  return FallNotifier(repo);
});
