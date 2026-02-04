import 'package:flutter/material.dart';
import 'package:vibe_music_app/src/config/app_config.dart';
import 'package:vibe_music_app/src/utils/app_initializer.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';

Future<void> main() async {
  // 先初始化日志工具
  AppLogger().initialize();

  // 初始化应用
  await AppInitializer.initialize();

  // 运行应用
  runApp(AppConfig.buildApp());
}
