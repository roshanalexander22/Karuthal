import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

final ttsServiceProvider = Provider<TTSService>((ref) {
  final service = TTSService();
  ref.onDispose(() => service.dispose());
  return service;
});

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();
  bool _isNativeTtsInitialized = false;

  TTSService() {
    _initNativeTts();
  }

  Future<void> _initNativeTts() async {
    try {
      await _flutterTts.setLanguage('ml-IN');
      await _flutterTts.setSpeechRate(0.85);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _isNativeTtsInitialized = true;
    } catch (e) {
      debugPrint('Native TTS init warning: $e');
    }
  }

  /// Play audio from base64-encoded WAV string using data URI.
  Future<void> playBase64Audio(String base64Wav) async {
    try {
      if (base64Wav.isEmpty) return;
      await stop();
      final uri = Uri.parse('data:audio/wav;base64,$base64Wav');
      await _player.setAudioSource(AudioSource.uri(uri));
      await _player.play();
    } catch (e) {
      debugPrint('AudioPlayer error: $e');
    }
  }

  /// Pause current audio.
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      debugPrint('AudioPlayer pause error: $e');
    }
  }

  /// Resume paused audio.
  Future<void> resume() async {
    try {
      await _player.play();
    } catch (e) {
      debugPrint('AudioPlayer resume error: $e');
    }
  }

  /// Stop current audio playback.
  Future<void> stop() async {
    try {
      await _player.stop();
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
  }

  /// Read text aloud using local native TTS engine (Malayalam fallback).
  Future<void> speak(String text, {String language = 'ml-IN'}) async {
    try {
      await stop();
      if (!_isNativeTtsInitialized) {
        await _initNativeTts();
      }
      await _flutterTts.setLanguage(language);
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Local TTS error: $e');
    }
  }

  void dispose() {
    _player.dispose();
    _flutterTts.stop();
  }
}
