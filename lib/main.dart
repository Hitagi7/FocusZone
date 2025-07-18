import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'models/timer_mode.dart';
import 'models/timer_config.dart';
import 'constants/app_constants.dart';
import 'widgets/app_header.dart';
import 'widgets/timer_display.dart';
import 'widgets/control_buttons.dart';
import 'widgets/round_counter.dart';
import 'widgets/sound_button.dart';
import 'controllers/timer_controller.dart';
import 'controllers/audio_controller.dart';
import 'widgets/task_list.dart';
import 'widgets/task_add.dart';
import 'controllers/task_controller.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  await _requestNotificationPermissions();
  runApp(FocusZoneApp());
}

Future<void> _requestNotificationPermissions() async {
  try {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final bool? granted = await androidImplementation.requestNotificationsPermission();
      print('[Main] Notification permission granted: $granted');
    }
  } catch (e) {
    print('[Main] Error requesting notification permissions: $e');
  }
}

class FocusZoneApp extends StatelessWidget {
  const FocusZoneApp({super.key});

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
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late TimerController _timerController;
  late AudioController _audioController;
  int _currentPageIndex = 0; // Simple page index (0, 1, 2)
  late PageController _pageController;
  late TaskController _taskController;

  @override
  void initState() {
    super.initState();
    _timerController = TimerController();
    _audioController = AudioController();
    _timerController.setAudioController(_audioController);
    _timerController.addListener(_onTimerUpdate);
    _timerController.addListener(_onModeChanged);
    _pageController = PageController(initialPage: _currentPageIndex);
    _taskController = TaskController();
  }

