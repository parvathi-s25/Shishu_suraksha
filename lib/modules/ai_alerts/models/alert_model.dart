
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum AlertType {
  health,      // Vital signs alerts
  growth,      // Malnutrition/growth issues
  environment, // Classroom environment issues
  device       // Device battery/connectivity
}

enum AlertSeverity {
  low,         // Informational
  medium,      // Warning
  high,        // Critical - requires immediate action
  critical     // Emergency
}

class AlertModel {
  final String id;
  final String schoolId;
  final String childId;
  final String? childName;
  final AlertType type;
  final AlertSeverity severity;
  final String title;
  final String message;
  final String? actionRecommendation;
  final DateTime timestamp;
  final bool acknowledged;
  final String? acknowledgedBy;
  final DateTime? acknowledgedAt;

  AlertModel({
    required this.id,
    required this.schoolId,
    required this.childId,
    this.childName,
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    this.actionRecommendation,
    required this.timestamp,
    this.acknowledged = false,
    this.acknowledgedBy,
    this.acknowledgedAt,
  });

  factory AlertModel.fromMap(String id, Map<String, dynamic> data) {
    return AlertModel(
      id: id,
      schoolId: data['school_id'] ?? "",
      childId: data['child_id'] ?? "",
      childName: data['child_name'],
      type: AlertType.values.firstWhere(
        (e) => e.toString() == 'AlertType.${data['type']}',
        orElse: () => AlertType.health,
      ),
      severity: AlertSeverity.values.firstWhere(
        (e) => e.toString() == 'AlertSeverity.${data['severity']}',
        orElse: () => AlertSeverity.medium,
      ),
      title: data['title'] ?? "",
      message: data['message'] ?? "",
      actionRecommendation: data['action_recommendation'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      acknowledged: data['acknowledged'] ?? false,
      acknowledgedBy: data['acknowledged_by'],
      acknowledgedAt: data['acknowledged_at'] != null 
          ? (data['acknowledged_at'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'school_id': schoolId,
      'child_id': childId,
      'child_name': childName,
      'type': type.toString().split('.').last,
      'severity': severity.toString().split('.').last,
      'title': title,
      'message': message,
      'action_recommendation': actionRecommendation,
      'timestamp': Timestamp.fromDate(timestamp),
      'acknowledged': acknowledged,
      'acknowledged_by': acknowledgedBy,
      'acknowledged_at': acknowledgedAt != null 
          ? Timestamp.fromDate(acknowledgedAt!) 
          : null,
    };
  }

  // UI Helpers
  Color get severityColor {
    switch (severity) {
      case AlertSeverity.low:
        return Colors.blue;
      case AlertSeverity.medium:
        return Colors.orange;
      case AlertSeverity.high:
        return Colors.red;
      case AlertSeverity.critical:
        return Colors.red.shade900;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case AlertType.health:
        return Icons.favorite;
      case AlertType.growth:
        return Icons.child_care;
      case AlertType.environment:
        return Icons.cloud;
      case AlertType.device:
        return Icons.battery_alert;
    }
  }

  String get severityLabel {
    switch (severity) {
      case AlertSeverity.low:
        return "Info";
      case AlertSeverity.medium:
        return "Warning";
      case AlertSeverity.high:
        return "Critical";
      case AlertSeverity.critical:
        return "EMERGENCY";
    }
  }

  // Copy with method for acknowledgment
  AlertModel copyWith({
    bool? acknowledged,
    String? acknowledgedBy,
    DateTime? acknowledgedAt,
  }) {
    return AlertModel(
      id: id,
      schoolId: schoolId,
      childId: childId,
      childName: childName,
      type: type,
      severity: severity,
      title: title,
      message: message,
      actionRecommendation: actionRecommendation,
      timestamp: timestamp,
      acknowledged: acknowledged ?? this.acknowledged,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
    );
  }
}
