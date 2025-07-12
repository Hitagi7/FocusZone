import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

// App header with logo, title, and action buttons
class AppHeader extends StatelessWidget {
  const AppHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
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
              _buildHeaderButton(context, Icons.insert_chart_outlined, 'Report'),
              const SizedBox(width: 8),
              _buildHeaderButton(context, Icons.settings, 'Settings'),
            ],
          ),
        ],
      ),
    );
  }

  // Build header button with icon and label
  Widget _buildHeaderButton(BuildContext context, IconData icon, String label) {
    return TextButton.icon(
      onPressed: () {
        _showComingSoonDialog(context, label);
      },
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

  // Show coming soon dialog
  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext _) {
        return AlertDialog(
          title: Text(feature),
          content: Text('$feature feature coming soon!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}