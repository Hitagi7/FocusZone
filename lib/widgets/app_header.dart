import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../Screens/activity_report.dart'; // Import the Report screen

// App header with logo, title, and action buttons
class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App logo and title
          Row(
            children: [
              const Icon(
                Icons.timer,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                AppConstants.appTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansDisplay',
                ),
              ),
            ],
          ),

          // Action buttons
          Row(
            children: [
              // Modified to show ReportScreen as a dialog, overlapping the landing page.
              _buildHeaderButton(context, Icons.insert_chart_outlined, 'Report', () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const ReportScreen(); // ReportScreen is already designed as a Dialog
                  },
                );
              }),
              const SizedBox(width: 8),
              _buildHeaderButton(context, Icons.settings, 'Settings', () {
                _showComingSoonDialog(context, 'Settings');
              }),
            ],
          ),
        ],
      ),
    );
  }

  // Build header button with icon, label, and an onTap callback
  Widget _buildHeaderButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return TextButton.icon(
      onPressed: onTap, // Use the provided onTap callback
      icon: Icon(icon, color: Colors.white, size: 20),
      label: Text(
        label,
        style: const TextStyle(
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
