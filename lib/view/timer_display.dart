import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/timer_mode.dart';
import 'constants/app_constants.dart';
import 'circular_progress_painter.dart';

// Displays the timer with circular progress indicator
class TimerDisplay extends StatefulWidget {
  final int timeLeft;
  final TimerMode currentMode;
  final double progress;
  final VoidCallback onToggleTimer;
  final bool isRunning;

  const TimerDisplay({
    super.key,
    required this.timeLeft,
    required this.currentMode,
    required this.progress,
    required this.onToggleTimer,
    required this.isRunning,
  });

  @override
  State<TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay> {
  String _timerFormat = 'minutes';

  @override
  void initState() {
    super.initState();
    _loadTimerFormat();
  }

  @override
  void didUpdateWidget(TimerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload timer format when widget updates
    _loadTimerFormat();
  }

  Future<void> _loadTimerFormat() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _timerFormat = prefs.getString('timerFormat') ?? 'minutes';
    });
  }

  // Convert seconds to MM:SS or HH:MM format based on user preference
  String formatTime(int seconds) {
    // If less than 1 minute left, always show minutes:seconds format
    if (seconds < 60) {
      int minutes = seconds ~/ 60;
      int remainingSeconds = seconds % 60;
      return '${minutes.toString()}:${remainingSeconds.toString().padLeft(2, '0')}';
    }

    if (_timerFormat == 'hours') {
      int totalMinutes = seconds ~/ 60;
      int hours = totalMinutes ~/ 60;
      int minutes = totalMinutes % 60;

      // Always show hours format when user selected hours
      return '${hours}:${minutes.toString().padLeft(2, '0')}';
    } else {
      // Default minutes format
      int minutes = seconds ~/ 60;
      int remainingSeconds = seconds % 60;
      return '${minutes.toString()}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }

  // Get the message to display below the timer
  String _getTimerMessage() {
    if (!widget.isRunning) {
      return 'Tap to start timer';
    }

    switch (widget.currentMode) {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final timerDiameter = screenWidth * 0.60;
    final timerInnerDiameter = timerDiameter * 0.85;
    final timerFontSize = timerDiameter * 0.22;
    return GestureDetector(
      onTap: widget.onToggleTimer,
      child: SizedBox(
        width: timerDiameter,
        height: timerDiameter,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circular progress indicator
            SizedBox(
              width: timerDiameter,
              height: timerDiameter,
              child: CustomPaint(
                painter: CircularProgressPainter(
                  progress: widget.progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  progressColor: Colors.white,
                  strokeWidth: AppConstants.progressStrokeWidth,
                ),
              ),
            ),
            // Timer content (time and message)
            AnimatedScale(
              scale: widget.isRunning ? 0.92 : 1.0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: Container(
                width: timerInnerDiameter,
                height: timerInnerDiameter,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Time display
                    Text(
                      formatTime(widget.timeLeft),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: timerFontSize,
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
                        fontSize: (timerFontSize * 0.32).clamp(12.0, 20.0),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
