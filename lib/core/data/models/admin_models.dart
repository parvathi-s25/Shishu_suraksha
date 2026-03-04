import 'package:flutter/material.dart';

class SchoolModel {
  final String id;
  final String name;
  final String district;
  final int totalChildren;
  final int highRiskCount;
  final int malnutritionCount;
  final int alertCount;
  final double averageHealthScore; // 0-100
  final double complianceScore; // 0-100

  SchoolModel({
    required this.id,
    required this.name,
    required this.district,
    required this.totalChildren,
    required this.highRiskCount,
    required this.malnutritionCount,
    required this.alertCount,
    required this.averageHealthScore,
    required this.complianceScore,
  });
}

class AdminSummaryModel {
  final int totalSchools;
  final int totalChildren;
  final int totalHighRisk;
  final int totalMalnutrition;
  final int activeAlerts;
  final double nationalHealthIndex;
  final List<SchoolModel> topPerformingSchools;
  final List<SchoolModel> criticalSchools;

  AdminSummaryModel({
    required this.totalSchools,
    required this.totalChildren,
    required this.totalHighRisk,
    required this.totalMalnutrition,
    required this.activeAlerts,
    required this.nationalHealthIndex,
    required this.topPerformingSchools,
    required this.criticalSchools,
  });
}

class AlertModel {
  final String id;
  final String childName;
  final String schoolName;
  final String issue; // "High HR", "Low BMI"
  final String severity; // "High", "Medium"
  final DateTime timestamp;
  bool isResolved;

  AlertModel({
    required this.id,
    required this.childName,
    required this.schoolName,
    required this.issue,
    required this.severity,
    required this.timestamp,
    this.isResolved = false,
  });
}
