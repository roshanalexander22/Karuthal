import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TTSState { stopped, playing, paused }

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _tts = FlutterTts();
  TTSState _state = TTSState.stopped;
  double _speechRate = 0.85; // Elder-friendly pace
  String _currentLanguage = 'ml-IN';
  final List<String> _speechQueue = [];
  bool _isQueueProcessing = false;

  final ValueNotifier<TTSState> stateNotifier = ValueNotifier<TTSState>(TTSState.stopped);

  Future<void> init() async {
    try {
      final languages = await _tts.getLanguages;
      if (languages is List && languages.contains('ml-IN')) {
        _currentLanguage = 'ml-IN';
      } else if (languages is List && languages.contains('ml')) {
        _currentLanguage = 'ml';
      } else {
        _currentLanguage = 'en-IN'; // Fallback to Indian English
      }

      await _tts.setLanguage(_currentLanguage);
      await _tts.setSpeechRate(_speechRate);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      _tts.setStartHandler(() {
        _state = TTSState.playing;
        stateNotifier.value = _state;
      });

      _tts.setCompletionHandler(() {
        _state = TTSState.stopped;
        stateNotifier.value = _state;
        _processNextInQueue();
      });

      _tts.setCancelHandler(() {
        _state = TTSState.stopped;
        stateNotifier.value = _state;
      });

      _tts.setPauseHandler(() {
        _state = TTSState.paused;
        stateNotifier.value = _state;
      });

      _tts.setContinueHandler(() {
        _state = TTSState.playing;
        stateNotifier.value = _state;
      });

      _tts.setErrorHandler((dynamic msg) {
        debugPrint('TTS Error: $msg');
        _state = TTSState.stopped;
        stateNotifier.value = _state;
        _processNextInQueue();
      });
    } catch (e) {
      debugPrint('TTS initialization warning: $e');
    }
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.5, 1.5);
    await _tts.setSpeechRate(_speechRate);
  }

  Future<void> speak(String text, {bool clearQueue = true}) async {
    if (clearQueue) {
      await stop();
    }

    if (text.trim().isEmpty) return;

    // For long texts, split by sentences to prevent audio engine dropouts
    final sentences = _splitIntoSentences(text);
    _speechQueue.addAll(sentences);

    if (!_isQueueProcessing) {
      _processNextInQueue();
    }
  }

  void _processNextInQueue() async {
    if (_speechQueue.isEmpty) {
      _isQueueProcessing = false;
      _state = TTSState.stopped;
      stateNotifier.value = _state;
      return;
    }

    _isQueueProcessing = true;
    final nextSentence = _speechQueue.removeAt(0);
    _state = TTSState.playing;
    stateNotifier.value = _state;

    await _tts.speak(nextSentence);
  }

  List<String> _splitIntoSentences(String text) {
    final regex = RegExp(r'(?<=[.!?\n])\s+');
    final rawSentences = text.split(regex);
    final results = <String>[];
    for (final s in rawSentences) {
      final trimmed = s.trim();
      if (trimmed.isNotEmpty) {
        results.add(trimmed);
      }
    }
    return results.isEmpty ? [text] : results;
  }

  Future<void> pause() async {
    await _tts.pause();
    _state = TTSState.paused;
    stateNotifier.value = _state;
  }

  Future<void> resume() async {
    if (_state == TTSState.paused) {
      _processNextInQueue();
    }
  }

  Future<void> stop() async {
    _speechQueue.clear();
    _isQueueProcessing = false;
    await _tts.stop();
    _state = TTSState.stopped;
    stateNotifier.value = _state;
  }

  bool get isSpeaking => _state == TTSState.playing;
  bool get isPaused => _state == TTSState.paused;
}

final ttsServiceProvider = Provider<TTSService>((ref) {
  final service = TTSService();
  service.init();
  return service;
});
