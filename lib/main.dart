import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'models/timer_mode.dart';
import 'models/timer_config.dart';
import 'constants/app_constants.dart';
import 'widgets/app_header.dart';
import 'widgets/timer_mode_selector.dart';
import 'widgets/timer_display.dart';
import 'widgets/control_buttons.dart';
import 'widgets/round_counter.dart';

void main() {
  runApp(FocusZoneApp());
}

class FocusZoneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Noto Sans Display',
      ),
      home: LandingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  TimerMode currentMode = TimerMode.pomodoro;
  bool isRunning = false;
  int timeLeft = AppConstants.pomodoroTime;
  int round = 1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    timeLeft = TimerConfigManager.getConfig(currentMode).time;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void switchMode(TimerMode mode) {
    _timer?.cancel();
    setState(() {
      currentMode = mode;
      timeLeft = TimerConfigManager.getConfig(mode).time;
      isRunning = false;
    });
  }

  void toggleTimer() {
    setState(() {
      isRunning = !isRunning;
    });

    if (isRunning) {
      HapticFeedback.lightImpact();
      _startTimer();
    } else {
      _stopTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: AppConstants.timerUpdateIntervalSeconds), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          _onTimerComplete();
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _onTimerComplete() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
    });

// Show completion notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          alignment: Alignment.center,
          child: Text(
            currentMode == TimerMode.pomodoro
                ? AppConstants.pomodoroCompleteMessage
                : AppConstants.breakCompleteMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Noto Sans Display',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.white.withOpacity(0.05), // Even more subtle
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2, // Minimal shadow
      ),
    );

    // Vibrate to indicate completion
    HapticFeedback.heavyImpact();

    // Auto-switch to next mode
    _autoSwitchMode();
  }

  void _autoSwitchMode() {
    TimerMode nextMode;
    switch (currentMode) {
      case TimerMode.pomodoro:
        nextMode = (round % AppConstants.longBreakInterval == 0)
            ? TimerMode.longBreak
            : TimerMode.shortBreak;
        break;
      case TimerMode.shortBreak:
      case TimerMode.longBreak:
        nextMode = TimerMode.pomodoro;
        if (currentMode == TimerMode.longBreak) {
          round++;
        }
        break;
    }

    Future.delayed(Duration(seconds: AppConstants.autoSwitchDelaySeconds), () {
      switchMode(nextMode);
    });
  }

  void resetTimer() {
    _timer?.cancel();
    setState(() {
      timeLeft = TimerConfigManager.getConfig(currentMode).time;
      isRunning = false;
    });
  }

  void skipToNext() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
    });
    _autoSwitchMode();
  }

  double get progress {
    int totalTime = TimerConfigManager.getConfig(currentMode).time;
    return (totalTime - timeLeft) / totalTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TimerConfigManager.getConfig(currentMode).color,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                constraints: BoxConstraints(maxWidth: 620),
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    TimerModeSelector(
                      currentMode: currentMode,
                      onModeChanged: switchMode,
                    ),
                    SizedBox(height: 40),
                    TimerDisplay(
                      timeLeft: timeLeft,
                      currentMode: currentMode,
                      progress: progress,
                    ),
                    SizedBox(height: 30),
                    ControlButtons(
                      isRunning: isRunning,
                      currentMode: currentMode,
                      onToggleTimer: toggleTimer,
                      onResetTimer: resetTimer,
                      onSkipToNext: skipToNext,
                    ),
                    SizedBox(height: 20),
                    RoundCounter(
                      round: round,
                      currentMode: currentMode,
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