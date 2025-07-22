import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/timer_mode.dart';
import '../model/timer_config.dart';
import '../view/constants/app_constants.dart';
import 'audio_controller.dart';
import 'notification_service.dart';
import 'task_controller.dart';

// Manages the timer state and logic
class TimerController extends ChangeNotifier {
  Timer? _timer;
  TimerMode _currentMode = TimerMode.pomodoro;
  bool _isRunning = false;
  int _timeLeft = AppConstants.pomodoroTime;
  int _round = 1;
  AudioController? _audioController;
  TaskController? _taskController;

  bool _autoStartBreaks;
  bool _autoStartPomodoros;
  int _longBreakInterval = 4;
  int get longBreakInterval => _longBreakInterval;
  set longBreakInterval(int value) {
    _longBreakInterval = value > 0 ? value : 4;
  }

  // Reminder settings
  String _reminderTime = 'Off';
  int _reminderMinutes = 5;
  bool _reminderShown = false;

  // Real-time tracking
  int _sessionStartTime = 0;
  bool _isTrackingSession = false;

  TimerController({
    bool autoStartBreaks = false,
    bool autoStartPomodoros = false,
  }) : _autoStartBreaks = autoStartBreaks,
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

  // Set task controller reference
  void setTaskController(TaskController taskController) {
    _taskController = taskController;
  }

