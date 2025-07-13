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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          clipBehavior: Clip.antiAlias,
          child: Container(
            width: 500.0,
            height: 600.0,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: const Color(0xFFF0B2B2),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[700],
                    tabs: const [
                      Tab(text: 'Summary'),
                      Tab(text: 'Detail'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSummaryTab(),
                      _buildDetailTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginMessage() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        '* This report will be available when you are logged in',
        style: TextStyle(fontSize: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Centered content horizontally
        children: [
          const Text(
            'Activity Summary',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          _buildLoginMessage(),

          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.0,
            children: [
              _buildSummaryCard(Icons.access_time, 'hours focused'),
              _buildSummaryCard(Icons.calendar_today, 'days accessed'),
              _buildSummaryCard(Icons.local_fire_department, 'day streak'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4E4),
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: const Color(0xFFF0B2B2)),
          const SizedBox(height: 8),
          const Text(
            '--',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Centered content horizontally
      children: [
        const Text(
          'Focus Time Detail',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        _buildLoginMessage(),

        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              // Wrapped DataTable in Center to horizontally center it if it doesn't fill the width
              child: Center(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('DATE', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('PROJECT / TASK', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('MINUTES', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: const [
                    DataRow(cells: [
                      DataCell(Text('2023-10-26')),
                      DataCell(Text('Project Alpha')),
                      DataCell(Text('60')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('2023-10-25')),
                      DataCell(Text('Task Beta')),
                      DataCell(Text('45')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('2023-10-24')),
                      DataCell(Text('Meeting Prep')),
                      DataCell(Text('30')),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  // Handle previous page
                },
              ),
              const Text('1', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  // Handle next page
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
