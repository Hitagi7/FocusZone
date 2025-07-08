import 'package:flutter/material.dart';

class AppConstants {
  // Timer durations (in seconds)
  static const int pomodoroTime = 25 * 60;
  static const int shortBreakTime = 5 * 60;
  static const int longBreakTime = 15 * 60;

  // Colors
  static const Color pomodoroColor = Color(0xFFDB524D);
  static const Color shortBreakColor = Color(0xFF468E91);
  static const Color longBreakColor = Color(0xFF437EA8);

  // Timer settings
  static const int longBreakInterval = 4; // Long break every 4 pomodoros
  static const int autoSwitchDelaySeconds = 2;
  static const int timerUpdateIntervalSeconds = 1;

  // UI constants
  static const double circularTimerSize = 320.0;
  static const double circularTimerInnerSize = 280.0;
  static const double progressStrokeWidth = 8.0;
  static const double timerFontSize = 64.0;
  static const double headerIconSize = 32.0;

  // App strings
  static const String appTitle = 'FocusZone';
  static const String focusMessage = 'Time to focus!';
  static const String breakMessage = 'Time for a break!';
  static const String pomodoroCompleteMessage = 'Pomodoro completed! Time for a break.';
  static const String breakCompleteMessage = 'Break completed! Time to focus.';
  static const String startButtonText = 'START';
  static const String pauseButtonText = 'PAUSE';
}