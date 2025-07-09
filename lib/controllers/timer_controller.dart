import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/timer_mode.dart';
import '../models/timer_config.dart';
import '../constants/app_constants.dart';

class TimerController extends ChangeNotifier {
  Timer? _timer;
  TimerMode _currentMode = TimerMode.pomodoro;
  bool _isRunning = false;
  int _timeLeft = AppConstants.pomodoroTime;
  int _round = 1;

  // Getters
  TimerMode get currentMode => _currentMode;
  bool get isRunning => _isRunning;
  int get timeLeft => _timeLeft;
  int get round => _round;

  double get progress {
    int totalTime = TimerConfigManager.getConfig(_currentMode).time;
    if (totalTime <= 0) return 0.0;
    return ((totalTime - _timeLeft) / totalTime).clamp(0.0, 1.0);
  }

  void startTimer() {
    if (_isRunning) return;

    _isRunning = true;
    notifyListeners();

    _timer = Timer.periodic(Duration(seconds: AppConstants.timerUpdateIntervalSeconds), (timer) {
      if (_timeLeft > 0) {
        _timeLeft--;
        notifyListeners();
      } else {
        _completeTimer();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void toggleTimer() {
    if (_isRunning) {
      pauseTimer();
    } else {
      startTimer();
    }
  }

  void resetTimer() {
    _timer?.cancel();
    _timeLeft = TimerConfigManager.getConfig(_currentMode).time;
    _isRunning = false;
    notifyListeners();
  }

  void switchMode(TimerMode mode) {
    _timer?.cancel();
    _currentMode = mode;
    _timeLeft = TimerConfigManager.getConfig(_currentMode).time;
    _isRunning = false;
    notifyListeners();
  }

  void skipToNext() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
    _autoSwitchMode();
  }

  void _completeTimer() {
    _timer?.cancel();
    _isRunning = false;

    if (_currentMode == TimerMode.pomodoro) {
      _round++;
    }

    // Haptic feedback
    HapticFeedback.heavyImpact();

    notifyListeners();

    // Auto-switch to next mode
    _autoSwitchMode();
  }

  void _autoSwitchMode() {
    TimerMode nextMode;
    switch (_currentMode) {
      case TimerMode.pomodoro:
        nextMode = (_round % AppConstants.longBreakInterval == 0)
            ? TimerMode.longBreak
            : TimerMode.shortBreak;
        break;
      case TimerMode.shortBreak:
      case TimerMode.longBreak:
        nextMode = TimerMode.pomodoro;
        break;
    }

    Future.delayed(Duration(seconds: AppConstants.autoSwitchDelaySeconds), () {
      switchMode(nextMode);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}