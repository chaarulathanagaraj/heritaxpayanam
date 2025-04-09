import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('auth_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS places (
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
      CREATE TABLE IF NOT EXISTS saved_places (
        user_id INTEGER,
        place_id INTEGER,
        PRIMARY KEY (user_id, place_id),
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (place_id) REFERENCES places(place_id)
      )
    ''');
  }

  Future<void> savePlace(int userId, int placeId) async {
    final db = await instance.database;
    await db.insert(
      'saved_places',
      {'user_id': userId, 'place_id': placeId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeSavedPlace(int userId, int placeId) async {
    final db = await instance.database;
    await db.delete(
      'saved_places',
      where: 'user_id = ? AND place_id = ?',
      whereArgs: [userId, placeId],
    );
  }

  Future<List<int>> getSavedPlaceIds(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'saved_places',
      columns: ['place_id'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.map((e) => e['place_id'] as int).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}