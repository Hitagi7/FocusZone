import 'package:flutter/material.dart';
import '../models/timer_mode.dart';
import '../constants/app_constants.dart';
import 'circular_progress_painter.dart';

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

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString()}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _getTimerText() {
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
      default:
        return 'Time to focus!';
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
            // Circular Progress Indicator
            SizedBox(
              width: AppConstants.circularTimerSize,
              height: AppConstants.circularTimerSize,
              child: CustomPaint(
                painter: CircularProgressPainter(
                  progress: progress,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  progressColor: Colors.white,
                  strokeWidth: AppConstants.progressStrokeWidth,
                ),
              ),
            ),
            // Timer Content
            Container(
              width: AppConstants.circularTimerInnerSize,
              height: AppConstants.circularTimerInnerSize,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formatTime(timeLeft),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppConstants.timerFontSize,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    currentMode == TimerMode.pomodoro
                        ? AppConstants.focusMessage
                        : AppConstants.breakMessage,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
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