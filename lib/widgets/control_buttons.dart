import 'package:flutter/material.dart';
import '../models/timer_mode.dart';
import '../models/timer_config.dart';
import '../constants/app_constants.dart';

class ControlButtons extends StatelessWidget {
  final TimerMode currentMode;
  final VoidCallback onResetTimer;
  final VoidCallback onSkipToNext;

  const ControlButtons({
    Key? key,
    required this.currentMode,
    required this.onResetTimer,
    required this.onSkipToNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = TimerConfigManager.getConfig(currentMode);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reset button
        IconButton(
          onPressed: onResetTimer,
          icon: Icon(
            Icons.refresh,
            color: Colors.white,
            size: 36,
          ),
        ),

        SizedBox(width: 20),

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