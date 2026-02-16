import 'package:flutter/material.dart';
import 'dart:ui';
import '../../models/alert_model.dart';
import 'package:shishu_suraksha/l10n/app_localizations.dart';

class InterventionDialog extends StatefulWidget {
  final AlertModel alert;

  const InterventionDialog({Key? key, required this.alert}) : super(key: key);

  @override
  State<InterventionDialog> createState() => _InterventionDialogState();
}

class _InterventionDialogState extends State<InterventionDialog> {
  DateTime? _selectedFollowUpDate;

  Color get _riskColor {
    switch (widget.alert.riskLevel) {
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
    switch (widget.alert.riskLevel) {
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

  List<String> _getSuggestedExercises(AppLocalizations t) {
    String exercisesString;
    switch (widget.alert.category.toLowerCase()) {
      case 'hearing':
        exercisesString = t.exercisesHearing;
        break;
      case 'speech':
        exercisesString = t.exercisesSpeech;
        break;
      case 'motor skills':
        exercisesString = t.exercisesMotor;
        break;
      case 'nutrition':
        exercisesString = t.exercisesNutrition;
        break;
      case 'development':
        exercisesString = t.exercisesDevelopment;
        break;
      default:
        exercisesString = t.exercisesDefault;
    }
    return exercisesString.split(' | ');
  }

  String? _getReferralSuggestion(AppLocalizations t) {
    if (widget.alert.riskLevel == RiskLevel.high) {
      switch (widget.alert.category.toLowerCase()) {
        case 'hearing':
          return t.referralHearing;
        case 'speech':
          return t.referralSpeech;
        case 'motor skills':
          return t.referralMotor;
        case 'nutrition':
          return t.referralNutrition;
        default:
          return t.referralDefault;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: _riskColor.withValues(alpha: 0.3), width: 2),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _riskColor.withValues(alpha: 0.1),
                      border: Border(
                        bottom: BorderSide(color: _riskColor.withValues(alpha: 0.3)),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: _riskColor.withValues(alpha: 0.2),
                              child: Text(
                                widget.alert.childName[0],
                                style: TextStyle(
                                  fontSize: 20,
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
                                    widget.alert.childName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${widget.alert.riskEmoji} ${_getRiskLevelText(t)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _riskColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Normal status special case
                        if (widget.alert.riskLevel == RiskLevel.normal) ...[
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 80,
                                  color: Colors.green[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No Intervention Required',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  widget.alert.description,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    widget.alert.recommendedAction,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.green[900],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Referral Suggestion (High Risk Only)
                          if (_getReferralSuggestion(t) != null) ...[
                            _buildSectionHeader('🏥 Referral Required', Colors.red),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.warning, color: Colors.red[700], size: 28),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _getReferralSuggestion(t)!,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red[900],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Suggested Exercises
                          _buildSectionHeader('💪 Suggested Exercises', Colors.teal),
                          const SizedBox(height: 12),
                          ..._getSuggestedExercises(t).asMap().entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.teal[100],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${entry.key + 1}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 24),

                          // Follow-up Schedule
                          _buildSectionHeader('📅 Follow-up Schedule', Colors.orange),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(const Duration(days: 7)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 90)),
                              );
                              if (date != null) {
                                setState(() {
                                  _selectedFollowUpDate = date;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, color: Colors.orange[700]),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _selectedFollowUpDate != null
                                          ? 'Follow-up on: ${_selectedFollowUpDate!.day}/${_selectedFollowUpDate!.month}/${_selectedFollowUpDate!.year}'
                                          : 'Tap to schedule follow-up visit',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.orange[900],
                                        fontWeight: _selectedFollowUpDate != null
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios, 
                                       size: 16, 
                                       color: Colors.orange[700]),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: BorderSide(color: Colors.grey[400]!),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Close',
                                  style: TextStyle(fontSize: 16, color: Colors.black87),
                                ),
                              ),
                            ),
                            if (widget.alert.riskLevel != RiskLevel.normal) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Save intervention plan
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Intervention plan saved for ${widget.alert.childName}',
                                        ),
                                        backgroundColor: Colors.teal,
                                      ),
                                    );
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Save Plan',
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color is MaterialColor ? (color as MaterialColor)[900] ?? color : color,
          ),
        ),
      ],
    );
  }
}
