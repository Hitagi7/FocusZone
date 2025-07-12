import 'package:flutter/material.dart';
import 'timer_mode.dart'; // Make sure TimerMode enum is imported
import '../constants/app_constants.dart'; // Make sure your constants are imported

// Defines the configuration for a specific timer mode
class TimerConfig {
  final String label;
  final int time; // Duration in seconds
  final Color color;

  TimerConfig({
    required this.label,
    required this.time,
    required this.color,
  });
}

// Manages and provides access to configurations for different timer modes
class TimerConfigManager {
  // Static map holding all the configurations, keyed by TimerMode
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

  // Static method to get the configuration for a specific mode
  static TimerConfig getConfig(TimerMode mode) {
    // The '!' (null assertion operator) is used because we expect every TimerMode
    // to have a corresponding configuration. If not, it's a programming error.
    return _configs[mode]!;
  }

  // Optional: A getter to access all configurations if needed elsewhere
  static Map<TimerMode, TimerConfig> get allConfigs => _configs;
}
