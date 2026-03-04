import 'dart:math';
import '../models/admin_models.dart';

class AdminDataService {
  static final AdminDataService _instance = AdminDataService._internal();
  factory AdminDataService() => _instance;
  AdminDataService._internal();

  // Mock Schools
  final List<SchoolModel> _schools = [
    SchoolModel(id: 's1', name: 'Green Valley Anganwadi', district: 'Bangalore South', totalChildren: 45, highRiskCount: 2, malnutritionCount: 1, alertCount: 0, averageHealthScore: 88.5, complianceScore: 95),
    SchoolModel(id: 's2', name: 'Sunrise Public Center', district: 'Bangalore North', totalChildren: 120, highRiskCount: 14, malnutritionCount: 8, alertCount: 5, averageHealthScore: 72.0, complianceScore: 82),
    SchoolModel(id: 's3', name: 'Little Stars Center', district: 'Mysore Urban', totalChildren: 30, highRiskCount: 0, malnutritionCount: 0, alertCount: 0, averageHealthScore: 92.0, complianceScore: 98),
    SchoolModel(id: 's4', name: 'Rural Care Unit 4', district: 'Tumkur', totalChildren: 85, highRiskCount: 18, malnutritionCount: 12, alertCount: 9, averageHealthScore: 61.5, complianceScore: 65),
    SchoolModel(id: 's5', name: 'City Central Anganwadi', district: 'Bangalore Central', totalChildren: 60, highRiskCount: 5, malnutritionCount: 3, alertCount: 2, averageHealthScore: 79.0, complianceScore: 88),
  ];

  // Mock Alerts
  final List<AlertModel> _alerts = [
    AlertModel(id: 'a1', childName: 'Aditya Kumar', schoolName: 'Sunrise Public Center', issue: 'High Heart Rate (135 bpm)', severity: 'High', timestamp: DateTime.now().subtract(Duration(minutes: 5))),
    AlertModel(id: 'a2', childName: 'Kavya S', schoolName: 'Rural Care Unit 4', issue: 'Severe Malnutrition', severity: 'High', timestamp: DateTime.now().subtract(Duration(hours: 2))),
    AlertModel(id: 'a3', childName: 'Rahul M', schoolName: 'Sunrise Public Center', issue: 'Low SpO2 (93%)', severity: 'Medium', timestamp: DateTime.now().subtract(Duration(hours: 5))),
    AlertModel(id: 'a4', childName: 'Sneha P', schoolName: 'City Central', issue: 'Missed Assessment', severity: 'Low', timestamp: DateTime.now().subtract(Duration(days: 1))),
  ];

  Future<AdminSummaryModel> getDashboardSummary() async {
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: 800));

    int tSchools = _schools.length;
    int tChildren = _schools.fold(0, (sum, item) => sum + item.totalChildren);
    int tHighRisk = _schools.fold(0, (sum, item) => sum + item.highRiskCount);
    int tMalnutrition = _schools.fold(0, (sum, item) => sum + item.malnutritionCount);
    int tAlerts = _alerts.where((a) => !a.isResolved).length;
    
    // Average of averages
    double avgHealth = _schools.fold(0.0, (sum, item) => sum + item.averageHealthScore) / tSchools;

    return AdminSummaryModel(
      totalSchools: tSchools,
      totalChildren: tChildren,
      totalHighRisk: tHighRisk,
      totalMalnutrition: tMalnutrition, // Adding this field to model in previous step if missed, assumed OK
      activeAlerts: tAlerts,
      nationalHealthIndex: avgHealth,
      topPerformingSchools: _schools.where((s) => s.averageHealthScore > 85).toList(),
      criticalSchools: _schools.where((s) => s.averageHealthScore < 75).toList(),
    );
  }

  Future<List<SchoolModel>> getAllSchools() async {
    await Future.delayed(Duration(milliseconds: 500));
    return _schools;
  }

  Future<List<AlertModel>> getActiveAlerts() async {
    return _alerts.where((a) => !a.isResolved).toList();
  }

  Future<void> resolveAlert(String alertId) async {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      _alerts[index].isResolved = true;
    }
  }

  // Mock Student Data for School Detail
  Future<List<Map<String, dynamic>>> getStudentsForSchool(String schoolId) async {
    await Future.delayed(Duration(milliseconds: 600));
    // Generate random students
    final random = Random();
    return List.generate(15, (index) {
      final isHighRisk = random.nextDouble() < 0.2;
      return {
        'id': 'std_${schoolId}_$index',
        'name': 'Student ${String.fromCharCode(65 + index)}',
        'age': 3 + random.nextInt(4),
        'gender': random.nextBool() ? 'Male' : 'Female',
        'riskLevel': isHighRisk ? 'High' : (random.nextDouble() < 0.3 ? 'Medium' : 'Low'),
        'lastAssessment': DateTime.now().subtract(Duration(days: random.nextInt(30))),
      };
    });
  }
}
