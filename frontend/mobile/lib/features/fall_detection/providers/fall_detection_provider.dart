import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';
import '../../text_to_speech/services/tts_service.dart';

class FallDetectionState {
  final bool isMonitoring;
  final bool isFallAlertActive;
  final int countdownSeconds;
  final String statusText;
  final bool emergencyDispatched;

  FallDetectionState({
    this.isMonitoring = true,
    this.isFallAlertActive = false,
    this.countdownSeconds = 30,
    this.statusText = 'സെൻസർ നിരീക്ഷണം സജീവം (Monitoring active)',
    this.emergencyDispatched = false,
  });

  FallDetectionState copyWith({
    bool? isMonitoring,
    bool? isFallAlertActive,
    int? countdownSeconds,
    String? statusText,
    bool? emergencyDispatched,
  }) {
    return FallDetectionState(
      isMonitoring: isMonitoring ?? this.isMonitoring,
      isFallAlertActive: isFallAlertActive ?? this.isFallAlertActive,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      statusText: statusText ?? this.statusText,
      emergencyDispatched: emergencyDispatched ?? this.emergencyDispatched,
    );
  }
}

class FallNotifier extends StateNotifier<FallDetectionState> {
  final ApiClient _apiClient;
  final TTSService _ttsService;
  static const _sensorChannel = MethodChannel('sahaayi/sensors');
  Timer? _countdownTimer;

  FallNotifier(this._apiClient, this._ttsService) : super(FallDetectionState()) {
    _initChannel();
  }

  void _initChannel() {
    _sensorChannel.setMethodCallHandler((call) async {
      if (call.method == 'onFallDetected') {
        triggerFallDetectedAlert();
      }
    });
  }

  Future<void> toggleMonitoring() async {
    final nextState = !state.isMonitoring;
    try {
      if (nextState) {
        await _sensorChannel.invokeMethod('startSensorMonitoring');
      } else {
        await _sensorChannel.invokeMethod('stopSensorMonitoring');
      }
    } catch (e) {
      AppLogger.w('Sensor channel invoke warning: $e');
    }

    state = state.copyWith(
      isMonitoring: nextState,
      statusText: nextState ? 'സെൻസർ നിരീക്ഷണം സജീവം (Active)' : 'സെൻസർ നിരീക്ഷണം നിർത്തി (Inactive)',
    );
  }

  void triggerFallDetectedAlert() {
    if (state.isFallAlertActive) return;

    _countdownTimer?.cancel();
    state = state.copyWith(
      isFallAlertActive: true,
      countdownSeconds: 30,
      emergencyDispatched: false,
      statusText: 'വീഴ്ച സംഭവിച്ചതായി കണ്ടെത്തി! (Fall Detected)',
    );

    // Speak alert in Malayalam
    _ttsService.speak('വീഴ്ച സംഭവിച്ചതായി കണ്ടെത്തി. സഹായം ആവശ്യമുണ്ടോ?');

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.countdownSeconds > 1) {
        state = state.copyWith(countdownSeconds: state.countdownSeconds - 1);
      } else {
        timer.cancel();
        confirmAndDispatchSOS(reason: 'FALL_DETECTED_TIMEOUT');
      }
    });
  }

  Future<void> cancelAlert() async {
    _countdownTimer?.cancel();
    state = state.copyWith(
      isFallAlertActive: false,
      countdownSeconds: 30,
      statusText: 'മുന്നറിയിപ്പ് റദ്ദാക്കി - നിങ്ങൾ സുരക്ഷിതനാണ്',
    );

    _ttsService.speak('മുന്നറിയിപ്പ് റദ്ദാക്കി.');

    try {
      await _apiClient.post(
        ApiEndpoints.fallReport,
        data: {
          'confidence_score': 0.85,
          'was_cancelled_by_user': true,
          'sensor_summary': {'action': 'CANCELLED_BY_USER'},
        },
      );
    } catch (e) {
      AppLogger.w('Report cancelled fall warning: $e');
    }
  }

  Future<void> confirmAndDispatchSOS({String reason = 'FALL_CONFIRMED'}) async {
    _countdownTimer?.cancel();
    state = state.copyWith(
      isFallAlertActive: false,
      countdownSeconds: 30,
      emergencyDispatched: true,
      statusText: 'അടിയന്തിര സന്ദേശം ബന്ധുക്കൾക്ക് അയച്ചു! (SOS Sent)',
    );

    _ttsService.speak('അടിയന്തിര സഹായ സന്ദേശം നിങ്ങളുടെ ബന്ധുക്കൾക്ക് അയച്ചു.');

    try {
      // 1. Report fall event
      await _apiClient.post(
        ApiEndpoints.fallReport,
        data: {
          'confidence_score': 0.95,
          'was_cancelled_by_user': false,
          'sensor_summary': {'reason': reason},
        },
      );
      // 2. Trigger SOS broadcast
      await _apiClient.post(
        ApiEndpoints.emergencySos,
        data: {'reason': reason},
      );
    } catch (e) {
      AppLogger.e('Dispatch SOS error: $e');
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}

final fallDetectionProvider = StateNotifierProvider<FallNotifier, FallDetectionState>((ref) {
  final client = ref.watch(apiClientProvider);
  final tts = ref.watch(ttsServiceProvider);
  return FallNotifier(client, tts);
});
