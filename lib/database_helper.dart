import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' hide context;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tourism.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE places (
        place_id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        english_name TEXT NOT NULL,
        image TEXT NOT NULL,
        description TEXT NOT NULL,
        english_description TEXT NOT NULL,
        location TEXT NOT NULL,
        english_location TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE saved_places (
        email TEXT NOT NULL,
        place_id INTEGER NOT NULL,
        PRIMARY KEY (email, place_id),
        FOREIGN KEY (place_id) REFERENCES places(place_id)
      )
    ''');
  }

  // Initialize the database (call this at app startup)
  Future<void> init() async {
    await database;
  }

  // User operations
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUser(String email) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Saved places operations
  Future<void> savePlace(String email, int placeId) async {
    final db = await instance.database;
    await db.insert(
      'saved_places',
      {'email': email, 'place_id': placeId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeSavedPlace(String email, int placeId) async {
    final db = await instance.database;
    await db.delete(
      'saved_places',
      where: 'email = ? AND place_id = ?',
      whereArgs: [email, placeId],
    );
  }

  Future<List<int>> getSavedPlaceIds(String email) async {
    final db = await instance.database;
    final result = await db.query(
      'saved_places',
      columns: ['place_id'],
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.map((e) => e['place_id'] as int).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}