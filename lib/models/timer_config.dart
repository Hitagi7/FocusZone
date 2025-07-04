import 'package:flutter/material.dart';
import 'timer_mode.dart';
import '../constants/app_constants.dart';

class TimerConfig {
  final String label;
  final int time;
  final Color color;

  TimerConfig({
    required this.label,
    required this.time,
    required this.color,
  });
}

class TimerConfigManager {
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

  static TimerConfig getConfig(TimerMode mode) {
    return _configs[mode]!;
  }

  static Map<TimerMode, TimerConfig> get allConfigs => _configs;
}