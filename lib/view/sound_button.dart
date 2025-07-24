import 'package:flutter/material.dart';
import '../controller/audio_controller.dart';
import 'ambient_sound_selector.dart';

class SoundButton extends StatelessWidget {
  final AudioController audioController;

  const SoundButton({super.key, required this.audioController});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: audioController,
      builder: (context, child) {
        final hasSound = audioController.isPlaying;

        return Opacity(
          opacity: hasSound ? 1 : 0.5,
          child: FloatingActionButton(
            onPressed: () => _showSoundSelector(context),
            backgroundColor: hasSound ? Colors.blue : Colors.grey[600],
            foregroundColor: Colors.white,
            elevation: 8,
            child: Icon(
              hasSound ? Icons.volume_up : Icons.volume_off,
              size: 24,
            ),
          ),
        );
      },
    );
  }

  void _showSoundSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.8,
        builder: (context, scrollController) => AmbientSoundSelector(
          audioController: audioController,
          onSoundSelected: () {
            // Optional callback when sound is selected
          },
        ),
      ),
    );
  }
}
