import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';
import 'package:vibe_music_app/src/utils/database/index.dart';
import 'package:vibe_music_app/src/utils/sp_util.dart';
import 'package:vibe_music_app/src/utils/di/dependency_injection.dart';

/// 应用初始化器
/// 负责处理应用启动前的所有初始化操作
class AppInitializer {
  /// 初始化应用
  /// [返回值]: 初始化是否成功
  static Future<bool> initialize() async {
    final stopwatch = Stopwatch()..start();

    try {
      // 确保Flutter绑定已初始化
      WidgetsFlutterBinding.ensureInitialized();
      AppLogger().d('✅ Flutter绑定初始化完成');

      // 初始化环境变量
      await _initializeEnvironment();

      // 初始化工具类
      await _initializeUtilities();

      // 初始化依赖注入
      await _initializeDependencyInjection();

      // 启动时间统计
      stopwatch.stop();
      AppLogger().d('🚀 应用初始化完成，耗时: ${stopwatch.elapsedMilliseconds}ms');

      return true;
    } catch (e) {
      AppLogger().e('❌ 应用初始化失败: $e');
      return false;
    }
  }

  /// 初始化环境变量
  static Future<void> _initializeEnvironment() async {
    await dotenv.load(fileName: ".env");
    AppLogger().d('✅ 环境变量加载完成');
  }

  /// 初始化工具类
  static Future<void> _initializeUtilities() async {
    // 初始化SpUtil存储工具
    await SpUtil.init();

    try {
      // 初始化数据库
      await DatabaseManager().initDatabase();
    } catch (e) {
      AppLogger().e('数据库初始化失败: $e');
    }

    // 工具类初始化完成
    AppLogger().d('✅ 工具类初始化完成');
  }

  /// 初始化依赖注入
  static Future<void> _initializeDependencyInjection() async {
    DependencyInjection.init();
  }
}
