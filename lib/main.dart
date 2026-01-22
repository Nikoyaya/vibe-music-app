import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/src/routes/app_routes.dart';
import 'package:vibe_music_app/src/theme/app_theme.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';
import 'package:vibe_music_app/src/utils/sp_util.dart';
import 'package:vibe_music_app/src/utils/di/dependency_injection.dart';

Future<void> main() async {
  // 加载环境变量
  await dotenv.load(fileName: ".env");
  // 初始化AppLogger日志工具
  AppLogger().initialize();
  // 初始化SpUtil存储工具
  await SpUtil.init();
  // 初始化GetX依赖注入
  DependencyInjection.init();
  // 运行应用
  runApp(const VibeMusicApp());
}

/// Vibe Music 应用主组件
class VibeMusicApp extends StatelessWidget {
  const VibeMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Vibe Music', // 应用标题
      theme: AppTheme.lightTheme, // 亮色主题
      darkTheme: AppTheme.darkTheme, // 暗色主题
      themeMode: ThemeMode.dark, // 默认使用深色主题
      initialRoute: AppRoutes.home, // 初始路由为主页
      getPages: AppRoutes.routes, // 应用路由配置
      debugShowCheckedModeBanner: false, // 隐藏调试横幅
    );
  }
}
