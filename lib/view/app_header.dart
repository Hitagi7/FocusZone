import 'package:flutter/material.dart';
import 'constants/app_constants.dart';
import 'user_settings.dart';
import 'activity_report.dart';
import '../controller/task_controller.dart';

// App header with logo, title, and action buttons
class AppHeader extends StatelessWidget {
  final TaskController taskController;

  const AppHeader({super.key, required this.taskController});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final baseWidth = 390.0; // iPhone 12/13/14 width as a reference
    final scale = (screenWidth / baseWidth).clamp(0.8, 1.2);
    final padding = (16.0 * scale).clamp(8.0, 24.0);
    final iconSize = (32.0 * scale).clamp(20.0, 36.0);
    final titleFontSize = (24.0 * scale).clamp(16.0, 28.0);
    final buttonFontSize = (14.0 * scale).clamp(10.0, 18.0);
    final buttonIconSize = (20.0 * scale).clamp(14.0, 24.0);
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App logo and title
          Row(
            children: [
              Icon(Icons.timer, color: Colors.white, size: iconSize),
              SizedBox(width: 12 * scale),
              Text(
                AppConstants.appTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Noto Sans Display',
                ),
              ),
            ],
          ),
          // Action buttons
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              children: [
                _buildHeaderButton(
                  context,
                  Icons.insert_chart_outlined,
                  'Report',
                  () {
                    _showReportScreen(context);
                  },
                  buttonFontSize,
                  buttonIconSize,
                ),
                SizedBox(width: 8 * scale),
                _buildHeaderButton(
                  context,
                  Icons.settings,
                  'Settings',
                  () {
                    _showSettingsScreen(context);
                  },
                  buttonFontSize,
                  buttonIconSize,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build header button with icon and label
  Widget _buildHeaderButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed,
    double fontSize,
    double iconSize,
  ) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: iconSize),
      label: Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: fontSize),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  // Show report screen
  void _showReportScreen(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) {
        return ReportScreen(taskController: taskController);
      },
    );
  }

  // Show settings screen
  void _showSettingsScreen(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) {
        return const UserSettingsScreen();
      },
    );
  }
}
