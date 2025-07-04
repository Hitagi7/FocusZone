import 'package:flutter/material.dart';
import '../models/timer_mode.dart';
import '../models/timer_config.dart';
import '../constants/app_constants.dart';

class ControlButtons extends StatelessWidget {
  final bool isRunning;
  final TimerMode currentMode;
  final VoidCallback onToggleTimer;
  final VoidCallback onResetTimer;
  final VoidCallback onSkipToNext;

  const ControlButtons({
    Key? key,
    required this.isRunning,
    required this.currentMode,
    required this.onToggleTimer,
    required this.onResetTimer,
    required this.onSkipToNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = TimerConfigManager.getConfig(currentMode);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Start/Stop button
        ElevatedButton(
          onPressed: onToggleTimer,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: config.color,
            padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            elevation: 4,
          ),
          child: Text(
            isRunning ? AppConstants.pauseButtonText : AppConstants.startButtonText,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        SizedBox(width: 20),

        // Reset button
        IconButton(
          onPressed: onResetTimer,
          icon: Icon(
            Icons.refresh,
            color: Colors.white,
            size: 36,
          ),
        ),

        SizedBox(width: 10),

        // Skip button
        IconButton(
          onPressed: onSkipToNext,
          icon: Icon(
            Icons.skip_next,
            color: Colors.white,
            size: 48,
          ),
        ),
      ],
    );
  }
}