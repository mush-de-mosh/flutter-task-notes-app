import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tasks.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        priority TEXT NOT NULL,
        description TEXT NOT NULL,
        isCompleted INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertTask(TaskItem task) async {
    try {
      print('DatabaseHelper: Attempting to insert task: ${task.title}');
      final db = await database;
      final taskMap = task.toJson();
      taskMap['isCompleted'] = taskMap['isCompleted'] ? 1 : 0;
      print('DatabaseHelper: Task map: $taskMap');
      final result = await db.insert('tasks', taskMap);
      print('DatabaseHelper: Insert result: $result');
      return result;
    } catch (e) {
      print('DatabaseHelper: Error inserting task: $e');
      rethrow;
    }
  }

  Future<List<TaskItem>> getAllTasks() async {
    try {
      print('DatabaseHelper: Getting all tasks');
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('tasks');
      print('DatabaseHelper: Found ${maps.length} task records');
      final tasks = List.generate(maps.length, (i) {
        final map = Map<String, dynamic>.from(maps[i]);
        map['isCompleted'] = map['isCompleted'] == 1;
        return TaskItem.fromJson(map);
      });
      print('DatabaseHelper: Converted to ${tasks.length} TaskItem objects');
      return tasks;
    } catch (e) {
      print('DatabaseHelper: Error getting tasks: $e');
      rethrow;
    }
  }

  Future<int> deleteTask(String id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Test function to verify database connection
  Future<bool> testConnection() async {
    try {
      print('DatabaseHelper: Testing database connection...');
      final db = await database;
      
      // Test if we can query the tasks table
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM tasks');
      final count = result.first['count'] as int;
      print('DatabaseHelper: Database connection successful. Current task count: $count');
      return true;
    } catch (e) {
      print('DatabaseHelper: Database connection failed: $e');
      return false;
    }
  }
}