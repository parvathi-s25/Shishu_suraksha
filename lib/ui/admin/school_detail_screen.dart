import 'package:flutter/material.dart';
import '../../core/data/models/admin_models.dart';
import '../../core/data/services/admin_data_service.dart';
import 'package:fl_chart/fl_chart.dart';

class SchoolDetailScreen extends StatefulWidget { // Converted to StatefulWidget for data fetching
  final SchoolModel school;

  const SchoolDetailScreen({Key? key, required this.school}) : super(key: key);

  @override
  State<SchoolDetailScreen> createState() => _SchoolDetailScreenState();
}

class _SchoolDetailScreenState extends State<SchoolDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AdminDataService _dataService = AdminDataService();
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final students = await _dataService.getStudentsForSchool(widget.school.id);
    if (mounted) {
      setState(() {
        _students = students;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.school.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Students'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildStudentsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSchoolHeader(),
          const SizedBox(height: 20),
          _buildStatsGrid(),
          const SizedBox(height: 20),
          const Text('Developmental Domain Analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildAnalysisChart(),
          const SizedBox(height: 20),
          _buildReportButton(),
        ],
      ),
    );
  }

  Widget _buildStudentsTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final student = _students[index];
        final riskColor = _getRiskColor(student['riskLevel']);
        
        return Card(
           margin: const EdgeInsets.only(bottom: 8),
           child: ListTile(
             leading: CircleAvatar(
               backgroundColor: riskColor.withOpacity(0.1),
               child: Text(student['name'][0], style: TextStyle(color: riskColor, fontWeight: FontWeight.bold)),
             ),
             title: Text(student['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
             subtitle: Text('${student['gender']} • ${student['age']} Years'),
             trailing: Container(
               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
               decoration: BoxDecoration(
                 color: riskColor.withOpacity(0.1),
                 borderRadius: BorderRadius.circular(4),
                 border: Border.all(color: riskColor.withOpacity(0.5)),
               ),
               child: Text(student['riskLevel'] as String, style: TextStyle(color: riskColor, fontSize: 12, fontWeight: FontWeight.bold)),
             ),
           ),
        );
      },
    );
  }

  Color _getRiskColor(String level) {
    if (level == 'High') return Colors.red;
    if (level == 'Medium') return Colors.orange;
    return Colors.green;
  }

  // --- Components from original file ---

  Widget _buildSchoolHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: CircleAvatar(radius: 25, child: Text(widget.school.name[0])), 
          title: Text(widget.school.name, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
          subtitle: Text('${widget.school.district} • ID: ${widget.school.id}', overflow: TextOverflow.ellipsis),
          trailing: Container(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Chip(
              label: Text('Compliance: ${widget.school.complianceScore.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 10)),
              backgroundColor: widget.school.complianceScore > 90 ? Colors.green[100] : Colors.orange[100],
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildStatCard('Health Score', '${widget.school.averageHealthScore}', widget.school.averageHealthScore > 80 ? Colors.green : Colors.orange),
        _buildStatCard('Malnutrition', '${widget.school.malnutritionCount}', Colors.red),
        _buildStatCard('High Risk', '${widget.school.highRiskCount}', Colors.redAccent),
      ],
    );
  }
  
  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      width: 100, // Fixed width for wrap items
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(fontSize: 10, color: Colors.grey[700]), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildAnalysisChart() {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barGroups: [
            _buildBarGroup(0, 85, Colors.blue, 'Motor'),
            _buildBarGroup(1, 70, Colors.orange, 'Speech'),
            _buildBarGroup(2, 60, Colors.purple, 'Cognitive'),
            _buildBarGroup(3, 90, Colors.green, 'Social'),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0: return const Text('Motor', style: TextStyle(fontSize: 10));
                    case 1: return const Text('Speech', style: TextStyle(fontSize: 10));
                    case 2: return const Text('Cognitive', style: TextStyle(fontSize: 10));
                    case 3: return const Text('Social', style: TextStyle(fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
             topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color, String label) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: y, color: color, width: 16, borderRadius: BorderRadius.circular(4)),
      ],
    );
  }

  Widget _buildReportButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {
           _simulateReportGeneration(context);
        },
        icon: const Icon(Icons.download),
        label: const Text('DOWNLOAD SCHOOL HEALTH REPORT (PDF)'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      ),
    );
  }
  
  void _simulateReportGeneration(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Generating AI Health Report...'),
              Text('Aggregating Data...', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [const Icon(Icons.check_circle, color: Colors.white), const SizedBox(width: 8), Text('Report Downloaded: ${widget.school.id}_report.pdf')]),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }
}
