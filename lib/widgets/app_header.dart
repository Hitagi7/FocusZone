import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Icon(
                Icons.timer,
                color: Colors.white,
                size: AppConstants.headerIconSize,
              ),
              SizedBox(width: 8),
              Text(
                AppConstants.appTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Navigation buttons
          Row(
            children: [
              _buildHeaderButton(context, Icons.insert_chart_outlined, 'Report'),
              SizedBox(width: 8),
              _buildHeaderButton(context, Icons.settings, 'Settings'),
              SizedBox(width: 8),
              _buildHeaderButton(context, Icons.account_circle, 'Login'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(BuildContext context, IconData icon, String label) {
    return TextButton.icon(
      onPressed: () {
        // Show overlay/modal instead of navigation
        _showOverlay(context, label);
      },
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void _showOverlay(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(feature),
          content: Text('$feature feature coming soon!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}