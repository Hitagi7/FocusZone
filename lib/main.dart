import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'model/timer_mode.dart';
import 'model/timer_config.dart';
import 'view/constants/app_constants.dart';
import 'view/app_header.dart';
import 'view/timer_display.dart';
import 'view/round_counter.dart';
import 'view/sound_button.dart';
import 'controller/timer_controller.dart';
import 'controller/audio_controller.dart';
import 'view/task_list.dart';
import 'view/task_add.dart';
import 'controller/task_controller.dart';
import 'controller/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'view/quotes_page.dart';

final GlobalKey<_LandingPageState> landingPageKey =
    GlobalKey<_LandingPageState>();

bool globalAutoStartBreaks = false;
bool globalAutoStartPomodoros = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  await _requestNotificationPermissions();
  await _loadUserTimerSettings();
  await _loadAutoStartSettings();
  runApp(FocusZoneApp());
}

Future<void> _requestNotificationPermissions() async {
  try {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      // print('[Main] Notification permission requested');
    }
  } catch (e) {
    // print('[Main] Error requesting notification permissions: $e');
  }
}

Future<void> _loadUserTimerSettings() async {
  final prefs = await SharedPreferences.getInstance();
  final pomodoro = prefs.getInt('pomodoroTime') ?? 25;
  final shortBreak = prefs.getInt('shortBreakTime') ?? 5;
  final longBreak = prefs.getInt('longBreakTime') ?? 20;
  TimerConfigManager.updateAllConfigs(
    pomodoro: pomodoro * 60,
    shortBreak: shortBreak * 60,
    longBreak: longBreak * 60,
  );
}

