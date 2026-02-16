import 'package:flutter/material.dart';
import '../../models/alert_model.dart';
import 'intervention_dialog.dart';
import 'package:shishu_suraksha/l10n/app_localizations.dart';

class AlertCard extends StatelessWidget {
  final AlertModel alert;

  const AlertCard({Key? key, required this.alert}) : super(key: key);

  Color get _riskColor {
    switch (alert.riskLevel) {
      case RiskLevel.high:
        return Colors.red;
      case RiskLevel.moderate:
        return Colors.orange;
      case RiskLevel.mild:
        return Colors.amber;
      case RiskLevel.normal:
        return Colors.green;
    }
  }

  String _getRiskLevelText(AppLocalizations t) {
    switch (alert.riskLevel) {
      case RiskLevel.high:
        return t.riskHigh;
      case RiskLevel.moderate:
        return t.riskModerate;
      case RiskLevel.mild:
        return t.riskMild;
      case RiskLevel.normal:
        return t.riskNormal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _riskColor.withValues(alpha: 0.3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Child Info with Avatar
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: _riskColor.withValues(alpha: 0.15),
                  child: Text(
                    alert.childName.isNotEmpty ? alert.childName[0] : '?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _riskColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.childName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${t.ageLabel}: ${alert.childAge}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '${t.idLabel}: ${alert.childId}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Risk Level Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _riskColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _riskColor, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    alert.riskEmoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getRiskLevelText(t),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _riskColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Category
            Text(
              '${t.categoryLabel}: ${alert.category}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                alert.description, // This description might come from backend/model. If it's static/enum based, it should be localized too.
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Recommended Action
            Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 18, color: Colors.teal[700]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    alert.recommendedAction, // Also potential for localization if static
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.teal[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Start Intervention Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => InterventionDialog(alert: alert),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _riskColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.medical_services, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      t.startIntervention,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
