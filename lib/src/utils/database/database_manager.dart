import 'dart:async';
import 'package:floor/floor.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:vibe_music_app/src/data/database/app_database.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';

/// 数据库管理器
/// 用于初始化数据库并提供单例实例
class DatabaseManager {
  /// 单例实例
  static final DatabaseManager _instance = DatabaseManager._internal();

  /// 数据库实例
  static AppDatabase? _database;

  /// 获取单例实例
  factory DatabaseManager() => _instance;

  /// 私有构造函数
  DatabaseManager._internal();

  /// 初始化数据库
  Future<AppDatabase> initDatabase() async {
    if (_database != null) {
      return _database!;
    }

    try {
      // 获取数据库路径
      final databasePath = await sqflite.getDatabasesPath();
      final path = join(databasePath, 'vibe_music.db');

      AppLogger().d('初始化数据库，路径: $path');

      // 打开数据库
      _database = await $FloorAppDatabase.databaseBuilder(path).build();
      AppLogger().d('数据库初始化成功');
      return _database!;
    } catch (e) {
      AppLogger().e('数据库初始化失败: $e');
      rethrow;
    }
  }

  /// 获取数据库实例
  Future<AppDatabase> get database async {
    if (_database == null) {
      await initDatabase();
    }
    return _database!;
  }

  /// 关闭数据库
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      AppLogger().d('数据库关闭成功');
    }
  }

  /// 清除所有数据库数据
  Future<void> clearAllData() async {
    final db = await database;
    await db.userDao.clearAllUsers();
    await db.songDao.clearAllSongs();
    await db.playlistDao.clearAllPlaylists();
    await db.playlistSongDao.clearAllPlaylistSongs();
    await db.playHistoryDao.clearAllPlayHistory();
    AppLogger().d('所有数据库数据清除成功');
  }
}
