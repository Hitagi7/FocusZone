import 'package:flutter/material.dart';
import '../../controller/audio_controller.dart';

class AmbientSoundSelector extends StatelessWidget {
  final AudioController audioController;
  final VoidCallback? onSoundSelected;

  const AmbientSoundSelector({
    Key? key,
    required this.audioController,
    this.onSoundSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Placeholder UI for sound selection
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ambient Sound Selector',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          // Add your sound selection UI here
          ElevatedButton(
            onPressed: () {
              onSoundSelected?.call();
              Navigator.of(context).pop();
            },
            child: Text('Select Sound (placeholder)'),
          ),
        ],
      ),
    );
  }
}
