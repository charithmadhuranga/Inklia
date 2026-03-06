import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/journal_entry.dart';

class DatabaseService {
  static Database? _database;
  static const String _tableName = 'journal_entries';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'journal.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        imagePaths TEXT NOT NULL,
        voiceMemoPaths TEXT NOT NULL,
        mood INTEGER,
        tags TEXT NOT NULL,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        templateType TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE $_tableName ADD COLUMN mood INTEGER');
      } catch (_) {}
      try {
        await db.execute(
          "ALTER TABLE $_tableName ADD COLUMN tags TEXT NOT NULL DEFAULT '[]'",
        );
      } catch (_) {}
      try {
        await db.execute(
          'ALTER TABLE $_tableName ADD COLUMN isFavorite INTEGER NOT NULL DEFAULT 0',
        );
      } catch (_) {}
      try {
        await db.execute(
          'ALTER TABLE $_tableName ADD COLUMN templateType TEXT',
        );
      } catch (_) {}
    }
  }

  Future<int> insertEntry(JournalEntry entry) async {
    final db = await database;
    return await db.insert(
      _tableName,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateEntry(JournalEntry entry) async {
    final db = await database;
    return await db.update(
      _tableName,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteEntry(String id) async {
    final db = await database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<JournalEntry?> getEntryById(String id) async {
    final db = await database;
    final maps = await db.query(_tableName, where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;
    return JournalEntry.fromMap(maps.first);
  }

  Future<JournalEntry?> getEntryByDate(DateTime date) async {
    final db = await database;
    final dateStr = DateTime(date.year, date.month, date.day).toIso8601String();
    final maps = await db.query(
      _tableName,
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (maps.isEmpty) return null;
    return JournalEntry.fromMap(maps.first);
  }

  Future<List<JournalEntry>> getAllEntries() async {
    final db = await database;
    final maps = await db.query(_tableName, orderBy: 'date DESC');
    return maps.map((map) => JournalEntry.fromMap(map)).toList();
  }

  Future<List<JournalEntry>> getEntriesForMonth(int year, int month) async {
    final db = await database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    final maps = await db.query(
      _tableName,
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date DESC',
    );

    return maps.map((map) => JournalEntry.fromMap(map)).toList();
  }

  Future<List<JournalEntry>> searchEntries(String query) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'title LIKE ? OR content LIKE ? OR tags LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'date DESC',
    );
    return maps.map((map) => JournalEntry.fromMap(map)).toList();
  }

  Future<List<JournalEntry>> getFavoriteEntries() async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'date DESC',
    );
    return maps.map((map) => JournalEntry.fromMap(map)).toList();
  }

  Future<List<JournalEntry>> getEntriesByMood(Mood mood) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'mood = ?',
      whereArgs: [mood.index],
      orderBy: 'date DESC',
    );
    return maps.map((map) => JournalEntry.fromMap(map)).toList();
  }

  Future<Map<Mood, int>> getMoodStatistics() async {
    final db = await database;
    final Map<Mood, int> stats = {};

    for (final mood in Mood.values) {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName WHERE mood = ?',
        [mood.index],
      );
      stats[mood] = (result.first['count'] as int?) ?? 0;
    }

    return stats;
  }

  Future<int> getTotalEntriesCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName',
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<int> getCurrentStreak() async {
    final db = await database;
    final entries = await db.query(_tableName, orderBy: 'date DESC');
    if (entries.isEmpty) return 0;

    int streak = 0;
    DateTime? lastDate;

    for (final entry in entries) {
      final entryDate = DateTime.parse(entry['date'] as String);
      final normalizedDate = DateTime(
        entryDate.year,
        entryDate.month,
        entryDate.day,
      );

      if (lastDate == null) {
        final today = DateTime.now();
        final normalizedToday = DateTime(today.year, today.month, today.day);
        final yesterday = normalizedToday.subtract(const Duration(days: 1));

        if (normalizedDate == normalizedToday || normalizedDate == yesterday) {
          streak = 1;
          lastDate = normalizedDate;
        } else {
          break;
        }
      } else {
        final expectedDate = lastDate.subtract(const Duration(days: 1));
        if (normalizedDate == expectedDate) {
          streak++;
          lastDate = normalizedDate;
        } else if (normalizedDate == lastDate) {
          continue;
        } else {
          break;
        }
      }
    }

    return streak;
  }

  Future<List<String>> getAllTags() async {
    final db = await database;
    final maps = await db.query(_tableName, columns: ['tags']);
    final Set<String> allTags = {};

    for (final map in maps) {
      try {
        final tagsJson = map['tags'] as String?;
        if (tagsJson != null && tagsJson.isNotEmpty && tagsJson != '[]') {
          final tags = List<String>.from(
            tagsJson.isNotEmpty
                ? (tagsJson
                    .replaceAll('[', '')
                    .replaceAll(']', '')
                    .replaceAll('"', '')
                    .split(','))
                : <String>[],
          );
          allTags.addAll(tags.where((t) => t.isNotEmpty));
        }
      } catch (e) {
        continue;
      }
    }

    return allTags.toList()..sort();
  }
}
