import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class DBService {
  DBService._private();
  static final DBService instance = DBService._private();

  // Increment this when static data or DB schema/seed changes in the app
  static const int kStaticDataVersion = 1;

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  /// Ensure that static data / seeded DB is refreshed when app version updates
  /// Compares `kStaticDataVersion` with stored value and deletes DB if mismatch.
  Future<void> ensureStaticDataUpToDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getInt('static_data_version') ?? 0;
      if (stored != kStaticDataVersion) {
        final path = join(await getDatabasesPath(), 'shishu_suraksha.db');
        // Close any open db
        try {
          if (_db != null) {
            await _db!.close();
            _db = null;
          }
        } catch (_) {}

        // Delete DB file if exists
        try {
          if (await databaseExists(path)) {
            await deleteDatabase(path);
          }
        } catch (e) {
          // best-effort
        }

        // Update stored version
        await prefs.setInt('static_data_version', kStaticDataVersion);
      }
    } catch (e) {
      // ignore errors here
    }
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'shishu_suraksha.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vision_acuity(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        assessment_id TEXT,
        eye TEXT,
        level_passed INTEGER,
        details TEXT,
        created_at INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE vision_alignment(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        assessment_id TEXT,
        symmetry REAL,
        risk_flag INTEGER,
        details TEXT,
        created_at INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE vision_reflex(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        assessment_id TEXT,
        left_contraction REAL,
        right_contraction REAL,
        risk_flag INTEGER,
        details TEXT,
        created_at INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE vision_color(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        assessment_id TEXT,
        correct_count INTEGER,
        incorrect_count INTEGER,
        details TEXT,
        created_at INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE vision_refraction(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        assessment_id TEXT,
        blur_level REAL,
        risk_flag INTEGER,
        details TEXT,
        created_at INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE final_scores(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        assessment_id TEXT,
        module_scores TEXT,
        overall_score REAL,
        category TEXT,
        created_at INTEGER
      )
    ''');
  }

  Future<int> insert(String table, Map<String, Object?> values) async {
    final database = await db;
    return database.insert(table, values);
  }
}
