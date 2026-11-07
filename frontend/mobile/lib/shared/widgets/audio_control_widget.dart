import 'package:flutter/material.dart';

/// Accessible audio playback control bar for TTS, screen reading, and voice notes.
/// Provides large touch target buttons for Play, Pause, Stop, and Speech Speed adjustment.
class AudioControlWidget extends StatelessWidget {
  final bool isPlaying;
  final bool isPaused;
  final double speechRate;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onStop;
  final ValueChanged<double> onSpeedChanged;

  const AudioControlWidget({
    super.key,
    required this.isPlaying,
    required this.isPaused,
    required this.speechRate,
    required this.onPlay,
    required this.onPause,
    required this.onStop,
    required this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Play / Resume
              Semantics(
                label: isPlaying && !isPaused ? 'Pause Reading' : 'Play Reading',
                button: true,
                child: IconButton.filled(
                  iconSize: 36,
                  icon: Icon(isPlaying && !isPaused ? Icons.pause : Icons.play_arrow),
                  onPressed: isPlaying && !isPaused ? onPause : onPlay,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(60, 60),
                  ),
                ),
              ),

              // Stop
              Semantics(
                label: 'Stop Reading',
                button: true,
                child: IconButton.filledTonal(
                  iconSize: 36,
                  icon: const Icon(Icons.stop),
                  onPressed: isPlaying || isPaused ? onStop : null,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(60, 60),
                  ),
                ),
              ),

              // Speed selector button
              PopupMenuButton<double>(
                initialValue: speechRate,
                tooltip: 'വായനാ വേഗത (Speech Speed)',
                onSelected: onSpeedChanged,
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 0.75, child: Text('0.75x (പതുക്കെ - Slow)', style: TextStyle(fontSize: 18))),
                  PopupMenuItem(value: 1.0, child: Text('1.0x (സാധാരണ - Normal)', style: TextStyle(fontSize: 18))),
                  PopupMenuItem(value: 1.25, child: Text('1.25x (വേഗത്തിൽ - Fast)', style: TextStyle(fontSize: 18))),
                ],
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.speed, size: 24),
                      const SizedBox(width: 6),
                      Text(
                        '${speechRate}x',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
