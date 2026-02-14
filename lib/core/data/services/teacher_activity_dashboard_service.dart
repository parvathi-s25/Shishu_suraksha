import 'package:flutter/material.dart';

class TeacherActivityDashboardService {
  Future<List<ActivityData>> getActivities() async {
    return [];
  }

  void recordActivitySession(ActivitySession session) {
    // placeholder: persist session in real implementation
  }
}

class ActivityData {
  final String id;
  final String title;

  ActivityData({
    required this.id,
    required this.title,
  });
}
