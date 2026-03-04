import 'package:flutter/material.dart';
import 'package:shishu_suraksha/l10n/generated/app_localizations.dart';
import 'package:shishu_suraksha/services/analytics_service.dart';
import 'package:shishu_suraksha/models/dashboard_data.dart';
import 'package:shishu_suraksha/ui/widgets/kpi_card.dart';
import 'package:shishu_suraksha/ui/widgets/charts/risk_distribution_chart.dart';
import 'package:shishu_suraksha/ui/widgets/charts/assessment_trend_chart.dart';
import 'package:shishu_suraksha/ui/widgets/charts/age_distribution_chart.dart';
import 'package:shishu_suraksha/ui/widgets/charts/intervention_outcome_chart.dart';
import '../../../../services/responsive_dashboard.dart';

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

    final responsive = ResponsiveDashboard(context);
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: responsive.contentPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header & Filters
                  _buildHeaderAndFilters(responsive, t),
                  SizedBox(height: responsive.getSpacing(20)),

                  // KPI Cards
                  _buildKPISection(responsive, t),
                  SizedBox(height: responsive.getSpacing(24)),

                  // Visualizations
                  _buildVisualizations(responsive, t),
                  
                  SizedBox(height: responsive.getSpacing(32)),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _showExportOptions(responsive),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.getSpacing(24),
                          vertical: responsive.getSpacing(12),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.download),
                      label: Text(
                        t.exportReport,
                        style: TextStyle(
                          fontSize: responsive.getFontSize(14),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: responsive.getSpacing(40)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAndFilters(ResponsiveDashboard responsive, AppLocalizations t) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t.analyticsDashboard,
              style: TextStyle(
                fontSize: responsive.getFontSize(24),
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.getSpacing(16)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(t.dateLabel, _selectedDateRange, [t.last30Days, t.last6Months, t.lastYear], responsive),
              SizedBox(width: responsive.getSpacing(8)),
              _buildFilterChip(t.ageGroups, _selectedAgeGroup, [t.allAges, t.years0to3, t.years3to6], responsive),
              SizedBox(width: responsive.getSpacing(8)),
              _buildFilterChip(t.centers, _selectedCenter, [t.mainCenter, t.northWing, t.eastWing], responsive),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, List<String> options, ResponsiveDashboard responsive) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.getSpacing(12),
        vertical: responsive.getSpacing(8),
      ),
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
              child: Text(
                val,
                style: TextStyle(fontSize: responsive.getFontSize(11)),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                if (label == "Date") _selectedDateRange = newValue;
                if (label == "Age") _selectedAgeGroup = newValue;
                if (label == "Center") _selectedCenter = newValue;
                _isLoading = true;
                _loadData();
              });
            }
          },
          icon: Icon(Icons.arrow_drop_down, color: Colors.teal, size: responsive.getFontSize(20)),
        ),
      ),
    );
  }

  Widget _buildKPISection(ResponsiveDashboard responsive, AppLocalizations t) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          KPICard(
            title: t.totalAssessed,
            value: "${_stats.totalAssessed}",
            icon: Icons.people,
            color: Colors.blue,
            trend: "+${_stats.totalAssessedChange}%",
          ),
          SizedBox(width: responsive.getSpacing(12)),
          KPICard(
            title: t.highRisk,
            value: "${_stats.highRisk}",
            icon: Icons.warning,
            color: Colors.red,
            trend: "${_stats.highRiskChange}%",
            isPositiveTrend: false,
          ),
          SizedBox(width: responsive.getSpacing(12)),
          KPICard(
            title: t.pending,
            value: "${_stats.pendingAssessments}",
            icon: Icons.pending_actions,
            color: Colors.orange,
          ),
          SizedBox(width: responsive.getSpacing(12)),
          KPICard(
            title: "Completed",
            value: "${_stats.completedAssessments}",
            icon: Icons.check_circle,
            color: Colors.teal,
          ),
          SizedBox(width: responsive.getSpacing(12)),
          KPICard(
            title: t.avgDevScore,
            value: "${_stats.avgDevelopmentScore}%",
            icon: Icons.psychology,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildVisualizations(ResponsiveDashboard responsive, AppLocalizations t) {
    return Column(
      children: [
        RiskDistributionChart(data: _riskData, t: t),
        SizedBox(height: responsive.getSpacing(16)),
        AssessmentTrendChart(data: _trendData, t: t),
        SizedBox(height: responsive.getSpacing(16)),
        AgeDistributionChart(data: _ageData, t: t),
        SizedBox(height: responsive.getSpacing(16)),
        InterventionOutcomeChart(data: _interventionData, t: t),
        SizedBox(height: responsive.getSpacing(16)),
        _buildDevelopmentScoreCard(responsive, t),
      ],
    );
  }

  Widget _buildDevelopmentScoreCard(ResponsiveDashboard responsive, AppLocalizations t) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: responsive.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.devScoreOverview,
              style: TextStyle(
                fontSize: responsive.getFontSize(16),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: responsive.getSpacing(20)),
            _buildScoreBar("Cognitive", _devScores['Cognitive']!, Colors.purple, responsive),
            _buildScoreBar("Mobility", _devScores['Mobility']!, Colors.blue, responsive),
            _buildScoreBar("Hearing", _devScores['Hearing']!, Colors.orange, responsive),
            _buildScoreBar("Speech", _devScores['Speech']!, Colors.teal, responsive),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBar(String label, double value, Color color, ResponsiveDashboard responsive) {
    return Padding(
      padding: EdgeInsets.only(bottom: responsive.getSpacing(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: responsive.getFontSize(13),
                ),
              ),
              Text(
                "${value.toStringAsFixed(1)}%",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: responsive.getFontSize(12),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.getSpacing(6)),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: color.withOpacity(0.1),
              color: color,
              minHeight: responsive.getSpacing(10),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportOptions(ResponsiveDashboard responsive) {
    final t = AppLocalizations.of(context)!;
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
            SizedBox(height: responsive.getSpacing(16)),
            Container(
              height: responsive.getSpacing(4),
              width: responsive.getSpacing(40),
              color: Colors.grey[300],
            ),
            SizedBox(height: responsive.getSpacing(16)),
            Text(
              t.exportReport,
              style: TextStyle(
                fontSize: responsive.getFontSize(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: responsive.getSpacing(20)),
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: Colors.red, size: responsive.getFontSize(24)),
              title: Text(
                t.downloadPdf,
                style: TextStyle(fontSize: responsive.getFontSize(13)),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      t.downloading,
                      style: TextStyle(fontSize: responsive.getFontSize(12)),
                    ),
                    backgroundColor: Colors.teal,
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.table_chart, color: Colors.green, size: responsive.getFontSize(24)),
              title: Text(
                t.exportCsv,
                style: TextStyle(fontSize: responsive.getFontSize(13)),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      t.exporting,
                      style: TextStyle(fontSize: responsive.getFontSize(12)),
                    ),
                    backgroundColor: Colors.teal,
                  ),
                );
              },
            ),
            SizedBox(height: responsive.getSpacing(30)),
          ],
        ),
      ),
    );
  }
}
