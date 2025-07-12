import 'package:flutter/material.dart';
import '../models/timer_config.dart';
import '../models/timer_mode.dart';

class TimerModeSwiper extends StatefulWidget {
  final TimerMode currentMode; // Pass the current mode to highlight it
  final Function(TimerMode) onModeChanged;

  const TimerModeSwiper({
    Key? key,
    required this.currentMode,
    required this.onModeChanged,
  }) : super(key: key);

  @override
  _TimerModeSwiperState createState() => _TimerModeSwiperState();
}

class _TimerModeSwiperState extends State<TimerModeSwiper> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentMode.index);
  }

  @override
  void didUpdateWidget(TimerModeSwiper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentMode != oldWidget.currentMode) {
      // If the current mode changes externally (e.g., by skipping a round),
      // animate the PageView to the correct page.
      if (_pageController.hasClients &&
          _pageController.page?.round() != widget.currentMode.index) {
        _pageController.animateToPage(
          widget.currentMode.index,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine initial page based on the current mode from the controller
    // This ensures the swiper starts at the correct mode.
    // Note: This logic moves to initState and didUpdateWidget for better handling.

    return SizedBox(
      height: 60, // Adjust height as needed
      child: PageView(
        controller: _pageController,
        onPageChanged: (int index) {
          TimerMode newMode;
          switch (index) {
            case 0:
              newMode = TimerMode.pomodoro;
              break;
            case 1:
              newMode = TimerMode.shortBreak;
              break;
            case 2:
              newMode = TimerMode.longBreak;
              break;
            default:
              newMode = TimerMode.pomodoro;
          }
          widget.onModeChanged(newMode);
        },
        children: <Widget>[
          _buildModeIndicator(TimerMode.pomodoro, "Pomodoro"),
          _buildModeIndicator(TimerMode.shortBreak, "Short Break"),
          _buildModeIndicator(TimerMode.longBreak, "Long Break"),
        ],
      ),
    );
  }

  Widget _buildModeIndicator(TimerMode mode, String text) {
    bool isActive = widget.currentMode == mode;
    Color activeColor = TimerConfigManager.getConfig(mode).color; // Get color from your config

    return Center(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18, // Adjust as you like
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? activeColor.withOpacity(0.9) : Colors.white
              .withOpacity(0.7),
        ),
      ),
    );
  }
}
// ctrl z