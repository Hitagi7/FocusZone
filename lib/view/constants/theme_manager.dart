import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  static const String _themeKey = 'selectedThemeColor';
  
  // Theme colors
  static const Color darkMode = Colors.black;
  static const Color semiDarkMode = Color(0xFF37474F); // More greyish blue
  static const Color lightMode = Color(0xFFE0E0E0); // Colors.grey[300]
  
  // Get current theme color
  static Future<Color> getCurrentThemeColor() async {
    final prefs = await SharedPreferences.getInstance();
    final themeValue = prefs.getInt(_themeKey) ?? 0xFF000000; // Default to black
    return Color(themeValue);
  }
  
  // Save theme color
  static Future<void> saveThemeColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, color.value);
  }
  
  // Get theme colors based on selected theme
  static Map<String, Color> getThemeColors(Color selectedTheme) {
    // Compare by color value instead of object reference
    if (selectedTheme.value == darkMode.value) {
      return {
        'background': Colors.grey[900]!,
        'surface': Colors.grey[800]!,
        'primary': Colors.white,
        'secondary': Colors.grey[300]!,
        'text': Colors.white,
        'textSecondary': Colors.grey[400]!,
        'border': Colors.grey[700]!,
        'inputBackground': Colors.grey[800]!,
        'buttonBackground': Colors.grey[700]!,
      };
    } else if (selectedTheme.value == semiDarkMode.value) {
      return {
        'background': Color(0xFF37474F),
        'surface': Color(0xFF455A64),
        'primary': Colors.white,
        'secondary': Colors.grey[300]!,
        'text': Colors.white,
        'textSecondary': Colors.grey[400]!,
        'border': Color(0xFF546E7A),
        'inputBackground': Color(0xFF455A64),
        'buttonBackground': Color(0xFF546E7A),
      };
    } else { // lightMode
      return {
        'background': Colors.white,
        'surface': Colors.grey[100]!,
        'primary': Colors.black87,
        'secondary': Colors.grey[600]!,
        'text': Colors.black87,
        'textSecondary': Colors.grey[600]!,
        'border': Colors.grey[300]!,
        'inputBackground': Colors.grey[200]!,
        'buttonBackground': Colors.grey[300]!,
      };
    }
  }
} 