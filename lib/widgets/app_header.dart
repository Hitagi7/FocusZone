import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../screens/user_settings.dart';
import '../screens/activity_report.dart';

// App header with logo, title, and action buttons
class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
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
              Icon(
                Icons.timer,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                AppConstants.appTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Noto Sans Display',
                ),
              ),
            ],
          ),
          
          // Action buttons
          Row(
            children: [
              _buildHeaderButton(context, Icons.insert_chart_outlined, 'Report', () {
                _showReportScreen(context);
              }),
              const SizedBox(width: 8),
              _buildHeaderButton(context, Icons.settings, 'Settings', () {
                _showSettingsScreen(context);
              }),
            ],
          ),
        ],
      ),
    );
  }

  // Build header button with icon and label
  Widget _buildHeaderButton(BuildContext context, IconData icon, String label, VoidCallback onPressed) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 20),
      label: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  // Show report screen
  void _showReportScreen(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) {
        return const ReportScreen();
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