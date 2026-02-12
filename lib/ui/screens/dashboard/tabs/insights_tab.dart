import 'package:flutter/material.dart';
import 'package:shishu_suraksha/services/analytics_service.dart';
import 'package:shishu_suraksha/models/dashboard_data.dart';
import 'package:shishu_suraksha/ui/widgets/kpi_card.dart';
import 'package:shishu_suraksha/ui/widgets/charts/risk_distribution_chart.dart';
import 'package:shishu_suraksha/ui/widgets/charts/assessment_trend_chart.dart';
import 'package:shishu_suraksha/ui/widgets/charts/age_distribution_chart.dart';
// Development score is implemented inline for simplicity 
import 'package:shishu_suraksha/ui/widgets/charts/intervention_outcome_chart.dart';

class InsightsTab extends StatefulWidget {
  const InsightsTab({Key? key}) : super(key: key);

  @override
  State<InsightsTab> createState() => _InsightsTabState();
}

class _InsightsTabState extends State<InsightsTab> {
  // State for filters
  String _selectedDateRange = 'Last 6 Months';
  String _selectedAgeGroup = 'All Ages';
  String _selectedCenter = 'Main Center';

  // Data
  late DashboardStats _stats;
  late RiskDistribution _riskData;
  late List<ChartDataPoint> _trendData;
  late List<ChartDataPoint> _ageData;
  late InterventionOutcome _interventionData;
  late Map<String, double> _devScores;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        final service = AnalyticsService();
        setState(() {
          _stats = service.getDashboardStats();
          _riskData = service.getRiskDistribution();
          _trendData = service.getAssessmentTrend();
          _ageData = service.getAgeDistribution();
          _interventionData = service.getInterventionOutcomes();
          _devScores = service.getDevelopmentScores();
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.teal));
    }

    return Scaffold(
      backgroundColor: Colors.transparent, // Inherit background from DashboardScreen
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1️⃣ Header & Filters
                  _buildHeaderAndFilters(),
                  const SizedBox(height: 20),

                  // 2️⃣ KPI Cards (Horizontal Scroll)
                  _buildKPISection(),
                  const SizedBox(height: 24),

                  // 3️⃣ Visualizations
                  _buildVisualizations(),
                  
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showExportOptions,
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.download, color: Colors.white),
        label: const Text("Export Report", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildHeaderAndFilters() {
    return Column(
      children: [
        Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             const Text(
               "Analytics Dashboard",
               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
             ),
           ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip("Date", _selectedDateRange, ["Last 30 Days", "Last 6 Months", "Last Year"]),
              const SizedBox(width: 8),
              _buildFilterChip("Age", _selectedAgeGroup, ["All Ages", "0-3 Years", "3-6 Years"]),
              const SizedBox(width: 8),
              _buildFilterChip("Center", _selectedCenter, ["Main Center", "North Wing", "East Wing"]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, List<String> options) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value.contains(options[0]) || options.contains(value) ? value : options[0], 
          isDense: true,
          items: options.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val, style: const TextStyle(fontSize: 12)),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                // Update state variable based on label (simplified logic for demo)
                if (label == "Date") _selectedDateRange = newValue;
                if (label == "Age") _selectedAgeGroup = newValue;
                if (label == "Center") _selectedCenter = newValue;
                _isLoading = true; // Simulate refresh
                _loadData(); // Reload mock data
              });
            }
          },
          icon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
        ),
      ),
    );
  }

  Widget _buildKPISection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          KPICard(
            title: "Total Assessed",
            value: "${_stats.totalAssessed}",
            icon: Icons.people,
            color: Colors.blue,
            trend: "+${_stats.totalAssessedChange}%",
          ),
          const SizedBox(width: 12),
          KPICard(
            title: "High Risk",
            value: "${_stats.highRisk}",
            icon: Icons.warning,
            color: Colors.red,
            trend: "${_stats.highRiskChange}%",
            isPositiveTrend: false, // Negative trend is good for risk
          ),
          const SizedBox(width: 12),
          KPICard(
            title: "Pending",
            value: "${_stats.pendingAssessments}",
            icon: Icons.pending_actions,
            color: Colors.orange,
          ),
          const SizedBox(width: 12),
          KPICard(
            title: "Completed",
            value: "${_stats.completedAssessments}",
            icon: Icons.check_circle,
            color: Colors.teal,
          ),
          const SizedBox(width: 12),
          KPICard(
            title: "Avg Dev Score",
            value: "${_stats.avgDevelopmentScore}%",
            icon: Icons.psychology,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildVisualizations() {
    // Keep it center aligned and responsive
    return Column(
      children: [
        // Row 1: Risk & Trend (Stack vertically on mobile, could row on tablet but let's stick to col for safety)
        RiskDistributionChart(data: _riskData),
        const SizedBox(height: 16),
        AssessmentTrendChart(data: _trendData),
        const SizedBox(height: 16),
        
        // Row 2: Age & Outcomes
        AgeDistributionChart(data: _ageData),
        const SizedBox(height: 16),
        InterventionOutcomeChart(data: _interventionData),
        const SizedBox(height: 16),

        // Development Score Overview (Manual implementation for simple bars)
        _buildDevelopmentScoreCard(),
      ],
    );
  }

  Widget _buildDevelopmentScoreCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Development Score Overview",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            _buildScoreBar("Cognitive", _devScores['Cognitive']!, Colors.purple),
            _buildScoreBar("Mobility", _devScores['Mobility']!, Colors.blue),
            _buildScoreBar("Hearing", _devScores['Hearing']!, Colors.orange),
            _buildScoreBar("Speech", _devScores['Speech']!, Colors.teal),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text("${value.toStringAsFixed(1)}%", style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: color.withOpacity(0.1),
              color: color,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(height: 4, width: 40, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text("Export Report", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text("Download PDF Report"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Downloading PDF Report..."), backgroundColor: Colors.teal),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text("Export CSV Data"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Exporting CSV Data..."), backgroundColor: Colors.teal),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
