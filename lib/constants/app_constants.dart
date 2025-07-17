import 'package:flutter/material.dart';

// App-wide constants and settings
class AppConstants {
  // Timer durations (in seconds)
  static const int pomodoroTime = 25 * 60;    // 25 minutes
  static const int shortBreakTime = 5 * 60;   // 5 minutes
  static const int longBreakTime = 20 * 60;   // 20 minutes

  // Colors for each timer mode
  static const Color pomodoroColor = Color(0xFFDB524D);    // Red
  static const Color shortBreakColor = Color(0xFF468E91);  // Teal
  static const Color longBreakColor = Color(0xFF437EA8);   // Blue

  // Timer settings
  static const int longBreakInterval = 4;  // Long break every 4 pomodoros
  static const int timerUpdateIntervalSeconds = 1;

  // UI sizes
  static const double circularTimerSize = 320.0;
  static const double circularTimerInnerSize = 280.0;
  static const double progressStrokeWidth = 8.0;
  static const double timerFontSize = 64.0;

  // App text
  static const String appTitle = 'FocusZone';
  static const String focusMessage = 'Time to focus!';
  static const String breakMessage = 'Time for a break!';
  static const String pomodoroCompleteMessage = 'Pomodoro completed! Time for a break.';
  static const String breakCompleteMessage = 'Break completed! Time to focus.';
}