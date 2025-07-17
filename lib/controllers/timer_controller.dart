import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/timer_mode.dart';
import '../models/timer_config.dart';
import '../constants/app_constants.dart';
import 'audio_controller.dart';

// Manages the timer state and logic
class TimerController extends ChangeNotifier {
  Timer? _timer;
  TimerMode _currentMode = TimerMode.pomodoro;
  bool _isRunning = false;
  int _timeLeft = AppConstants.pomodoroTime;
  int _round = 1;
  AudioController? _audioController;

  bool _autoStartBreaks;
  bool _autoStartPomodoros;
  int _longBreakInterval = 4;
  int get longBreakInterval => _longBreakInterval;
  set longBreakInterval(int value) {
    _longBreakInterval = value > 0 ? value : 4;
  }

  TimerController({bool autoStartBreaks = false, bool autoStartPomodoros = false})
      : _autoStartBreaks = autoStartBreaks,
        _autoStartPomodoros = autoStartPomodoros;

  set autoStartBreaks(bool value) {
    _autoStartBreaks = value;
  }

  set autoStartPomodoros(bool value) {
    _autoStartPomodoros = value;
  }

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

  // Set audio controller reference
  void setAudioController(AudioController audioController) {
    _audioController = audioController;
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
    
    // Calculate next round for interval check
    int nextRound = _round;
    if (_currentMode == TimerMode.pomodoro) {
      nextRound++;
    }
    
    // Determine the next mode based on current mode
    TimerMode nextMode;
    switch (_currentMode) {
      case TimerMode.pomodoro:
        nextMode = (nextRound % _longBreakInterval == 0)
            ? TimerMode.longBreak
            : TimerMode.shortBreak;
        break;
      case TimerMode.shortBreak:
      case TimerMode.longBreak:
        nextMode = TimerMode.pomodoro;
        break;
    }
    
    // Switch to the next mode
    switchMode(nextMode);

    // Increment round only if switching to pomodoro
    if (nextMode == TimerMode.pomodoro) {
      _round++;
    }

    // Now check the toggles for the *new* mode
    if ((nextMode == TimerMode.pomodoro && _autoStartPomodoros) ||
        ((nextMode == TimerMode.shortBreak || nextMode == TimerMode.longBreak) && _autoStartBreaks)) {
      startTimer();
    }
  }

  // Called when timer reaches zero
  void _completeTimer() {
    _timer?.cancel();
    _isRunning = false;

    // Increment round counter for pomodoro sessions
    if (_currentMode == TimerMode.pomodoro) {
      _round++;
    }

    // Play alarm sound
    _audioController?.playAlarm();

    // Provide haptic feedback
    HapticFeedback.heavyImpact();
    notifyListeners();

    // Auto-switch to next mode after a short delay
    _autoSwitchToNextMode();
  }

  // Auto-switch to the next appropriate mode
  void _autoSwitchToNextMode() {
    TimerMode nextMode;
    bool shouldAutoStart = false;
    int nextRound = _round;
    if (_currentMode == TimerMode.pomodoro) {
      nextRound++;
    }
    
    switch (_currentMode) {
      case TimerMode.pomodoro:
        // After pomodoro, go to short break (or long break every X rounds)
        nextMode = (nextRound % _longBreakInterval == 0)
            ? TimerMode.longBreak
            : TimerMode.shortBreak;
        shouldAutoStart = _autoStartBreaks;
        break;
      case TimerMode.shortBreak:
      case TimerMode.longBreak:
        nextMode = TimerMode.pomodoro;
        shouldAutoStart = _autoStartPomodoros;
        break;
    }

    // Switch to next mode after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      switchMode(nextMode);
      // Increment round only if switching to pomodoro
      if (nextMode == TimerMode.pomodoro) {
        _round++;
      }
      if (shouldAutoStart) {
        startTimer();
      }
    });
  }

  // Update the current timer duration and reset if mode matches
  void updateCurrentDurationIfNeeded() {
    _timeLeft = TimerConfigManager.getConfig(_currentMode).time;
    _isRunning = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}