  @override
  void dispose() {
    _timerController.removeListener(_onTimerUpdate);
    _timerController.removeListener(_onModeChanged);
    _timerController.dispose();
    _audioController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onTimerUpdate() {
    setState(() {});

    if (_timerController.timeLeft == 0 && !_timerController.isRunning) {
      _showCompletionNotification();
    }
  }

  // Listen for mode changes from timer controller
  void _onModeChanged() {
    // Update page index to match the new timer mode
    TimerMode newMode = _timerController.currentMode;
    int newPageIndex = _getPageIndexForMode(newMode);
    
    if (_currentPageIndex != newPageIndex) {
      setState(() {
        _currentPageIndex = newPageIndex;
      });
      
      // Animate to the new page
      _pageController.animateToPage(
        newPageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showCompletionNotification() {
    // Get the current mode that just completed
    TimerMode completedMode = _timerController.currentMode;
    
    // Show animated notification
    _showAnimatedNotification(completedMode);
    
    // Show local notification with mode-specific content
    String title;
    String body;
    switch (completedMode) {
      case TimerMode.pomodoro:
        title = 'Pomodoro Timer Complete!';
        body = 'Great work! Your focus session has ended. Time for a break.';
        break;
      case TimerMode.shortBreak:
        title = 'Short Break Complete!';
        body = 'Your short break has ended. Ready to focus again?';
        break;
      case TimerMode.longBreak:
        title = 'Long Break Complete!';
        body = 'Your long break has ended. Time to get back to work!';
        break;
    }
    
    NotificationService.showNotification(
      title: title,
      body: body,
    );
  }

  void _showAnimatedNotification(TimerMode completedMode) {
    final overlay = Navigator.of(context).overlay;
    assert(overlay != null, 'No overlay found in context!');

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 20,
        left: 16,
        right: 16,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          curve: Curves.elasticOut,
          builder: (context, value, _) {
            final clampedValue = value.clamp(0.0, 1.0);

            return Transform.translate(
              offset: Offset(0, 100 * (1 - clampedValue)),
              child: Opacity(
                opacity: clampedValue,
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontFamily: 'Noto Sans Display',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: _getCompletionColor(completedMode),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _getCompletionMessage(completedMode),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    overlay!.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  // Get completion message based on mode
  String _getCompletionMessage(TimerMode mode) {
    switch (mode) {
      case TimerMode.pomodoro:
        return 'Great work! Pomodoro timer completed!';
      case TimerMode.shortBreak:
        return 'Short break completed!';
      case TimerMode.longBreak:
        return 'Long break completed!';
    }
  }

  // Get completion color based on mode
  Color _getCompletionColor(TimerMode mode) {
    switch (mode) {
      case TimerMode.pomodoro:
        return Colors.green.withValues(alpha: 0.9);
      case TimerMode.shortBreak:
        return Colors.blue.withValues(alpha: 0.9);
      case TimerMode.longBreak:
        return Colors.purple.withValues(alpha: 0.9);
    }
    // Unique fallback color (bright red for debugging)
    return const Color(0xFFFF0000); // Red
  }

  void _toggleTimer() {
    if (!_timerController.isRunning) {
      HapticFeedback.lightImpact();
    }
    _timerController.toggleTimer();
  }

  // Handle skip button press
  void _handleSkipToNext() {
    _timerController.skipToNext();
    
    // Update the page index to match the new timer mode
    TimerMode newMode = _timerController.currentMode;
    int newPageIndex = _getPageIndexForMode(newMode);
    
    setState(() {
      _currentPageIndex = newPageIndex;
    });
    
    // Animate to the new page
    _pageController.animateToPage(
      newPageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Handle page changes when user swipes
  void _onPageChanged(int pageIndex) {
    setState(() {
      _currentPageIndex = pageIndex;
    });
    
    // Get the mode for this page
    TimerMode newMode = _getModeForPage(pageIndex);
    
    // Only switch timer mode if it's different
    if (_timerController.currentMode != newMode) {
      HapticFeedback.selectionClick();
      _timerController.switchMode(newMode);
    }
  }

  // Simple mapping: page 0 = Pomodoro, page 1 = Short Break, page 2 = Long Break
  TimerMode _getModeForPage(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return TimerMode.pomodoro;
      case 1:
        return TimerMode.shortBreak;
      case 2:
        return TimerMode.longBreak;
      default:
        return TimerMode.pomodoro;
    }
  }

  // Get page index for a given timer mode
  int _getPageIndexForMode(TimerMode mode) {
    switch (mode) {
      case TimerMode.pomodoro:
        return 0;
      case TimerMode.shortBreak:
        return 1;
      case TimerMode.longBreak:
        return 2;
    }
    // Unique fallback index for debugging
    return -1;
  }

  // Get the label for each mode
  String _getModeLabel(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return 'Pomodoro';
      case 1:
        return 'Short Break';
      case 2:
        return 'Long Break';
      default:
        return 'Pomodoro';
    }
  }

  // Get the icon for each mode
  IconData _getModeIcon(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return Icons.work;
      case 1:
        return Icons.coffee;
      case 2:
        return Icons.weekend;
      default:
        return Icons.work;
    }
  }

  // Get the description for each mode
  String _getModeDescription(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return 'Focus on your task';
      case 1:
        return 'Take a quick rest';
      case 2:
        return 'Time for a longer break';
      default:
        return 'Focus on your task';
    }
  }

  // Get the background color for the current page
  Color _getBackgroundColor() {
    return TimerConfigManager.getConfig(_getModeForPage(_currentPageIndex)).color;
  }

  // Load background image with multiple fallback options
  Future<Widget> _loadBackgroundImage() async {
    final List<String> assetPaths = [
      'images/pomodoro_bg.gif',
      'assets/images/pomodoro_bg.gif',
    ];

    for (String path in assetPaths) {
      try {
        await rootBundle.load(path);
        print('Successfully loaded: $path');
        return Image.asset(
          path,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        );
      } catch (e) {
        print('Failed to load $path: $e');
        continue;
      }
    }

    // If all assets fail, return gradient
    print('All assets failed, using gradient fallback');
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppConstants.pomodoroColor,
            AppConstants.pomodoroColor.withValues(alpha: 0.8),
          ],
        ),
      ),
    );
  }





    @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: _getBackgroundColor(),
      body: SafeArea(
        child: Stack(
          children: [
            // Background image for Pomodoro mode
            if (_currentPageIndex == 0) // Pomodoro mode
              Positioned.fill(
                child: FutureBuilder<Widget>(
                  future: _loadBackgroundImage(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data!;
                    } else {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppConstants.pomodoroColor,
                              AppConstants.pomodoroColor.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            // Semi-transparent overlay for better text readability
            if (_currentPageIndex == 0) // Pomodoro mode
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),
            // Main content
            Column(
          children: [
            // Header stays at the top
            AppHeader(),
            
            // Swipeable content (timer and mode label)
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      children: [
                        _buildTimerPage(0),
                        _buildTimerPage(1),
                        _buildTimerPage(2),
                      ],
                    ),
                  ),
                  
                  // Remove or reduce space before RoundCounter and tasks
                  const SizedBox(height: 0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: RoundCounter(
                      round: _timerController.round,
                    ),
                  ),
                  const SizedBox(height: 0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Column(
                      children: [
                        TaskAdd(taskController: _taskController),
                        const SizedBox(height: 8),
                        TaskList(taskController: _taskController),
                      ],
                    ),
                  ),
                  // Reduce bottom space
                  const SizedBox(height: 79),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
    ),
    floatingActionButton: Align(
      alignment: Alignment.bottomRight,
      child: SoundButton(
        audioController: _audioController,
      ),
    ),
  );
}

  // Build the timer page for each mode
  Widget _buildTimerPage(int pageIndex) {
    return Column(
      children: [
        // Enhanced mode label
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              // Mode icon
              Icon(
                _getModeIcon(pageIndex),
                color: Colors.white.withValues(alpha: 0.9),
                size: 28,
              ),
              const SizedBox(height: 4),
              // Mode label with enhanced styling
              Text(
                _getModeLabel(pageIndex),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Noto Sans Display',
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              // Mode description
              Text(
                _getModeDescription(pageIndex),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontFamily: 'Noto Sans Display',
                ),
              ),
            ],
          ),
        ),
        // Timer display with reset/skip buttons overlaid
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 50),
          child: SizedBox(
            width: AppConstants.circularTimerSize,
            height: AppConstants.circularTimerSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Timer in the center
                Align(
                  alignment: Alignment.center,
                  child: TimerDisplay(
                    timeLeft: _timerController.timeLeft,
                    currentMode: _timerController.currentMode,
                    progress: _timerController.progress,
                    onToggleTimer: _toggleTimer,
                    isRunning: _timerController.isRunning,
                  ),
                ),
                // Reset button (bottom left, lowered)
                if (_timerController.isRunning)
                  Positioned(
                    left: -10,
                    bottom: -10,
                    child: IconButton(
                      onPressed: _timerController.resetTimer,
                      icon: Icon(Icons.refresh, color: Colors.white, size: 42),
                    ),
                  ),
                // Skip button (bottom right, lowered)
                if (_timerController.isRunning)
                  Positioned(
                    right: -10,
                    bottom: -10, // less negative to lower it more
                    child: IconButton(
                      onPressed: _handleSkipToNext,
                      icon: Icon(Icons.skip_next, color: Colors.white, size: 46),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}