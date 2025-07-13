import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/timer_mode.dart';
import '../models/timer_config.dart';
import '../constants/app_constants.dart';

// Manages the timer state and logic
class TimerController extends ChangeNotifier {
  Timer? _timer;
  TimerMode _currentMode = TimerMode.pomodoro;
  bool _isRunning = false;
  int _timeLeft = AppConstants.pomodoroTime;
  int _round = 1;

  // Getters for UI to access timer state
  TimerMode get currentMode => _currentMode;
  bool get isRunning => _isRunning;
  int get timeLeft => _timeLeft;
  int get round => _round;

  // Calculate progress for the circular progress indicator
  double get progress {
    int totalTime = TimerConfigManager.getConfig(_currentMode).time;
    if (totalTime <= 0) return 0.0;
    return ((totalTime - _timeLeft) / totalTime).clamp(0.0, 1.0);
  }

  // Start the timer
  void startTimer() {
    if (_isRunning) return;

    _isRunning = true;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        _timeLeft--;
        notifyListeners();
      } else {
        _completeTimer();
      }
    });
  }

  // Pause the timer
  void pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  // Toggle between start and pause
  void toggleTimer() {
    if (_isRunning) {
      pauseTimer();
    } else {
      startTimer();
    }
  }

  // Reset timer to full duration
  void resetTimer() {
    _timer?.cancel();
    _timeLeft = TimerConfigManager.getConfig(_currentMode).time;
    _isRunning = false;
    notifyListeners();
  }

  // Switch to a different timer mode
  void switchMode(TimerMode mode) {
    _timer?.cancel();
    _currentMode = mode;
    _timeLeft = TimerConfigManager.getConfig(_currentMode).time;
    _isRunning = false;
    notifyListeners();
  }

  // Skip to the next mode
  void skipToNext() {
    _timer?.cancel();
    _isRunning = false;
    
    // Increment round only if current mode is pomodoro
    if (_currentMode == TimerMode.pomodoro) {
      _round++;
    }
    
    // Determine the next mode based on current mode
    TimerMode nextMode;
    switch (_currentMode) {
      case TimerMode.pomodoro:
        // After pomodoro, go to short break (or long break every 4 rounds)
        nextMode = (_round % AppConstants.longBreakInterval == 0)
            ? TimerMode.longBreak
            : TimerMode.shortBreak;
        break;
      case TimerMode.shortBreak:
      case TimerMode.longBreak:
        // After any break, go back to pomodoro
        nextMode = TimerMode.pomodoro;
        break;
    }
    
    // Switch to the next mode
    switchMode(nextMode);
  }

  // Called when timer reaches zero
  void _completeTimer() {
    _timer?.cancel();
    _isRunning = false;

    // Increment round counter for pomodoro sessions
    if (_currentMode == TimerMode.pomodoro) {
      _round++;
    }

    // Provide haptic feedback
    HapticFeedback.heavyImpact();
    notifyListeners();

    // Auto-switch to next mode after a short delay
    _autoSwitchToNextMode();
  }

  // Auto-switch to the next appropriate mode
  void _autoSwitchToNextMode() {
    TimerMode nextMode;
    
    switch (_currentMode) {
      case TimerMode.pomodoro:
        // After pomodoro, go to short break (or long break every 4 rounds)
        nextMode = (_round % AppConstants.longBreakInterval == 0)
            ? TimerMode.longBreak
            : TimerMode.shortBreak;
        break;
      case TimerMode.shortBreak:
      case TimerMode.longBreak:
        // After any break, go back to pomodoro
        nextMode = TimerMode.pomodoro;
        break;
    }

    // Switch to next mode after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      switchMode(nextMode);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}