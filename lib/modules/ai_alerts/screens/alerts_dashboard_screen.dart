
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import '../services/alerts_service.dart';

class AlertsDashboardScreen extends StatefulWidget {
  const AlertsDashboardScreen({Key? key}) : super(key: key);

  @override
  _AlertsDashboardScreenState createState() => _AlertsDashboardScreenState();
}

class _AlertsDashboardScreenState extends State<AlertsDashboardScreen> {
  final AlertsService _alertsService = AlertsService();
  final String _schoolId = "DEMO_SCHOOL_01";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Risk Alerts"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Filter logic
            },
          )
        ],
      ),
      backgroundColor: Colors.grey[50], 
      body: StreamBuilder<List<AlertModel>>(
        stream: _alertsService.getAlerts(_schoolId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error loading alerts: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final alerts = snapshot.data!;
          
          if (alerts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text("No active alerts. Everything looks good!", 
                       style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            separatorBuilder: (c, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return _buildAlertCard(alert);
            },
          );
        },
      ),
    );
  }

  Widget _buildAlertCard(AlertModel alert) {
    final color = alert.severityColor;
    final icon = alert.typeIcon;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: alert.acknowledged ? Colors.grey : color, width: 6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 16,
                            decoration: alert.acknowledged ? TextDecoration.lineThrough : null,
                            color: alert.acknowledged ? Colors.grey : Colors.black87,
                          ),
                        ),
                        Text(
                          "Monitor: ${alert.childName ?? alert.childId}",
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  _formatTime(alert.timestamp),
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(),
            ),
            Text(
              alert.message,
              style: TextStyle(
                color: alert.acknowledged ? Colors.grey : Colors.black87, 
                height: 1.4
              ),
            ),
            if (alert.actionRecommendation != null && !alert.acknowledged) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Recommendation: ${alert.actionRecommendation}",
                  style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (alert.acknowledged)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      "Resolved by ${alert.acknowledgedBy}",
                      style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  )
                else ...[
                  TextButton(
                    onPressed: () {
                       _showDetails(alert);
                    },
                    style: TextButton.styleFrom(foregroundColor: color),
                    child: const Text("View Details"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _acknowledge(alert),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: const Text("Resolve"),
                  ),
                ],
              ],
            )
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${time.day}/${time.month}";
  }

  void _acknowledge(AlertModel alert) async {
    await _alertsService.acknowledgeAlert(_schoolId, alert.id, "Anganwadi Teacher");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Alert marked as resolved")),
    );
  }

  void _showDetails(AlertModel alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(alert.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Child: ${alert.childName ?? alert.childId}"),
            const SizedBox(height: 8),
            Text("Severity: ${alert.severityLabel}"),
            const SizedBox(height: 16),
            const Text("Detail Message:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(alert.message),
            if (alert.actionRecommendation != null) ...[
              const SizedBox(height: 16),
              const Text("AI Recommendation:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              Text(alert.actionRecommendation!),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }
}

