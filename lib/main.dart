import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'models/timer_mode.dart';
import 'models/timer_config.dart';
import 'constants/app_constants.dart';
import 'widgets/app_header.dart';
// import 'widgets/timer_mode_selector.dart'; // Remove this
import 'widgets/timer_mode_swiper.dart'; // Import the new swiper
import 'widgets/timer_display.dart';
import 'widgets/control_buttons.dart';
import 'widgets/round_counter.dart';
import 'controllers/timer_controller.dart';

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
  late TimerController _timerController;

  @override
  void initState() {
    super.initState();
    _timerController = TimerController();
    _timerController.addListener(_onTimerUpdate);
  }

  @override
  void dispose() {
    _timerController.removeListener(_onTimerUpdate);
    _timerController.dispose();
    super.dispose();
  }

  void _onTimerUpdate() {
    setState(() {}); // This will rebuild the UI, including the swiper if its currentMode needs to update

    if (_timerController.timeLeft == 0 && !_timerController.isRunning) {
      _showCompletionNotification();
    }
  }

  void _showCompletionNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          alignment: Alignment.center,
          child: Text(
            _timerController.currentMode == TimerMode.pomodoro
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
        backgroundColor: Colors.white.withOpacity(0.05),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    );
  }

  void _toggleTimer() {
    if (!_timerController.isRunning) {
      HapticFeedback.lightImpact();
    }
    _timerController.toggleTimer();
  }

  // This is the callback for the TimerModeSwiper
  void _onModeSwiped(TimerMode newMode) {
    if (_timerController.currentMode != newMode) { // Only switch if it's a new mode
      HapticFeedback.selectionClick(); // Optional: haptic feedback for swipe
      _timerController.switchMode(newMode);
      // setState is called by _onTimerUpdate via the listener,
      // or you can call it here if _switchMode doesn't trigger a listener update immediately
      // that affects the background color or other elements dependent on currentMode.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current background color based on the controller's mode
    final currentConfig = TimerConfigManager.getConfig(_timerController.currentMode);

    return Scaffold(
      backgroundColor: currentConfig.color, // Update background color dynamically
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
                    // Replace TimerModeSelector with TimerModeSwiper
                    TimerModeSwiper(
                      currentMode: _timerController.currentMode,
                      onModeChanged: _onModeSwiped,
                    ),
                    SizedBox(height: 40),
                    TimerDisplay(
                      timeLeft: _timerController.timeLeft,
                      currentMode: _timerController.currentMode,
                      progress: _timerController.progress,
                      onToggleTimer: _toggleTimer,
                      isRunning: _timerController.isRunning,
                    ),
                    SizedBox(height: 30),
                    ControlButtons(
                      currentMode: _timerController.currentMode,
                      onResetTimer: _timerController.resetTimer,
                      onSkipToNext: _timerController.skipToNext,
                    ),
                    SizedBox(height: 20),
                    RoundCounter(
                      round: _timerController.round,
                      currentMode: _timerController.currentMode,
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
// ctrl z