Future<void> _loadAutoStartSettings() async {
  final prefs = await SharedPreferences.getInstance();
  globalAutoStartBreaks = prefs.getBool('autoStartBreaks') ?? false;
  globalAutoStartPomodoros = prefs.getBool('autoStartPomodoros') ?? false;
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
      home: LandingPage(key: landingPageKey),
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
  int _currentPageIndex =
      1; // 0 = Quotes, 1 = Pomodoro, 2 = Short Break, 3 = Long Break
  late PageController _pageController;
  late TaskController _taskController;
  bool _isPageAnimating = false; // Add this flag

  TimerController get timerController => _timerController;

  @override
  void initState() {
    super.initState();
    _timerController = TimerController(
      autoStartBreaks: globalAutoStartBreaks,
      autoStartPomodoros: globalAutoStartPomodoros,
    );
    _audioController = AudioController();
    _taskController = TaskController();
    _timerController.setAudioController(_audioController);
    _timerController.setTaskController(_taskController);
    _timerController.addListener(_onTimerUpdate);
    _timerController.addListener(_onModeChanged);
    _pageController = PageController(initialPage: _currentPageIndex);

    // Load user's timer settings
    _timerController.loadTimerSettings();

    // Load reminder settings
    _timerController.loadReminderSettings();

    // Check day tracking when app starts
    _timerController.checkDayTracking();
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
      _isPageAnimating = true;
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

    NotificationService.showNotification(title: title, body: body);
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
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
                          child: Text(_getCompletionMessage(completedMode)),
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
    TimerMode? newMode = _getModeForPage(pageIndex);

    // Only switch timer mode if it's different and not animating
    if (!_isPageAnimating &&
        newMode != null &&
        _timerController.currentMode != newMode) {
      HapticFeedback.selectionClick();
      _timerController.switchMode(newMode);
    }
    // Reset the animating flag
    if (_isPageAnimating) {
      _isPageAnimating = false;
    }
  }

  // Update mapping functions for new page structure
  TimerMode? _getModeForPage(int pageIndex) {
    switch (pageIndex) {
      case 1:
        return TimerMode.pomodoro;
      case 2:
        return TimerMode.shortBreak;
      case 3:
        return TimerMode.longBreak;
      default:
        return null;
    }
  }

  int _getPageIndexForMode(TimerMode mode) {
    switch (mode) {
      case TimerMode.pomodoro:
        return 1;
      case TimerMode.shortBreak:
        return 2;
      case TimerMode.longBreak:
        return 3;
    }
  }

  // Get the label for each mode
  String _getModeLabel(int pageIndex) {
    switch (pageIndex) {
      case 1:
        return 'Pomodoro';
      case 2:
        return 'Short Break';
      case 3:
        return 'Long Break';
      default:
        return 'Pomodoro';
    }
  }

  // Get the icon for each mode
  IconData _getModeIcon(int pageIndex) {
    switch (pageIndex) {
      case 1:
        return Icons.work;
      case 2:
        return Icons.coffee;
      case 3:
        return Icons.weekend;
      default:
        return Icons.work;
    }
  }

  // Get the description for each mode
  String _getModeDescription(int pageIndex) {
    switch (pageIndex) {
      case 1:
        return 'Focus on your task';
      case 2:
        return 'Take a quick rest';
      case 3:
        return 'Time for a longer break';
      default:
        return 'Focus on your task';
    }
  }

  // Get the background color for the current page
  Color _getBackgroundColor() {
    return TimerConfigManager.getConfig(
      _getModeForPage(_currentPageIndex) ?? TimerMode.pomodoro,
    ).color;
  }

  // Load background image for specific timer mode
  Future<Widget> _loadBackgroundImage(TimerMode mode) async {
    String gifPath;
    Color fallbackColor;

    switch (mode) {
      case TimerMode.pomodoro:
        gifPath = 'images/pomodoro_bg.gif';
        fallbackColor = AppConstants.pomodoroColor;
        break;
      case TimerMode.shortBreak:
        gifPath = 'images/break_bg.gif';
        fallbackColor = AppConstants.shortBreakColor;
        break;
      case TimerMode.longBreak:
        gifPath = 'images/longbreak_bg.gif';
        fallbackColor = AppConstants.longBreakColor;
        break;
    }

    final List<String> assetPaths = [gifPath, 'assets/$gifPath'];

    for (String path in assetPaths) {
      try {
        await rootBundle.load(path);
        // print('Successfully loaded: $path');
        return Image.asset(path, fit: BoxFit.cover, gaplessPlayback: true);
      } catch (e) {
        // print('Failed to load $path: $e');
        continue;
      }
    }

    // If all assets fail, return gradient
    // print('All assets failed, using gradient fallback');
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [fallbackColor, fallbackColor.withValues(alpha: 0.8)],
        ),
      ),
    );
  }

  String _getModeLabelForTimerMode(TimerMode mode) {
    switch (mode) {
      case TimerMode.pomodoro:
        return 'Pomodoro';
      case TimerMode.shortBreak:
        return 'Short Break';
      case TimerMode.longBreak:
        return 'Long Break';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: _getBackgroundColor(),
      body: SafeArea(
        child: Stack(
          children: [
            // Background image for all timer modes
            Positioned.fill(
              child: FutureBuilder<Widget>(
                future: _loadBackgroundImage(
                  _getModeForPage(_currentPageIndex) ?? TimerMode.pomodoro,
                ),
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
                            _getBackgroundColor(),
                            _getBackgroundColor().withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            // Semi-transparent overlay for better text readability
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.3)),
            ),
            // Main content
            Column(
              children: [
                // Header stays at the top
                AppHeader(taskController: _taskController),

                // Swipeable content (timer and mode label)
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: _onPageChanged,
                          children: [
                            QuotesPage(), // index 0
                            _buildTimerPage(1), // Pomodoro
                            _buildTimerPage(2), // Short Break
                            _buildTimerPage(3), // Long Break
                          ],
                        ),
                      ),

                      // (RoundCounter moved inside _buildTimerPage)
                      // (Task widgets moved inside _buildTimerPage)
                      // Ultra-minimal bottom space
                      const SizedBox(height: 25),
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
          modeTitle: _getModeLabelForTimerMode(_timerController.currentMode),
        ),
      ),
    );
  }

  // Update _buildTimerPage to accept the new pageIndex
  Widget _buildTimerPage(int pageIndex) {
    final TimerMode? mode = _getModeForPage(pageIndex);
    if (mode == null) {
      return const SizedBox.shrink();
    }
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
          padding: const EdgeInsets.only(top: 4, bottom: 0),
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
                      icon: Icon(
                        Icons.skip_next,
                        color: Colors.white,
                        size: 46,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // RoundCounter directly below timer
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          constraints: const BoxConstraints(maxWidth: 400),
          child: RoundCounter(round: _timerController.round),
        ),
        // Task widgets directly below round counter
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            children: [
              TaskAdd(taskController: _taskController),
              const SizedBox(height: 2),
              TaskList(taskController: _taskController),
            ],
          ),
        ),
      ],
    );
  }

  // Add a public method to update timer duration from outside
  void updateTimerDurationFromSettings() {
    _timerController.updateCurrentDurationIfNeeded();
  }
}
