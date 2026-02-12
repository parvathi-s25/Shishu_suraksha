import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';

class TaskDatabase {
  static final TaskDatabase instance = TaskDatabase._init();
  static Database? _database;

  TaskDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL';
    const nullableTextType = 'TEXT';

    await db.execute('''
CREATE TABLE tasks ( 
  id $idType, 
  googleId $nullableTextType,
  title $textType,
  description $textType,
  dueDate $textType,
  isCompleted $boolType
  )
''');
  }

  // Web-safe Mock Data Storage
  final List<Task> _webTasks = [];
  int _webIdCounter = 1;

  Future<Task> create(Task task) async {
    if (kIsWeb) {
      final newTask = task.copyWith(id: _webIdCounter++);
      _webTasks.add(newTask);
      return newTask;
    }
    final db = await instance.database;
    final id = await db.insert('tasks', task.toMap());
    return task.copyWith(id: id);
  }

  Future<Task> readTask(int id) async {
    if (kIsWeb) {
       return _webTasks.firstWhere((t) => t.id == id, orElse: () => throw Exception('ID $id not found'));
    }
    final db = await instance.database;
    final maps = await db.query(
      'tasks',
      columns: ['id', 'googleId', 'title', 'description', 'dueDate', 'isCompleted'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Task>> readAllTasks() async {
    if (kIsWeb) {
      return List.from(_webTasks);
    }
    final db = await instance.database;
    final orderBy = 'dueDate ASC';
    final result = await db.query('tasks', orderBy: orderBy);

    return result.map((json) => Task.fromMap(json)).toList();
  }

  Future<int> update(Task task) async {
    if (kIsWeb) {
      final index = _webTasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _webTasks[index] = task;
        return 1;
      }
      return 0;
    }
    final db = await instance.database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> delete(int id) async {
    if (kIsWeb) {
      _webTasks.removeWhere((t) => t.id == id);
      return 1;
    }
    final db = await instance.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    if (kIsWeb) return;
    final db = await instance.database;
    db.close();
  }
}
