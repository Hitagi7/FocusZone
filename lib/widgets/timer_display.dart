import 'package:flutter/material.dart';
import '../models/timer_mode.dart';
import '../constants/app_constants.dart';
import 'circular_progress_painter.dart';

// Displays the timer with circular progress indicator
class TimerDisplay extends StatelessWidget {
  final int timeLeft;
  final TimerMode currentMode;
  final double progress;
  final VoidCallback onToggleTimer;
  final bool isRunning;

  const TimerDisplay({
    Key? key,
    required this.timeLeft,
    required this.currentMode,
    required this.progress,
    required this.onToggleTimer,
    required this.isRunning,
  }) : super(key: key);

  // Convert seconds to MM:SS format
  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString()}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Get the message to display below the timer
  String _getTimerMessage() {
    if (!isRunning) {
      return 'Tap to start timer';
    }

    switch (currentMode) {
      case TimerMode.pomodoro:
        return 'Time to focus!';
      case TimerMode.shortBreak:
        return 'Time for a short break!';
      case TimerMode.longBreak:
        return 'Time for a long break!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggleTimer,
      child: Container(
        width: AppConstants.circularTimerSize,
        height: AppConstants.circularTimerSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circular progress indicator
            SizedBox(
              width: AppConstants.circularTimerSize,
              height: AppConstants.circularTimerSize,
              child: CustomPaint(
                painter: CircularProgressPainter(
                  progress: progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  progressColor: Colors.white,
                  strokeWidth: AppConstants.progressStrokeWidth,
                ),
              ),
            ),
            
            // Timer content (time and message)
            Container(
              width: AppConstants.circularTimerInnerSize,
              height: AppConstants.circularTimerInnerSize,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Time display
                  Text(
                    formatTime(timeLeft),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppConstants.timerFontSize,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Message below timer
                  Text(
                    _getTimerMessage(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}