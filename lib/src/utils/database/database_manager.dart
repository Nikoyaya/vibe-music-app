import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:vibe_music_app/src/data/database/app_database.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';
import 'package:vibe_music_app/src/utils/storage/platform_storage.dart';

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
      // 对于 Web 平台，使用 PlatformStorage 作为备选方案
      if (kIsWeb) {
        AppLogger().d('Web 平台使用 PlatformStorage 作为存储方案');
        // 初始化 PlatformStorage
        await PlatformStorage().init();
        AppLogger().d('Web 平台存储初始化成功');

        // 由于 Web 平台无法使用 SQLite，我们需要返回一个模拟的 AppDatabase
        // 这里抛出一个特定的错误，让应用知道 Web 平台的限制
        throw UnimplementedError('Web 平台使用 PlatformStorage 代替 SQLite');
      }

      // 非 Web 平台尝试使用标准数据库
      AppLogger().d('非 Web 平台初始化数据库');
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

      // 对于所有平台，如果数据库初始化失败，使用 PlatformStorage 作为备选方案
      AppLogger().d('尝试使用 PlatformStorage 作为备选存储方案');
      await PlatformStorage().init();
      AppLogger().d('备选存储方案初始化成功');

      // 抛出一个特定的错误，让应用知道使用了备选存储方案
      throw UnimplementedError('使用 PlatformStorage 代替 SQLite');
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
