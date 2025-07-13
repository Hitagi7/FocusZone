import 'package:flutter/material.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  // Timer settings
  final TextEditingController _pomodoroTimeController = TextEditingController(text: '25');
  final TextEditingController _shortBreakTimeController = TextEditingController(text: '5');
  final TextEditingController _longBreakTimeController = TextEditingController(text: '15');
  bool _autoStartBreaks = false;
  bool _autoStartPomodoros = false;
  final TextEditingController _longBreakIntervalController = TextEditingController(text: '4');

  // Sound settings
  String _alarmSound = 'Kitchen';
  double _alarmVolume = 50;
  int _alarmRepeat = 1;
  String _tickingSound = 'None';
  double _tickingVolume = 50;

  // Theme settings
  Color _selectedThemeColor = Colors.red; // Default selected color
  String _hourFormat = '24-hour';
  bool _darkModeWhenRunning = false;

  // Notification settings
  String _reminderTime = 'Last';
  final TextEditingController _reminderMinutesController = TextEditingController(text: '5');

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
    return Scaffold(
      backgroundColor: Colors.transparent, // Keeps background transparent for modal effect
      body: Center(
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          clipBehavior: Clip.antiAlias,
          child: Container(
            width: 550.0, // Adjusted width for settings content
            height: 700.0, // Adjusted height for settings content
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header with title and close button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'SETTING',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(), // Separator below header

                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TIMER Section
                          _buildSectionHeader(Icons.timer, 'TIMER'),
                          const SizedBox(height: 16),
                          _buildTimeInputRow(),
                          const SizedBox(height: 20),
                          _buildToggleSetting('Auto Start Breaks', _autoStartBreaks, (bool value) {
                            setState(() {
                              _autoStartBreaks = value;
                            });
                          }),
                          _buildToggleSetting('Auto Start Pomodoros', _autoStartPomodoros, (bool value) {
                            setState(() {
                              _autoStartPomodoros = value;
                            });
                          }),
                          _buildTextInputSetting('Long Break interval', _longBreakIntervalController),
                          const SizedBox(height: 20),
                          const Divider(),

                          // SOUND Section
                          _buildSectionHeader(Icons.volume_up, 'SOUND'),
                          _buildDropdownSetting('Alarm Sound', _alarmSound, ['Kitchen', 'Bell', 'Digital'], (String? newValue) {
                            setState(() {
                              _alarmSound = newValue!;
                            });
                          }),
                          _buildSliderSetting(_alarmVolume, (double value) {
                            setState(() {
                              _alarmVolume = value;
                            });
                          }, 'repeat', _alarmRepeat.toString(), (String? newValue) {
                            setState(() {
                              _alarmRepeat = int.tryParse(newValue!) ?? 1;
                            });
                          }),
                          _buildDropdownSetting('Ticking Sound', _tickingSound, ['None', 'Tick', 'Metronome'], (String? newValue) {
                            setState(() {
                              _tickingSound = newValue!;
                            });
                          }),
                          _buildSliderSetting(_tickingVolume, (double value) {
                            setState(() {
                              _tickingVolume = value;
                            });
                          }),
                          const SizedBox(height: 20),
                          const Divider(),

                          // THEME Section
                          _buildSectionHeader(Icons.edit, 'THEME'),
                          _buildColorThemeSetting(),
                          _buildDropdownSetting('Hour Format', _hourFormat, ['24-hour', '12-hour'], (String? newValue) {
                            setState(() {
                              _hourFormat = newValue!;
                            });
                          }),
                          _buildToggleSetting('Dark Mode when running', _darkModeWhenRunning, (bool value) {
                            setState(() {
                              _darkModeWhenRunning = value;
                            });
                          }),
                          _buildSmallWindowSetting(),
                          const SizedBox(height: 20),
                          const Divider(),

                          // NOTIFICATION Section
                          _buildSectionHeader(Icons.notifications, 'NOTIFICATION'),
                          _buildReminderSetting(),
                          _buildMobileAlarmSetting(),
                          const SizedBox(height: 20),
                          const Divider(),

                          // OK Button at the bottom
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close settings
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[800], // Dark grey background
                                foregroundColor: Colors.white, // White text color
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('OK'),
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

  // Helper to build section headers
  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  // Helper to build time input row (Pomodoro, Short Break, Long Break)
  Widget _buildTimeInputRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildLabeledTimeInput('Pomodoro', _pomodoroTimeController)),
        const SizedBox(width: 16),
        Expanded(child: _buildLabeledTimeInput('Short Break', _shortBreakTimeController)),
        const SizedBox(width: 16),
        Expanded(child: _buildLabeledTimeInput('Long Break', _longBreakTimeController)),
      ],
    );
  }

  // Helper for individual time input field
  Widget _buildLabeledTimeInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Helper to build a toggle setting (Switch)
  Widget _buildToggleSetting(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.red, // Active color for the switch
          ),
        ],
      ),
    );
  }

  // Helper to build a text input setting
  Widget _buildTextInputSetting(String label, TextEditingController controller, {bool showInfo = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 16)),
              if (showInfo)
                const Padding(
                  padding: EdgeInsets.only(left: 4.0),
                  child: Icon(Icons.info_outline, size: 16, color: Colors.grey),
                ),
            ],
          ),
          SizedBox(
            width: 80, // Fixed width for the input field
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build a dropdown setting
  Widget _buildDropdownSetting(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                onChanged: onChanged,
                items: items.map<DropdownMenuItem<String>>((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build a slider setting with optional repeat input
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

  // Helper to build color theme selection
  Widget _buildColorThemeSetting() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Color Themes', style: TextStyle(fontSize: 16)),
          Row(
            children: [
              _buildColorCircle(Colors.red, _selectedThemeColor == Colors.red),
              _buildColorCircle(Colors.teal, _selectedThemeColor == Colors.teal),
              _buildColorCircle(Colors.blue, _selectedThemeColor == Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  // Helper for individual color circle
  Widget _buildColorCircle(Color color, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedThemeColor = color;
        });
      },
      child: Container(
        width: 30,
        height: 30,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
        ),
      ),
    );
  }

  // Helper for "Small Window" button
  Widget _buildSmallWindowSetting() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Small Window', style: TextStyle(fontSize: 16)),
          OutlinedButton.icon(
            onPressed: () {
              // Handle "Open" action for small window
            },
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Open'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for Reminder setting
  Widget _buildReminderSetting() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Reminder', style: TextStyle(fontSize: 16)),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _reminderTime,
                    onChanged: (String? newValue) {
                      setState(() {
                        _reminderTime = newValue!;
                      });
                    },
                    items: <String>['Last', 'Every'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: TextField(
                  controller: _reminderMinutesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 8),
              const Text('min', style: TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  // Helper for Mobile Alarm setting
  Widget _buildMobileAlarmSetting() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('Mobile Alarm', style: TextStyle(fontSize: 16)),
              const Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Icon(Icons.info_outline, size: 16, color: Colors.grey),
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              // Handle "Add this device" action
            },
            child: const Text('+ Add this device', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
