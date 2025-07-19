import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/timer_config.dart';
import '../main.dart';
import '../constants/theme_manager.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  // Timer settings
  final TextEditingController _pomodoroTimeController = TextEditingController(text: '25');
  final TextEditingController _shortBreakTimeController = TextEditingController(text: '5');
  final TextEditingController _longBreakTimeController = TextEditingController(text: '20');
  bool _autoStartBreaks = false;
  bool _autoStartPomodoros = false;
  final TextEditingController _longBreakIntervalController = TextEditingController(text: '4');
  int _longBreakInterval = 4;

  // Theme settings
  Color _selectedThemeColor = Colors.black; // Default selected color (dark mode)
  Map<String, Color> _themeColors = {};

  // Timer format settings
  String _timerFormat = 'minutes';

  // Notification settings
  String _reminderTime = 'Off';
  final TextEditingController _reminderMinutesController = TextEditingController(text: '5');

  @override
  void initState() {
    super.initState();
    _loadTimerSettings();
    _loadAutoStartSettings();
    _loadLongBreakInterval();
    _loadThemeSettings();
    _loadTimerFormat();
    _loadReminderSettings();
  }

  Future<void> _loadTimerSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final pomodoro = prefs.getInt('pomodoroTime') ?? 25;
    final shortBreak = prefs.getInt('shortBreakTime') ?? 5;
    final longBreak = prefs.getInt('longBreakTime') ?? 20;
    setState(() {
      _pomodoroTimeController.text = pomodoro.toString();
      _shortBreakTimeController.text = shortBreak.toString();
      _longBreakTimeController.text = longBreak.toString();
    });
    TimerConfigManager.updateAllConfigs(
      pomodoro: pomodoro * 60,
      shortBreak: shortBreak * 60,
      longBreak: longBreak * 60,
    );
  }

  Future<void> _loadAutoStartSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoStartBreaks = prefs.getBool('autoStartBreaks') ?? false;
      _autoStartPomodoros = prefs.getBool('autoStartPomodoros') ?? false;
    });
  }

  Future<void> _saveAutoStartSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoStartBreaks', _autoStartBreaks);
    await prefs.setBool('autoStartPomodoros', _autoStartPomodoros);
  }

  Future<void> _loadLongBreakInterval() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _longBreakInterval = prefs.getInt('longBreakInterval') ?? 4;
      _longBreakIntervalController.text = _longBreakInterval.toString();
    });
    landingPageKey.currentState?.timerController.longBreakInterval = _longBreakInterval;
  }

  Future<void> _loadThemeSettings() async {
    final currentTheme = await ThemeManager.getCurrentThemeColor();
    setState(() {
      _selectedThemeColor = currentTheme;
      _themeColors = ThemeManager.getThemeColors(currentTheme);
    });
  }

  Future<void> _loadTimerFormat() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _timerFormat = prefs.getString('timerFormat') ?? 'minutes';
    });
  }

  Future<void> _saveLongBreakInterval() async {
    final prefs = await SharedPreferences.getInstance();
    final interval = int.tryParse(_longBreakIntervalController.text) ?? 4;
    await prefs.setInt('longBreakInterval', interval);
    _longBreakInterval = interval;
    landingPageKey.currentState?.timerController.longBreakInterval = interval;
  }

  Future<void> _saveTimerFormat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('timerFormat', _timerFormat);
  }

  Future<void> _loadReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _reminderTime = prefs.getString('reminderTime') ?? 'Off';
      _reminderMinutesController.text = (prefs.getInt('reminderMinutes') ?? 5).toString();
    });
  }

  Future<void> _saveReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reminderTime', _reminderTime);
    final minutes = int.tryParse(_reminderMinutesController.text) ?? 5;
    await prefs.setInt('reminderMinutes', minutes);
  }

  Future<void> _saveTimerSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final pomodoro = int.tryParse(_pomodoroTimeController.text) ?? 25;
    final shortBreak = int.tryParse(_shortBreakTimeController.text) ?? 5;
    final longBreak = int.tryParse(_longBreakTimeController.text) ?? 20;
    if (pomodoro < 1 || shortBreak < 1 || longBreak < 1) {
      _showInvalidDurationDialog();
      return;
    }
    await prefs.setInt('pomodoroTime', pomodoro);
    await prefs.setInt('shortBreakTime', shortBreak);
    await prefs.setInt('longBreakTime', longBreak);
    TimerConfigManager.updateAllConfigs(
      pomodoro: pomodoro * 60,
      shortBreak: shortBreak * 60,
      longBreak: longBreak * 60,
    );
    // Update timer immediately
    landingPageKey.currentState?.updateTimerDurationFromSettings();
    // Save auto start toggles as well
    await _saveAutoStartSettings();
    // Save long break interval as well
    await _saveLongBreakInterval();
    // Save timer format as well
    await _saveTimerFormat();
    // Save reminder settings as well
    await _saveReminderSettings();
  }

  void _showInvalidDurationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invalid Duration'),
        content: const Text('All timer durations must be at least 1 minute.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pomodoroTimeController.dispose();
    _shortBreakTimeController.dispose();
    _longBreakTimeController.dispose();
    _longBreakIntervalController.dispose();
    _reminderMinutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final scale = screenWidth / 400.0; // 400 is a typical mobile width
    final dialogWidth = screenWidth * 0.95 > 550 ? 550.0 : screenWidth * 0.95;
    final dialogHeight = screenHeight * 0.95 > 700 ? 700.0 : screenHeight * 0.95;
    return Scaffold(
      backgroundColor: Colors.transparent, // Keeps background transparent for modal effect
      body: Center(
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0 * scale)),
          clipBehavior: Clip.antiAlias,
          child: Container(
            width: dialogWidth,
            height: dialogHeight,
            padding: EdgeInsets.all(16.0 * scale),
            color: _themeColors['background'] ?? Colors.white,
            child: Column(
              children: [
                // Header with title and close button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0 * scale, vertical: 4.0 * scale),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SETTING',
                        style: TextStyle(
                          fontSize: 18 * scale, 
                          fontWeight: FontWeight.bold,
                          color: _themeColors['text'] ?? Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close, 
                          size: 24 * scale,
                          color: _themeColors['text'] ?? Colors.black87,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                    ],
                  ),
                ),
                Divider(
                  thickness: 1 * scale,
                  color: _themeColors['border'] ?? Colors.grey[300],
                ), // Separator below header
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(8.0 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(Icons.timer, 'TIMER', scale),
                          SizedBox(height: 16 * scale),
                          _buildTimeInputRow(scale),
                          SizedBox(height: 20 * scale),
                          _buildToggleSetting('Auto Start Breaks', _autoStartBreaks, (bool value) {
                            setState(() {
                              _autoStartBreaks = value;
                            });
                            _saveAutoStartSettings();
                            landingPageKey.currentState?.timerController.autoStartBreaks = value;
                          }, scale),
                          _buildToggleSetting('Auto Start Pomodoros', _autoStartPomodoros, (bool value) {
                            setState(() {
                              _autoStartPomodoros = value;
                            });
                            _saveAutoStartSettings();
                            landingPageKey.currentState?.timerController.autoStartPomodoros = value;
                          }, scale),
                          _buildTextInputSetting('Long Break interval', _longBreakIntervalController, scale: scale),
                          _buildDropdownSetting('Format', _timerFormat, ['minutes', 'hours'], (String? newValue) async {
                            setState(() {
                              _timerFormat = newValue!;
                            });
                            await _saveTimerFormat();
                            // Force rebuild of timer display to update format
                            landingPageKey.currentState?.setState(() {});
                          }, scale),
                          SizedBox(height: 20 * scale),
                          Divider(
                            thickness: 1 * scale,
                            color: _themeColors['border'] ?? Colors.grey[300],
                          ),
                          _buildSectionHeader(Icons.edit, 'THEME', scale),
                          _buildColorThemeSetting(scale),
                          SizedBox(height: 20 * scale),
                          Divider(
                            thickness: 1 * scale,
                            color: _themeColors['border'] ?? Colors.grey[300],
                          ),
                          _buildSectionHeader(Icons.notifications, 'NOTIFICATION', scale),
                          _buildReminderSetting(scale),
                          SizedBox(height: 20 * scale),
                          Divider(
                            thickness: 1 * scale,
                            color: _themeColors['border'] ?? Colors.grey[300],
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () async {
                                await _saveTimerSettings();
                                Navigator.of(context).pop(); // Close settings
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _themeColors['buttonBackground'] ?? Colors.grey[800],
                                foregroundColor: _themeColors['primary'] ?? Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 12 * scale),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8 * scale),
                                ),
                              ),
                              child: Text(
                                'OK', 
                                style: TextStyle(
                                  fontSize: 16 * scale,
                                  color: _themeColors['primary'] ?? Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0 * scale),
      child: Row(
        children: [
          Icon(icon, size: 20 * scale, color: _themeColors['textSecondary'] ?? Colors.grey[700]),
          SizedBox(width: 8 * scale),
          Text(
            title,
            style: TextStyle(
              fontSize: 16 * scale, 
              fontWeight: FontWeight.bold, 
              color: _themeColors['textSecondary'] ?? Colors.grey[700]
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInputRow(double scale) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildLabeledTimeInput('Pomodoro', _pomodoroTimeController, scale)),
        SizedBox(width: 16 * scale),
        Expanded(child: _buildLabeledTimeInput('Short Break', _shortBreakTimeController, scale)),
        SizedBox(width: 16 * scale),
        Expanded(child: _buildLabeledTimeInput('Long Break', _longBreakTimeController, scale)),
      ],
    );
  }

  Widget _buildLabeledTimeInput(String label, TextEditingController controller, double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14 * scale, color: _themeColors['text'] ?? Colors.black87),
        ),
        SizedBox(height: 4 * scale),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8 * scale),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: _themeColors['inputBackground'] ?? Colors.grey[200],
            contentPadding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 8 * scale),
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16 * scale, 
            fontWeight: FontWeight.bold,
            color: _themeColors['text'] ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleSetting(String label, bool value, ValueChanged<bool> onChanged, double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: TextStyle(
              fontSize: 16 * scale,
              color: _themeColors['text'] ?? Colors.black87,
            ),
          ),
          Transform.scale(
            scale: scale.clamp(0.8, 1.2),
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: _selectedThemeColor == ThemeManager.lightMode 
                ? Colors.green[600]! 
                : _themeColors['primary'] ?? Colors.white,
              activeTrackColor: _selectedThemeColor == ThemeManager.semiDarkMode 
                ? Colors.blue[300]! 
                : _selectedThemeColor == ThemeManager.lightMode
                  ? Colors.green[200]!
                  : _selectedThemeColor.withValues(alpha: 0.3),
              inactiveThumbColor: _selectedThemeColor == ThemeManager.lightMode 
                ? Colors.grey[500]! 
                : _themeColors['textSecondary'] ?? Colors.grey[400],
              inactiveTrackColor: _selectedThemeColor == ThemeManager.lightMode 
                ? Colors.grey[400]! 
                : _themeColors['border'] ?? Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputSetting(String label, TextEditingController controller, {bool showInfo = false, double scale = 1.0}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                label, 
                style: TextStyle(
                  fontSize: 16 * scale,
                  color: _themeColors['text'] ?? Colors.black87,
                ),
              ),
              if (showInfo)
                Padding(
                  padding: EdgeInsets.only(left: 4.0 * scale),
                  child: Icon(
                    Icons.info_outline, 
                    size: 16 * scale, 
                    color: _themeColors['textSecondary'] ?? Colors.grey,
                  ),
                ),
            ],
          ),
          SizedBox(
            width: 80 * scale,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8 * scale),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: _themeColors['inputBackground'] ?? Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 8 * scale),
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16 * scale,
                color: _themeColors['text'] ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSetting(String label, String value, List<String> items, ValueChanged<String?> onChanged, double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: TextStyle(
              fontSize: 16 * scale,
              color: _themeColors['text'] ?? Colors.black87,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 4 * scale),
            decoration: BoxDecoration(
              color: _themeColors['inputBackground'] ?? Colors.grey[200],
              borderRadius: BorderRadius.circular(8 * scale),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                onChanged: onChanged,
                dropdownColor: _themeColors['surface'] ?? Colors.grey[100],
                items: items.map<DropdownMenuItem<String>>((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(
                        color: _themeColors['text'] ?? Colors.black87,
                        fontSize: 16 * scale,
                      ),
                    ),
                  );
                }).toList(),
                style: TextStyle(
                  fontSize: 16 * scale, 
                  color: _themeColors['text'] ?? Colors.black87,
                ),
                icon: Icon(
                  Icons.arrow_drop_down, 
                  color: _themeColors['textSecondary'] ?? Colors.grey, 
                  size: 24 * scale,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting(double value, ValueChanged<double> onChanged, [String? suffixLabel, String? suffixValue, ValueChanged<String?>? onSuffixChanged]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Slider(
              value: value,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: onChanged,
              activeColor: Colors.red,
              inactiveColor: Colors.grey[300],
            ),
          ),
          if (suffixLabel != null && suffixValue != null && onSuffixChanged != null)
            Row(
              children: [
                const SizedBox(width: 10),
                Text(suffixLabel, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                SizedBox(
                  width: 50,
                  child: TextField(
                    controller: TextEditingController(text: suffixValue),
                    keyboardType: TextInputType.number,
                    onChanged: onSuffixChanged,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildColorThemeSetting(double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Color Themes', 
            style: TextStyle(
              fontSize: 16 * scale,
              color: _themeColors['text'] ?? Colors.black87,
            ),
          ),
          Row(
            children: [
              _buildColorCircle(ThemeManager.darkMode, _selectedThemeColor.value == ThemeManager.darkMode.value, scale),
              _buildColorCircle(ThemeManager.semiDarkMode, _selectedThemeColor.value == ThemeManager.semiDarkMode.value, scale),
              _buildColorCircle(ThemeManager.lightMode, _selectedThemeColor.value == ThemeManager.lightMode.value, scale),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorCircle(Color color, bool isSelected, double scale) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          _selectedThemeColor = color;
          _themeColors = ThemeManager.getThemeColors(color);
        });
        await ThemeManager.saveThemeColor(color);
      },
      child: Container(
        width: 30 * scale,
        height: 30 * scale,
        margin: EdgeInsets.symmetric(horizontal: 4 * scale),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.black, width: 2 * scale) : null,
        ),
      ),
    );
  }



  Widget _buildReminderSetting(double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Reminder', 
            style: TextStyle(
              fontSize: 16 * scale,
              color: _themeColors['text'] ?? Colors.black87,
            ),
          ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
                decoration: BoxDecoration(
                  color: _themeColors['inputBackground'] ?? Colors.grey[200],
                  borderRadius: BorderRadius.circular(8 * scale),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _reminderTime,
                    onChanged: (String? newValue) async {
                      setState(() {
                        _reminderTime = newValue!;
                      });
                      await _saveReminderSettings();
                    },
                    dropdownColor: _themeColors['surface'] ?? Colors.grey[100],
                    items: <String>['Off', 'Last', 'Every'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: _themeColors['text'] ?? Colors.black87,
                            fontSize: 16 * scale,
                          ),
                        ),
                      );
                    }).toList(),
                    style: TextStyle(
                      fontSize: 16 * scale, 
                      color: _themeColors['text'] ?? Colors.black87,
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down, 
                      color: _themeColors['textSecondary'] ?? Colors.grey, 
                      size: 24 * scale,
                    ),
                  ),
                ),
              ),
              if (_reminderTime != 'Off') ...[
                SizedBox(width: 8 * scale),
                SizedBox(
                  width: 60 * scale,
                  child: TextField(
                    controller: _reminderMinutesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8 * scale),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: _themeColors['inputBackground'] ?? Colors.grey[200],
                      contentPadding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 8 * scale),
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16 * scale,
                      color: _themeColors['text'] ?? Colors.black87,
                    ),
                  ),
                ),
                SizedBox(width: 8 * scale),
                Text(
                  'min', 
                  style: TextStyle(
                    fontSize: 16 * scale,
                    color: _themeColors['text'] ?? Colors.black87,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }


}
