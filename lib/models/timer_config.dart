import 'package:flutter/material.dart';
import 'timer_mode.dart';
import '../constants/app_constants.dart';

// Configuration for each timer mode
class TimerConfig {
  final String label;    // Display name
  final int time;        // Duration in seconds
  final Color color;     // Background color

  TimerConfig({
    required this.label,
    required this.time,
    required this.color,
  });
}

// Manages timer configurations for each mode
class TimerConfigManager {
  // Store configurations for each timer mode
  static final Map<TimerMode, TimerConfig> _configs = {
    TimerMode.pomodoro: TimerConfig(
      label: 'Pomodoro',
      time: AppConstants.pomodoroTime,
      color: AppConstants.pomodoroColor,
    ),
    TimerMode.shortBreak: TimerConfig(
      label: 'Short Break',
      time: AppConstants.shortBreakTime,
      color: AppConstants.shortBreakColor,
    ),
    TimerMode.longBreak: TimerConfig(
      label: 'Long Break',
      time: AppConstants.longBreakTime,
      color: AppConstants.longBreakColor,
    ),
  };

  // Get configuration for a specific timer mode
  static TimerConfig getConfig(TimerMode mode) {
    return _configs[mode]!;
  }
}
