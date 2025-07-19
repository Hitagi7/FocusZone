import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/theme_manager.dart';
import '../controllers/task_controller.dart';

class ReportScreen extends StatefulWidget {
  final TaskController taskController;
  
  const ReportScreen({super.key, required this.taskController});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, Color> _themeColors = {};

  // Activity data
  int _hoursFocused = 0;
  int _daysAccessed = 0;
  int _dayStreak = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        // Refresh data when Summary tab is selected
        _loadActivityData();
      }
    });
    _loadThemeSettings();
    _loadActivityData();
    
    // Listen to task changes
    widget.taskController.addListener(() {
      if (mounted) {
        setState(() {
          // Trigger rebuild when tasks change
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload activity data when the screen becomes visible
    _loadActivityData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    widget.taskController.removeListener(() {});
    super.dispose();
  }

  Future<void> _loadThemeSettings() async {
    final currentTheme = await ThemeManager.getCurrentThemeColor();
    setState(() {
      _themeColors = ThemeManager.getThemeColors(currentTheme);
    });
  }

  Future<void> _loadActivityData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Debug: Check all stored values
    final allKeys = prefs.getKeys();
    print('All SharedPreferences keys: $allKeys');
    
    final minutesFocused = prefs.getInt('hoursFocused') ?? 0;
    final daysAccessed = prefs.getInt('daysAccessed') ?? 0;
    final dayStreak = prefs.getInt('dayStreak') ?? 0;
    
    print('Raw data from SharedPreferences:');
    print('hoursFocused: ${prefs.getInt('hoursFocused')}');
    print('daysAccessed: ${prefs.getInt('daysAccessed')}');
    print('dayStreak: ${prefs.getInt('dayStreak')}');
    
    setState(() {
      _hoursFocused = minutesFocused;
      _daysAccessed = daysAccessed;
      _dayStreak = dayStreak;
    });
    print('Activity Data Loaded: $_hoursFocused minutes, $_daysAccessed days, $_dayStreak streak');
  }





  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final scale = screenWidth / 400.0;
    final dialogWidth = screenWidth * 0.95 > 500 ? 500.0 : screenWidth * 0.95;
    final dialogHeight = screenHeight * 0.90 > 600 ? 600.0 : screenHeight * 0.90;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0 * scale)),
            clipBehavior: Clip.antiAlias,
            child: Container(
              width: dialogWidth,
              height: dialogHeight,
              padding: EdgeInsets.all(16.0 * scale),
              color: _themeColors['background'] ?? Colors.white,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(
                          Icons.close, 
                          size: 24 * scale,
                          color: _themeColors['text'] ?? Colors.black87,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    Container(
                      decoration: BoxDecoration(
                        color: _themeColors['inputBackground'] ?? Colors.grey[200],
                        borderRadius: BorderRadius.circular(10.0 * scale),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: UnderlineTabIndicator(
                          borderSide: BorderSide(
                            color: _themeColors['primary'] ?? Colors.blue,
                            width: 3 * scale,
                          ),
                          insets: EdgeInsets.symmetric(horizontal: 24 * scale),
                        ),
                        labelColor: _themeColors['primary'] ?? Colors.blue,
                        unselectedLabelColor: _themeColors['textSecondary'] ?? Colors.grey[700],
                        labelStyle: TextStyle(fontSize: 14 * scale, fontWeight: FontWeight.bold),
                        unselectedLabelStyle: TextStyle(fontSize: 14 * scale, fontWeight: FontWeight.normal),
                        tabs: [
                          Tab(text: 'Summary'),
                          Tab(text: 'Detail'),
                        ],
                      ),
                    ),
                    SizedBox(height: 20 * scale),
                    SizedBox(
                      height: dialogHeight * 0.7,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildSummaryTab(scale),
                          _buildDetailTab(scale),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginMessage(double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0 * scale),
      child: Text(
        ' ',
        style: TextStyle(
          fontSize: 14 * scale, 
          color: _themeColors['textSecondary'] ?? Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSummaryTab(double scale) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = 4.0 * scale * 2; // left + right
    final cardSpacing = 12 * scale;
    final cardWidth = (screenWidth - horizontalPadding - cardSpacing) / 2;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0 * scale, horizontal: 4.0 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Activity Summary',
            style: TextStyle(
              fontSize: 20 * scale, 
              fontWeight: FontWeight.bold,
              color: _themeColors['text'] ?? Colors.black87,
            ),
          ),
          _buildLoginMessage(scale),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(Icons.access_time, 'minutes focused', scale),
              ),
              SizedBox(width: cardSpacing),
              Expanded(
                child: _buildSummaryCard(Icons.calendar_today, 'days accessed', scale),
              ),
            ],
          ),
          SizedBox(height: 16 * scale),
          Row(
            children: [
              Spacer(),
              SizedBox(
                width: cardWidth,
                child: _buildSummaryCard(Icons.local_fire_department, 'day streak', scale),
              ),
              Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(IconData icon, String label, double scale) {
    // Determine which value to show based on the label
    int value;
    switch (label) {
      case 'minutes focused':
        value = _hoursFocused;
        break;
      case 'days accessed':
        value = _daysAccessed;
        break;
      case 'day streak':
        value = _dayStreak;
        break;
      default:
        value = 0;
    }
    
    return Container(
      decoration: BoxDecoration(
        color: _themeColors['surface'] ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(10.0 * scale),
        border: Border.all(
          color: _themeColors['border'] ?? Colors.grey[300]!,
          width: 1 * scale,
        ),
      ),
      padding: EdgeInsets.all(12.0 * scale),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28 * scale, color: _themeColors['primary'] ?? Colors.blue),
          SizedBox(height: 8 * scale),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 14 * scale, 
              fontWeight: FontWeight.bold, 
              color: _themeColors['text'] ?? Colors.black87,
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11 * scale, 
              color: _themeColors['textSecondary'] ?? Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTab(double scale) {
    final tasks = widget.taskController.allTasksSorted;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0 * scale, vertical: 8.0 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Focus Time Detail',
            style: TextStyle(
              fontSize: 18 * scale, 
              fontWeight: FontWeight.bold,
              color: _themeColors['text'] ?? Colors.black87,
            ),
          ),
          _buildLoginMessage(scale),
          if (tasks.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0 * scale),
              child: Text(
                'No tasks added yet. Add tasks from the main screen!',
                style: TextStyle(
                  fontSize: 14 * scale,
                  color: _themeColors['textSecondary'] ?? Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 32 * scale,
                dataTextStyle: TextStyle(
                  fontSize: 14 * scale,
                  color: _themeColors['text'] ?? Colors.black87,
                ),
                headingTextStyle: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 15 * scale,
                  color: _themeColors['text'] ?? Colors.black87,
                ),
                columns: [
                  DataColumn(label: Text('DATE')),
                  DataColumn(label: Text('TASK NAME')),
                  DataColumn(label: Text('MINUTES')),
                ],
                rows: tasks.map((task) {
                  final date = task.createdAt;
                  final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  
                  return DataRow(cells: [
                    DataCell(Text(dateString)),
                    DataCell(Text(task.title)),
                    DataCell(Text(task.minutesSpent.toString())),
                  ]);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