  // Load reminder settings
  Future<void> loadReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _reminderTime = prefs.getString('reminderTime') ?? 'Off';
    _reminderMinutes = prefs.getInt('reminderMinutes') ?? 5;
  }

  // Load user's timer settings
  Future<void> loadTimerSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load user's saved timer durations
    final pomodoroMinutes = prefs.getInt('pomodoroTime') ?? 25;
    final shortBreakMinutes = prefs.getInt('shortBreakTime') ?? 5;
    final longBreakMinutes = prefs.getInt('longBreakTime') ?? 20;

    // Update the timer configurations with user's settings
    TimerConfigManager.updateAllConfigs(
      pomodoro: pomodoroMinutes * 60,
      shortBreak: shortBreakMinutes * 60,
      longBreak: longBreakMinutes * 60,
    );

    // Update current timer if it's not running
    if (!_isRunning) {
      _timeLeft = TimerConfigManager.getConfig(_currentMode).time;
      notifyListeners();
    }

    print(
      'Loaded timer settings: Pomodoro=$pomodoroMinutes, Short=$shortBreakMinutes, Long=$longBreakMinutes',
    );
  }

  // Check and update day tracking (call this when app starts)
  Future<void> checkDayTracking() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Get last activity date
    final lastActivityString = prefs.getString('lastActivityDate');
    DateTime? lastActivity;
    if (lastActivityString != null) {
      lastActivity = DateTime.parse(lastActivityString);
    }

    // If it's a new day and we haven't tracked it yet
    if (lastActivity == null || !_isSameDay(lastActivity, today)) {
      print('New day detected, updating day tracking...');

      // Update days accessed
      final currentDays = prefs.getInt('daysAccessed') ?? 0;
      final newDays = currentDays + 1;
      await prefs.setInt('daysAccessed', newDays);
      print('Updated days accessed: $currentDays -> $newDays');

      // Update day streak
      if (lastActivity != null && _isConsecutiveDay(lastActivity, today)) {
        final currentStreak = prefs.getInt('dayStreak') ?? 0;
        final newStreak = currentStreak + 1;
        await prefs.setInt('dayStreak', newStreak);
        print('Updated day streak: $currentStreak -> $newStreak');
      } else {
        // Reset streak if not consecutive or first time
        await prefs.setInt('dayStreak', 1);
        print('Reset day streak to 1');
      }

      // Save today's date
      await prefs.setString('lastActivityDate', today.toIso8601String());
    }
  }

  // Start the timer
  void startTimer() {
    print(
      'startTimer called - current mode: $_currentMode, isTrackingSession: $_isTrackingSession',
    );
    _timer?.cancel(); // Always clear any previous timer
    if (_isRunning) return;

    _isRunning = true;
    _reminderShown = false; // Reset reminder flag when starting

    // Start tracking session time for all timer modes
    if (!_isTrackingSession) {
      _sessionStartTime = TimerConfigManager.getConfig(_currentMode).time;
      _isTrackingSession = true;
      print(
        'Started tracking ${_currentMode.toString()} session: $_sessionStartTime seconds',
      );
    } else {
      print('Already tracking session, not starting new tracking');
    }

    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        _timeLeft--;
        _checkReminder(); // Check for reminder
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

  // Add actual time used to minutes focused
  Future<void> _addTimeUsed() async {
    print(
      '_addTimeUsed called - isTrackingSession: $_isTrackingSession, sessionStartTime: $_sessionStartTime, timeLeft: $_timeLeft',
    );

    if (_isTrackingSession) {
      final prefs = await SharedPreferences.getInstance();
      final timeUsed = _sessionStartTime - _timeLeft; // Time actually used
      final minutesUsed = timeUsed ~/ 60; // Convert to minutes

      print(
        'Calculated timeUsed: $timeUsed seconds, minutesUsed: $minutesUsed minutes',
      );

      if (minutesUsed > 0) {
        final currentMinutes = prefs.getInt('hoursFocused') ?? 0;
        final newMinutes = currentMinutes + minutesUsed;
        await prefs.setInt('hoursFocused', newMinutes);
        print(
          'Added $minutesUsed minutes to focus time (${_currentMode.toString()}, used ${timeUsed}s out of ${_sessionStartTime}s)',
        );
        print('Total minutes focused: $currentMinutes -> $newMinutes');

        // Force a reload to verify the data was saved
        final verifyMinutes = prefs.getInt('hoursFocused') ?? 0;
        print('Verification - minutes focused after save: $verifyMinutes');

        // Add minutes to the current active task if this is a Pomodoro session
        if (_currentMode == TimerMode.pomodoro && _taskController != null) {
          final taskIndex = _taskController!.getFirstUncompletedTaskIndex();
          print('Task controller found: ${_taskController != null}');
          print('First uncompleted task index: $taskIndex');
          if (taskIndex != null) {
            _taskController!.addMinutesToTask(taskIndex, minutesUsed);
            print('Added $minutesUsed minutes to task at index $taskIndex');
          } else {
            print('No uncompleted tasks found to add time to');
          }
        } else {
          print(
            'Not adding to task - Mode: $_currentMode, TaskController: ${_taskController != null}',
          );
        }
      } else {
        print('No minutes to add (minutesUsed: $minutesUsed)');
      }

      // Reset tracking
      _isTrackingSession = false;
      _sessionStartTime = 0;
      print('Tracking reset');
    } else {
      print('Not tracking session, skipping time addition');
    }
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

    // Reset tracking for all timer modes
    _isTrackingSession = false;
    _sessionStartTime = 0;
    print('${_currentMode.toString()} reset, tracking cleared');

    notifyListeners();
  }

  // Switch to a different timer mode
  void switchMode(TimerMode mode) {
    print(
      'switchMode called - from $_currentMode to $mode, isTrackingSession: $_isTrackingSession',
    );
    _timer?.cancel();
    _currentMode = mode;
    _timeLeft = TimerConfigManager.getConfig(_currentMode).time;
    _isRunning = false;
    notifyListeners();
  }

  // Skip to the next mode
  Future<void> skipToNext() async {
    print(
      'skipToNext called - current mode: $_currentMode, isTrackingSession: $_isTrackingSession',
    );
    _timer?.cancel();
    _isRunning = false;

    // Store current tracking state before adding time (for potential future use)
    // final wasTracking = _isTrackingSession;
    // final sessionStart = _sessionStartTime;
    // final timeLeft = _timeLeft;

    // Add time used for all timer modes when skipping
    print('${_currentMode.toString()} skipped, adding time used...');
    await _addTimeUsed();

    // Debug check after adding time
    await debugCheckMinutesFocused();

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

    print('Switching from $_currentMode to $nextMode');

    // Switch to the next mode
    switchMode(nextMode);

    // Increment round only if switching to pomodoro
    if (nextMode == TimerMode.pomodoro) {
      _round++;
    }

    // Now check the toggles for the *new* mode
    if ((nextMode == TimerMode.pomodoro && _autoStartPomodoros) ||
        ((nextMode == TimerMode.shortBreak ||
                nextMode == TimerMode.longBreak) &&
            _autoStartBreaks)) {
      startTimer();
    }
  }

  // Called when timer reaches zero
  void _completeTimer() {
    print('Timer completed! Mode: $_currentMode');
    _timer?.cancel();
    _isRunning = false;

    // Add time used for all timer modes
    _addTimeUsed();

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

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isConsecutiveDay(DateTime date1, DateTime date2) {
    final difference = date2.difference(date1).inDays;
    return difference == 1;
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

  // Debug method to check current minutes focused
  Future<void> debugCheckMinutesFocused() async {
    final prefs = await SharedPreferences.getInstance();
    final minutes = prefs.getInt('hoursFocused') ?? 0;
    print('DEBUG: Current minutes focused: $minutes');
  }

  // Check if reminder should be shown
  void _checkReminder() {
    if (_reminderTime == 'Off') return; // Don't show reminders if turned off
    if (_reminderShown) return; // Don't show reminder multiple times

    int totalTime = TimerConfigManager.getConfig(_currentMode).time;
    int timeElapsed = totalTime - _timeLeft;

    if (_reminderTime == 'Last') {
      // Show reminder in the last X minutes
      if (_timeLeft <= _reminderMinutes * 60 && _timeLeft > 0) {
        _showReminderNotification();
        _reminderShown = true;
      }
    } else if (_reminderTime == 'Every') {
      // Show reminder every X minutes
      if (timeElapsed > 0 && timeElapsed % (_reminderMinutes * 60) == 0) {
        _showReminderNotification();
      }
    }
  }

  // Show reminder notification
  void _showReminderNotification() {
    String title;
    String body;

    switch (_currentMode) {
      case TimerMode.pomodoro:
        title = 'Focus Reminder';
        body = 'Keep going! You\'re doing great with your focus session.';
        break;
      case TimerMode.shortBreak:
        title = 'Break Reminder';
        body = 'Enjoy your short break! Don\'t forget to stretch.';
        break;
      case TimerMode.longBreak:
        title = 'Long Break Reminder';
        body = 'Take this time to relax and recharge.';
        break;
    }

    NotificationService.showNotification(
      title: title,
      body: body,
      id: 1, // Use different ID for reminders
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
