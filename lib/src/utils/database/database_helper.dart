import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, 'vibe_music.db');

      AppLogger().d('初始化数据库，路径: $path');

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
      );
    } catch (e) {
      AppLogger().e('初始化数据库失败: $e');
      rethrow;
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    try {
      // 创建用户表
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT UNIQUE,
          username TEXT,
          email TEXT,
          avatar TEXT,
          createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // 创建歌曲表
      await db.execute('''
        CREATE TABLE IF NOT EXISTS songs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          songId TEXT UNIQUE,
          songName TEXT,
          artistName TEXT,
          coverUrl TEXT,
          songUrl TEXT,
          duration TEXT,
          isFavorite INTEGER DEFAULT 0,
          createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // 创建播放列表表
      await db.execute('''
        CREATE TABLE IF NOT EXISTS playlists (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // 创建播放列表歌曲关联表
      await db.execute('''
        CREATE TABLE IF NOT EXISTS playlist_songs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          playlist_id INTEGER,
          song_id TEXT,
          song_name TEXT,
          artist_name TEXT,
          cover_url TEXT,
          song_url TEXT,
          duration TEXT,
          position INTEGER,
          createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // 创建播放历史表
      await db.execute('''
        CREATE TABLE IF NOT EXISTS play_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          songId TEXT,
          songName TEXT,
          artistName TEXT,
          coverUrl TEXT,
          songUrl TEXT,
          duration TEXT,
          playedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      AppLogger().d('数据库表创建成功');
    } catch (e) {
      AppLogger().e('创建数据库表失败: $e');
      rethrow;
    }
  }

  Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    try {
      AppLogger().d('升级数据库，从版本 $oldVersion 到 $newVersion');
      // 在这里添加数据库升级逻辑
    } catch (e) {
      AppLogger().e('升级数据库失败: $e');
      rethrow;
    }
  }

  // 通用插入方法
  Future<int> insert(String table, Map<String, dynamic> data) async {
    try {
      final db = await database;
      final id = await db.insert(table, data,
          conflictAlgorithm: ConflictAlgorithm.replace);
      AppLogger().d('插入数据到表 $table 成功，ID: $id');
      return id;
    } catch (e) {
      AppLogger().e('插入数据到表 $table 失败: $e');
      rethrow;
    }
  }

  // 通用查询方法
  Future<List<Map<String, dynamic>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      final db = await database;
      final results = await db.query(
        table,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
      AppLogger().d('查询表 $table 成功，返回 ${results.length} 条记录');
      return results;
    } catch (e) {
      AppLogger().e('查询表 $table 失败: $e');
      rethrow;
    }
  }

  // 通用更新方法
  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final db = await database;
      final count = await db.update(
        table,
        data,
        where: where,
        whereArgs: whereArgs,
      );
      AppLogger().d('更新表 $table 成功，影响 $count 条记录');
      return count;
    } catch (e) {
      AppLogger().e('更新表 $table 失败: $e');
      rethrow;
    }
  }

  // 通用删除方法
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final db = await database;
      final count = await db.delete(
        table,
        where: where,
        whereArgs: whereArgs,
      );
      AppLogger().d('删除表 $table 数据成功，影响 $count 条记录');
      return count;
    } catch (e) {
      AppLogger().e('删除表 $table 数据失败: $e');
      rethrow;
    }
  }

  // 执行原始SQL
  Future<List<Map<String, dynamic>>> rawQuery(String sql,
      [List<dynamic>? arguments]) async {
    try {
      final db = await database;
      final results = await db.rawQuery(sql, arguments);
      AppLogger().d('执行原始SQL成功，返回 ${results.length} 条记录');
      return results;
    } catch (e) {
      AppLogger().e('执行原始SQL失败: $e');
      rethrow;
    }
  }

  // 执行原始SQL更新
  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    try {
      final db = await database;
      final count = await db.rawUpdate(sql, arguments);
      AppLogger().d('执行原始SQL更新成功，影响 $count 条记录');
      return count;
    } catch (e) {
      AppLogger().e('执行原始SQL更新失败: $e');
      rethrow;
    }
  }

  // 清除表数据
  Future<int> clearTable(String table) async {
    try {
      final db = await database;
      final count = await db.delete(table);
      AppLogger().d('清除表 $table 数据成功，影响 $count 条记录');
      return count;
    } catch (e) {
      AppLogger().e('清除表 $table 数据失败: $e');
      rethrow;
    }
  }

  // 关闭数据库
  Future<void> close() async {
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;
        AppLogger().d('数据库关闭成功');
      }
    } catch (e) {
      AppLogger().e('关闭数据库失败: $e');
      rethrow;
    }
  }

  // 获取数据库版本
  Future<int> getVersion() async {
    try {
      final db = await database;
      final version = await db.getVersion();
      AppLogger().d('获取数据库版本成功: $version');
      return version;
    } catch (e) {
      AppLogger().e('获取数据库版本失败: $e');
      rethrow;
    }
  }

  // 设置数据库版本
  Future<void> setVersion(int version) async {
    try {
      final db = await database;
      await db.setVersion(version);
      AppLogger().d('设置数据库版本成功: $version');
    } catch (e) {
      AppLogger().e('设置数据库版本失败: $e');
      rethrow;
    }
  }
}
