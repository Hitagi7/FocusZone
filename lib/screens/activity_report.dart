import 'package:flutter/material.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.close, size: 24 * scale),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10.0 * scale),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: const Color(0xFFF0B2B2),
                          borderRadius: BorderRadius.circular(10.0 * scale),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey[700],
                        labelStyle: TextStyle(fontSize: 14 * scale, fontWeight: FontWeight.bold),
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
        style: TextStyle(fontSize: 14 * scale, color: Colors.grey),
      ),
    );
  }

  Widget _buildSummaryTab(double scale) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Activity Summary',
            style: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.bold),
          ),
          _buildLoginMessage(scale),
          SizedBox(
            height: 120 * scale,
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10 * scale,
              crossAxisSpacing: 10 * scale,
              childAspectRatio: 1.2,
              children: [
                _buildSummaryCard(Icons.access_time, 'hours focused', scale),
                _buildSummaryCard(Icons.calendar_today, 'days accessed', scale),
              ],
            ),
          ),
          SizedBox(height: 10 * scale),
          Center(
            child: SizedBox(
              width: 140 * scale,
              child: _buildSummaryCard(Icons.local_fire_department, 'day streak', scale),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(IconData icon, String label, double scale) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4E4),
        borderRadius: BorderRadius.circular(10.0 * scale),
      ),
      padding: EdgeInsets.all(16.0 * scale),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30 * scale, color: const Color(0xFFF0B2B2)),
          SizedBox(height: 6 * scale),
          Text(
            '--',
            style: TextStyle(fontSize: 12 * scale, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12 * scale, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTab(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Focus Time Detail',
          style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.bold),
        ),
        _buildLoginMessage(scale),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Center(
                      child: DataTable(
                        columnSpacing: 16 * scale,
                        columns: [
                          DataColumn(label: Text('DATE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13 * scale))),
                          DataColumn(label: Text('PROJECT / TASK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13 * scale))),
                          DataColumn(label: Text('MINUTES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13 * scale))),
                        ],
                        rows: [
                          DataRow(cells: [
                            DataCell(Text('2023-10-26', style: TextStyle(fontSize: 12 * scale))),
                            DataCell(Text('Project Alpha', style: TextStyle(fontSize: 12 * scale))),
                            DataCell(Text('60', style: TextStyle(fontSize: 12 * scale))),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('2023-10-25', style: TextStyle(fontSize: 12 * scale))),
                            DataCell(Text('Task Beta', style: TextStyle(fontSize: 12 * scale))),
                            DataCell(Text('45', style: TextStyle(fontSize: 12 * scale))),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('2023-10-24', style: TextStyle(fontSize: 12 * scale))),
                            DataCell(Text('Meeting Prep', style: TextStyle(fontSize: 12 * scale))),
                            DataCell(Text('30', style: TextStyle(fontSize: 12 * scale))),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0 * scale),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, size: 20 * scale),
                      onPressed: () {
                        // Handle previous page
                      },
                    ),
                    Text('1', style: TextStyle(fontSize: 16 * scale, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios, size: 20 * scale),
                      onPressed: () {
                        // Handle next page
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
