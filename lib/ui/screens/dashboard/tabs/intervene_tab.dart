import 'package:flutter/material.dart';
import '../../../../services/alert_generator.dart';
import '../../../../models/alert_model.dart';
import '../../../widgets/alert_card.dart';

class InterveneTab extends StatefulWidget {
  const InterveneTab({Key? key}) : super(key: key);

  @override
  State<InterveneTab> createState() => _InterveneTabState();
}

class _InterveneTabState extends State<InterveneTab> {
  List<AlertModel> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  void _loadAlerts() {
    // Simulate loading delay for realistic UX
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _alerts = AlertGenerator.getMockAlerts();
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.teal),
          );
        }

        if (_alerts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: Colors.green[300],
                ),
                const SizedBox(height: 16),
                const Text(
                  'No alerts at this time',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'All children are being monitored.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Header Section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal[50]!, Colors.teal[100]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_active, color: Colors.teal[700], size: 28),
                          const SizedBox(width: 12),
                          const Text(
                            'Child Alerts',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_alerts.length} alert${_alerts.length != 1 ? 's' : ''} require${_alerts.length == 1 ? 's' : ''} attention',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Risk Level Summary Badges
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildRiskBadge(
                        '🔴 High Risk',
                        _alerts.where((a) => a.riskLevel == RiskLevel.high).length,
                        Colors.red,
                      ),
                      _buildRiskBadge(
                        '🟠 Moderate',
                        _alerts.where((a) => a.riskLevel == RiskLevel.moderate).length,
                        Colors.orange,
                      ),
                      _buildRiskBadge(
                        '🟡 Mild',
                        _alerts.where((a) => a.riskLevel == RiskLevel.mild).length,
                        Colors.amber,
                      ),
                      _buildRiskBadge(
                        '🟢 Normal',
                        _alerts.where((a) => a.riskLevel == RiskLevel.normal).length,
                        Colors.green,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Alert Cards List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _alerts.length,
                  itemBuilder: (context, index) {
                    return AlertCard(alert: _alerts[index]);
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRiskBadge(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color is MaterialColor ? (color as MaterialColor)[900] ?? color : color,
        ),
      ),
    );
  }
}
