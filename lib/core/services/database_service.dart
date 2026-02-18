// Database service for sqflite - handles all persistence
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/assessment_models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  
  factory DatabaseService() => _instance;
  
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'assessment.db');
    
    return openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Assessment sessions table
    await db.execute('''
      CREATE TABLE assessment_sessions (
        id TEXT PRIMARY KEY,
        childId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        completedAt TEXT
      )
    ''');

    // Pose results table
    await db.execute('''
      CREATE TABLE pose_results (
        id TEXT PRIMARY KEY,
        sessionId TEXT NOT NULL,
        shoulderSlope REAL,
        hipSlope REAL,
        spineDeviation REAL,
        kneeAngleLeft REAL,
        kneeAngleRight REAL,
        landmarkCount INTEGER,
        score REAL,
        issues TEXT,
        timestamp TEXT,
        FOREIGN KEY (sessionId) REFERENCES assessment_sessions(id)
      )
    ''');

    // Distance check results table
    await db.execute('''
      CREATE TABLE distance_results (
        id TEXT PRIMARY KEY,
        sessionId TEXT NOT NULL,
        faceHeightPixels REAL,
        status TEXT,
        score REAL,
        timestamp TEXT,
        FOREIGN KEY (sessionId) REFERENCES assessment_sessions(id)
      )
    ''');

    // Eye alignment results table
    await db.execute('''
      CREATE TABLE alignment_results (
        id TEXT PRIMARY KEY,
        sessionId TEXT NOT NULL,
        leftEyeOffset REAL,
        rightEyeOffset REAL,
        asymmetryDifference REAL,
        status TEXT,
        score REAL,
        timestamp TEXT,
        FOREIGN KEY (sessionId) REFERENCES assessment_sessions(id)
      )
    ''');

    // Pupil reflex results table
    await db.execute('''
      CREATE TABLE pupil_results (
        id TEXT PRIMARY KEY,
        sessionId TEXT NOT NULL,
        brightnessChangeBefore REAL,
        brightnessChangeAfter REAL,
        brightnessDifference REAL,
        status TEXT,
        score REAL,
        timestamp TEXT,
        FOREIGN KEY (sessionId) REFERENCES assessment_sessions(id)
      )
    ''');

    // Color vision results table
    await db.execute('''
      CREATE TABLE color_vision_results (
        id TEXT PRIMARY KEY,
        sessionId TEXT NOT NULL,
        totalTestsGiven INTEGER,
        correctAnswers INTEGER,
        accuracy REAL,
        status TEXT,
        score REAL,
        timestamp TEXT,
        FOREIGN KEY (sessionId) REFERENCES assessment_sessions(id)
      )
    ''');

    // Refraction risk results table
    await db.execute('''
      CREATE TABLE refraction_results (
        id TEXT PRIMARY KEY,
        sessionId TEXT NOT NULL,
        visualAcuity REAL,
        frequentSquint INTEGER,
        blinkRate INTEGER,
        riskLevel TEXT,
        score REAL,
        timestamp TEXT,
        FOREIGN KEY (sessionId) REFERENCES assessment_sessions(id)
      )
    ''');

    // Motor assessment results table
    await db.execute('''
      CREATE TABLE motor_results (
        id TEXT PRIMARY KEY,
        sessionId TEXT NOT NULL,
        balanceScore REAL,
        symmetryScore REAL,
        walkSymmetryScore REAL,
        overallMotorScore REAL,
        timestamp TEXT,
        FOREIGN KEY (sessionId) REFERENCES assessment_sessions(id)
      )
    ''');
  }

  // Assessment Session Operations
  Future<void> createSession(AssessmentSession session) async {
    final db = await database;
    await db.insert(
      'assessment_sessions',
      {
        'id': session.id,
        'childId': session.childId,
        'createdAt': session.createdAt.toIso8601String(),
        'completedAt': session.completedAt?.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<AssessmentSession?> getSession(String sessionId) async {
    final db = await database;
    final result = await db.query(
      'assessment_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return AssessmentSession(
      id: row['id'] as String,
      childId: row['childId'] as String,
      createdAt: DateTime.parse(row['createdAt'] as String),
    )..completedAt = row['completedAt'] != null 
        ? DateTime.parse(row['completedAt'] as String)
        : null;
  }

  Future<void> completeSession(String sessionId) async {
    final db = await database;
    await db.update(
      'assessment_sessions',
      {'completedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  // Pose Results
  Future<void> savePoseResult(String sessionId, PoseResult result) async {
    final db = await database;
    await db.insert(
      'pose_results',
      {
        'id': '${sessionId}_pose',
        'sessionId': sessionId,
        'shoulderSlope': result.shoulderSlope,
        'hipSlope': result.hipSlope,
        'spineDeviation': result.spineDeviation,
        'kneeAngleLeft': result.kneeAngleLeft,
        'kneeAngleRight': result.kneeAngleRight,
        'landmarkCount': result.landmarkCount,
        'score': result.score,
        'issues': result.issues.join(','),
        'timestamp': result.timestamp.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<PoseResult?> getPoseResult(String sessionId) async {
    final db = await database;
    final result = await db.query(
      'pose_results',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return PoseResult(
      shoulderSlope: row['shoulderSlope'] as double,
      hipSlope: row['hipSlope'] as double,
      spineDeviation: row['spineDeviation'] as double,
      kneeAngleLeft: row['kneeAngleLeft'] as double,
      kneeAngleRight: row['kneeAngleRight'] as double,
      landmarkCount: row['landmarkCount'] as int,
      score: row['score'] as double,
      issues: (row['issues'] as String).split(','),
      timestamp: DateTime.parse(row['timestamp'] as String),
    );
  }

  // Distance Results
  Future<void> saveDistanceResult(String sessionId, DistanceCheckResult result) async {
    final db = await database;
    await db.insert(
      'distance_results',
      {
        'id': '${sessionId}_distance',
        'sessionId': sessionId,
        'faceHeightPixels': result.faceHeightPixels,
        'status': result.status,
        'score': result.score,
        'timestamp': result.timestamp.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<DistanceCheckResult?> getDistanceResult(String sessionId) async {
    final db = await database;
    final result = await db.query(
      'distance_results',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return DistanceCheckResult(
      faceHeightPixels: row['faceHeightPixels'] as double,
      status: row['status'] as String,
      score: row['score'] as double,
      timestamp: DateTime.parse(row['timestamp'] as String),
    );
  }

  // Eye Alignment Results
  Future<void> saveAlignmentResult(String sessionId, EyeAlignmentResult result) async {
    final db = await database;
    await db.insert(
      'alignment_results',
      {
        'id': '${sessionId}_alignment',
        'sessionId': sessionId,
        'leftEyeOffset': result.leftEyeOffset,
        'rightEyeOffset': result.rightEyeOffset,
        'asymmetryDifference': result.asymmetryDifference,
        'status': result.status,
        'score': result.score,
        'timestamp': result.timestamp.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<EyeAlignmentResult?> getAlignmentResult(String sessionId) async {
    final db = await database;
    final result = await db.query(
      'alignment_results',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return EyeAlignmentResult(
      leftEyeOffset: row['leftEyeOffset'] as double,
      rightEyeOffset: row['rightEyeOffset'] as double,
      asymmetryDifference: row['asymmetryDifference'] as double,
      status: row['status'] as String,
      score: row['score'] as double,
      timestamp: DateTime.parse(row['timestamp'] as String),
    );
  }

  // Pupil Results
  Future<void> savePupilResult(String sessionId, PupilReflexResult result) async {
    final db = await database;
    await db.insert(
      'pupil_results',
      {
        'id': '${sessionId}_pupil',
        'sessionId': sessionId,
        'brightnessChangeBefore': result.brightnessChangeBefore,
        'brightnessChangeAfter': result.brightnessChangeAfter,
        'brightnessDifference': result.brightnessDifference,
        'status': result.status,
        'score': result.score,
        'timestamp': result.timestamp.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Color Vision Results
  Future<void> saveColorVisionResult(String sessionId, ColorVisionResult result) async {
    final db = await database;
    await db.insert(
      'color_vision_results',
      {
        'id': '${sessionId}_color_vision',
        'sessionId': sessionId,
        'totalTestsGiven': result.totalTestsGiven,
        'correctAnswers': result.correctAnswers,
        'accuracy': result.accuracy,
        'status': result.status,
        'score': result.score,
        'timestamp': result.timestamp.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Refraction Results
  Future<void> saveRefractionResult(String sessionId, RefractionRiskResult result) async {
    final db = await database;
    await db.insert(
      'refraction_results',
      {
        'id': '${sessionId}_refraction',
        'sessionId': sessionId,
        'visualAcuity': result.visualAcuity,
        'frequentSquint': result.frequentSquint ? 1 : 0,
        'blinkRate': result.blinkRate,
        'riskLevel': result.riskLevel,
        'score': result.score,
        'timestamp': result.timestamp.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Motor Results
  Future<void> saveMotorResult(String sessionId, MotorAssessmentResult result) async {
    final db = await database;
    await db.insert(
      'motor_results',
      {
        'id': '${sessionId}_motor',
        'sessionId': sessionId,
        'balanceScore': result.balanceScore,
        'symmetryScore': result.symmetryScore,
        'walkSymmetryScore': result.walkSymmetryScore,
        'overallMotorScore': result.overallMotorScore,
        'timestamp': result.timestamp.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> close() async {
    _database?.close();
    _database = null;
  }
}
