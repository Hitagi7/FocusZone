import 'package:flutter/material.dart';

// Control buttons for timer (reset and skip) - only visible when timer is running
class ControlButtons extends StatelessWidget {
  final VoidCallback onResetTimer;
  final VoidCallback onSkipToNext;
  final bool isRunning;

  const ControlButtons({
    super.key,
    required this.onResetTimer,
    required this.onSkipToNext,
    required this.isRunning,
  });

  @override
  Widget build(BuildContext context) {
    // Only show buttons when timer is running
    if (!isRunning) {
      return SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reset button - resets timer to full duration
        Padding(
          padding: EdgeInsets.zero,
          child: IconButton(
            onPressed: onResetTimer,
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),

        const SizedBox(width: 20),

        // Skip button - skips to next timer mode
        Padding(
          padding: EdgeInsets.zero,
          child: IconButton(
            onPressed: onSkipToNext,
            icon: Icon(
              Icons.skip_next,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
      ],
    );
  }
}