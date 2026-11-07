import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../utils/logger.dart';

final ttsServiceProvider = Provider<TTSService>((ref) {
  final service = TTSService();
  ref.onDispose(() => service.dispose());
  return service;
});

class TTSService {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  double _speechRate = 0.85;

  bool get isPlaying => _isPlaying;
  double get speechRate => _speechRate;

  TTSService() {
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing && state.processingState != ProcessingState.completed;
    });
  }

  void setSpeechRate(double rate) {
    _speechRate = rate.clamp(0.5, 1.5);
    _player.setSpeed(_speechRate);
  }

  /// Play audio from base64-encoded WAV string using data URI.
  Future<void> playBase64Audio(String base64Wav) async {
    try {
      if (base64Wav.isEmpty) return;
      await stop();
      final uri = Uri.parse('data:audio/wav;base64,$base64Wav');
      await _player.setAudioSource(AudioSource.uri(uri));
      await _player.setSpeed(_speechRate);
      await _player.play();
    } catch (e) {
      AppLogger.e('TTS playback error: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      AppLogger.e('TTS pause error: $e');
    }
  }

  Future<void> resume() async {
    try {
      await _player.play();
    } catch (e) {
      AppLogger.e('TTS resume error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (e) {
      AppLogger.e('TTS stop error: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
