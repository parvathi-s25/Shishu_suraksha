// Data Export Service - For collecting data for ML training
// Path: lib/core/services/data_export_service.dart

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

class DataExportService {
  final DatabaseService database;

  DataExportService({required this.database});

  /// Export all assessment data to CSV
  Future<String> exportAllData() async {
    final rows = <List<dynamic>>[];

    // Add header row
    rows.add([
      'session_id',
      'child_id',
      'created_at',
      'completed_at',
      'pose_score',
      'shoulder_slope',
      'hip_slope',
      'spine_deviation',
      'knee_angle_left',
      'knee_angle_right',
      'distance_score',
      'distance_status',
      'face_height_pixels',
      'alignment_score',
      'alignment_status',
      'asymmetry_difference',
      'pupil_score',
      'pupil_status',
      'brightness_difference',
      'color_vision_score',
      'color_vision_accuracy',
      'refraction_score',
      'refraction_risk',
      'blink_rate',
      'motor_score',
      'balance_score',
      'symmetry_score',
      'walk_symmetry_score',
      'overall_development_score',
    ]);

    // Get all sessions
    try {
      final db = await database.database;
      final sessions = await db.query('assessment_sessions');

      for (final session in sessions) {
        final sessionId = session['id'] as String;

        // Get results for this session
        final poseResult = await database.getPoseResult(sessionId);
        final distanceResult = await database.getDistanceResult(sessionId);
        final alignmentResult = await database.getAlignmentResult(sessionId);

        // Build row
        rows.add([
          sessionId,
          session['childId'],
          session['createdAt'],
          session['completedAt'] ?? '',
          poseResult?.score ?? 0,
          poseResult?.shoulderSlope ?? 0,
          poseResult?.hipSlope ?? 0,
          poseResult?.spineDeviation ?? 0,
          poseResult?.kneeAngleLeft ?? 0,
          poseResult?.kneeAngleRight ?? 0,
          distanceResult?.score ?? 0,
          distanceResult?.status ?? '',
          distanceResult?.faceHeightPixels ?? 0,
          alignmentResult?.score ?? 0,
          alignmentResult?.status ?? '',
          alignmentResult?.asymmetryDifference ?? 0,
          0, // pupil_score - to be filled
          '', // pupil_status
          0, // brightness_difference
          0, // color_vision_score
          0, // color_vision_accuracy
          0, // refraction_score
          '', // refraction_risk
          0, // blink_rate
          0, // motor_score
          0, // balance_score
          0, // symmetry_score
          0, // walk_symmetry_score
          0, // overall_development_score
        ]);
      }

      // Convert to CSV string
      final csvString = const ListToCsvConverter().convert(rows);

      // Save to file
      return await _saveToFile(csvString);
    } catch (e) {
      print('Export error: $e');
      return 'Error: $e';
    }
  }

  /// Export pose data specifically for ML training
  Future<String> exportPoseData() async {
    final rows = <List<dynamic>>[];

    // Header
    rows.add([
      'session_id',
      'child_id',
      'shoulder_slope',
      'hip_slope',
      'spine_deviation',
      'knee_angle_left',
      'knee_angle_right',
      'score',
      'has_issues',
    ]);

    try {
      final db = await database.database;
      final results = await db.query('pose_results');

      for (final row in results) {
        rows.add([
          row['sessionId'],
          '', // child_id - join from parent table if needed
          row['shoulderSlope'],
          row['hipSlope'],
          row['spineDeviation'],
          row['kneeAngleLeft'],
          row['kneeAngleRight'],
          row['score'],
          (row['issues'] as String).isNotEmpty ? 1 : 0,
        ]);
      }

      final csvString = const ListToCsvConverter().convert(rows);
      return await _saveToFile(csvString, filename: 'pose_data.csv');
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// Export vision data
  Future<String> exportVisionData() async {
    final rows = <List<dynamic>>[];

    rows.add([
      'session_id',
      'distance_face_height',
      'distance_status',
      'alignment_asymmetry',
      'alignment_status',
      'color_vision_accuracy',
      'refraction_risk',
    ]);

    try {
      final db = await database.database;
      final sessions = await db.query('assessment_sessions');

      for (final session in sessions) {
        final sessionId = session['id'] as String;

        final distanceResult = await database.getDistanceResult(sessionId);
        final alignmentResult = await database.getAlignmentResult(sessionId);

        rows.add([
          sessionId,
          distanceResult?.faceHeightPixels ?? 0,
          distanceResult?.status ?? '',
          alignmentResult?.asymmetryDifference ?? 0,
          alignmentResult?.status ?? '',
          0, // color_vision_accuracy
          '', // refraction_risk
        ]);
      }

      final csvString = const ListToCsvConverter().convert(rows);
      return await _saveToFile(csvString, filename: 'vision_data.csv');
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// Export motor data
  Future<String> exportMotorData() async {
    final rows = <List<dynamic>>[];

    rows.add([
      'session_id',
      'balance_score',
      'symmetry_score',
      'walk_symmetry_score',
      'overall_motor_score',
    ]);

    try {
      final db = await database.database;
      final results = await db.query('motor_results');

      for (final row in results) {
        rows.add([
          row['sessionId'],
          row['balanceScore'],
          row['symmetryScore'],
          row['walkSymmetryScore'],
          row['overallMotorScore'],
        ]);
      }

      final csvString = const ListToCsvConverter().convert(rows);
      return await _saveToFile(csvString, filename: 'motor_data.csv');
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// Save CSV to file
  Future<String> _saveToFile(String csvString, {String filename = 'assessment_data.csv'}) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');

      await file.writeAsString(csvString);
      print('File saved to: ${file.path}');

      return file.path;
    } catch (e) {
      print('File save error: $e');
      return 'Error saving file: $e';
    }
  }

  /// Get summary statistics for collected data
  Future<Map<String, dynamic>> getDataSummary() async {
    try {
      final db = await database.database;

      // Count sessions
      final sessionCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM assessment_sessions'),
      ) ?? 0;

      // Count completed assessments
      final completedCount = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM assessment_sessions WHERE completedAt IS NOT NULL',
        ),
      ) ?? 0;

      // Average pose score
      final avgPoseScore = await db.rawQuery(
        'SELECT AVG(score) as avg FROM pose_results',
      );

      // Count issues found
      final issueCount = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM pose_results WHERE issues != ""',
        ),
      ) ?? 0;

      return {
        'total_sessions': sessionCount,
        'completed_assessments': completedCount,
        'average_pose_score': avgPoseScore.isNotEmpty 
          ? (avgPoseScore[0]['avg'] as num? ?? 0).toDouble() 
          : 0,
        'sessions_with_issues': issueCount,
        'completion_rate': sessionCount > 0 
          ? (completedCount / sessionCount * 100).toStringAsFixed(1)
          : '0',
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
