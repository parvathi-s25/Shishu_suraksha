
import 'dart:async';
import 'excel_export_service.dart';

class AdminService {
  final ExcelExportService _exportService = ExcelExportService();

  // Mock Data for Admin Dashboard - In real app, this would be an aggregate query
  Future<Map<String, dynamic>> getDashboardStats() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    return {
      'total_schools': 42,
      'total_children': 1250,
      'high_risk_children': 85, 
      'malnutrition_cases': 120, 
      'fever_alerts_today': 14,
      'poor_aqi_schools': 3,
    };
  }

  Future<List<Map<String, dynamic>>> getHighRiskList() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      {"name": "Aditi Sharma", "school": "MPS Delhi", "risk": "High Heart Rate (140)", "score": 85},
      {"name": "Rohan Gupta", "school": "KV Noida", "risk": "Low SpO2 (88%)", "score": 92},
      {"name": "Sita Verma", "school": "Govt School #4", "risk": "Severe Malnutrition (BMI 14.2)", "score": 78},
      {"name": "Amit Kumar", "school": "MPS Delhi", "risk": "High Fever (39.5°C)", "score": 88},
      {"name": "Priya Singh", "school": "KV Noida", "risk": "Irregular ECG", "score": 82},
    ];
  }

  // Actual Excel Export Integration
  Future<String?> exportToExcel(String reportType) async {
    if (reportType == "HighRisk") {
      final data = await getHighRiskList();
      final List<Map<String, dynamic>> exportData = data.map((e) => {
        "name": e['name'],
        "age": 4, // Mock age
        "heart_rate": 140.0, // Mock
        "spo2": 95.0,
        "temp": 37.0,
        "score": e['score'],
        "status": e['risk'],
      }).toList();
      
      return await _exportService.generateHealthReport("Central_Admin", exportData);
    } else {
      // Generic growth report mock
      final List<Map<String, dynamic>> growthData = [
        {"name": "Rahul", "height": 110.0, "weight": 18.0, "bmi": 14.8, "status": "Normal", "date": "15/02/2026"},
      ];
      return await _exportService.generateGrowthReport("Central_Admin", growthData);
    }
  }
}

