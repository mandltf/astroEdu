// lib/services/local/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('astroedu.db');
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
        password TEXT NOT NULL,
        photo_path TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        category TEXT NOT NULL,
        item_id TEXT NOT NULL,
        is_read INTEGER DEFAULT 0,
        is_unlocked INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE quiz_scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        category TEXT NOT NULL,
        score INTEGER NOT NULL,
        total INTEGER NOT NULL,
        played_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE chat_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        role TEXT NOT NULL,
        message TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE bought_stars (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        star_name TEXT NOT NULL,
        custom_name TEXT NOT NULL,
        price_usd REAL NOT NULL,
        price_idr REAL NOT NULL,
        bought_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE saran_kesan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        saran TEXT,
        kesan TEXT,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  // USER CRUD
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final results = await db.query('users', where: 'email = ?', whereArgs: [email]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final results = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateUser(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('users', data, where: 'id = ?', whereArgs: [id]);
  }

  // PROGRESS
  Future<void> unlockItem(int userId, String category, String itemId) async {
    final db = await database;
    final exists = await db.query('user_progress',
        where: 'user_id = ? AND category = ? AND item_id = ?',
        whereArgs: [userId, category, itemId]);
    if (exists.isEmpty) {
      await db.insert('user_progress', {
        'user_id': userId,
        'category': category,
        'item_id': itemId,
        'is_read': 0,
        'is_unlocked': 1,
      });
    }
  }

  Future<void> markAsRead(int userId, String category, String itemId) async {
    final db = await database;
    await db.update(
      'user_progress',
      {'is_read': 1},
      where: 'user_id = ? AND category = ? AND item_id = ?',
      whereArgs: [userId, category, itemId],
    );
  }

  Future<List<Map<String, dynamic>>> getProgress(int userId, String category) async {
    final db = await database;
    return await db.query('user_progress',
        where: 'user_id = ? AND category = ?', whereArgs: [userId, category]);
  }

  Future<bool> isItemUnlocked(int userId, String category, String itemId) async {
    final db = await database;
    final results = await db.query('user_progress',
        where: 'user_id = ? AND category = ? AND item_id = ?',
        whereArgs: [userId, category, itemId]);
    if (results.isEmpty) return itemId == 'item_0';
    return results.first['is_unlocked'] == 1;
  }

  Future<bool> isItemRead(int userId, String category, String itemId) async {
    final db = await database;
    final results = await db.query('user_progress',
        where: 'user_id = ? AND category = ? AND item_id = ?',
        whereArgs: [userId, category, itemId]);
    if (results.isEmpty) return false;
    return results.first['is_read'] == 1;
  }

  Future<bool> allItemsRead(int userId, String category, int totalItems) async {
    final db = await database;
    final results = await db.query('user_progress',
        where: 'user_id = ? AND category = ? AND is_read = 1',
        whereArgs: [userId, category]);
    return results.length >= totalItems;
  }

  // QUIZ SCORES
  Future<int> insertQuizScore(Map<String, dynamic> score) async {
    final db = await database;
    return await db.insert('quiz_scores', score);
  }

  Future<List<Map<String, dynamic>>> getQuizScores(int userId) async {
    final db = await database;
    return await db.query('quiz_scores',
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'played_at DESC');
  }

  // CHAT HISTORY
  Future<int> insertChat(Map<String, dynamic> chat) async {
    final db = await database;
    return await db.insert('chat_history', chat);
  }

  Future<List<Map<String, dynamic>>> getChatHistory(int userId) async {
    final db = await database;
    return await db.query('chat_history',
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'created_at ASC', limit: 50);
  }

  Future<void> clearChatHistory(int userId) async {
    final db = await database;
    await db.delete('chat_history', where: 'user_id = ?', whereArgs: [userId]);
  }

  // BOUGHT STARS
  Future<int> insertStar(Map<String, dynamic> star) async {
    final db = await database;
    return await db.insert('bought_stars', star);
  }

  Future<List<Map<String, dynamic>>> getBoughtStars(int userId) async {
    final db = await database;
    return await db.query('bought_stars',
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'bought_at DESC');
  }

  // SARAN KESAN
  Future<void> saveSaranKesan(int userId, String saran, String kesan) async {
    final db = await database;
    final exists = await db.query('saran_kesan',
        where: 'user_id = ?', whereArgs: [userId]);
    if (exists.isEmpty) {
      await db.insert('saran_kesan', {
        'user_id': userId,
        'saran': saran,
        'kesan': kesan,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } else {
      await db.update('saran_kesan', {
        'saran': saran,
        'kesan': kesan,
        'updated_at': DateTime.now().toIso8601String(),
      }, where: 'user_id = ?', whereArgs: [userId]);
    }
  }

  Future<Map<String, dynamic>?> getSaranKesan(int userId) async {
    final db = await database;
    final results = await db.query('saran_kesan',
        where: 'user_id = ?', whereArgs: [userId]);
    return results.isNotEmpty ? results.first : null;
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}