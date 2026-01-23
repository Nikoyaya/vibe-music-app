import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/src/routes/app_routes.dart';
import 'package:vibe_music_app/src/theme/app_theme.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';
import 'package:vibe_music_app/src/utils/database/database_helper.dart';
import 'package:vibe_music_app/src/utils/sp_util.dart';
import 'package:vibe_music_app/src/utils/di/dependency_injection.dart';

Future<void> main() async {
  final stopwatch = Stopwatch()..start();

  // 确保Flutter绑定已初始化
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger().d('✅ Flutter绑定初始化完成');

  // 并行初始化不相互依赖的组件
  await Future.wait([
    _initializeEnvironment(),
    _initializeUtilities(),
  ]);

  // 初始化依赖注入
  await _initializeDependencyInjection();

  // 启动时间统计
  stopwatch.stop();
  AppLogger().d('🚀 应用初始化完成，耗时: ${stopwatch.elapsedMilliseconds}ms');

  // 运行应用
  runApp(const VibeMusicApp());
}

/// 初始化环境变量
Future<void> _initializeEnvironment() async {
  await dotenv.load(fileName: ".env");
  AppLogger().d('✅ 环境变量加载完成');
}

/// 初始化工具类
Future<void> _initializeUtilities() async {
  // 初始化AppLogger日志工具
  AppLogger().initialize();

  // 初始化SpUtil存储工具
  await SpUtil.init();

  // 初始化DatabaseHelper数据库工具
  await DatabaseHelper().database;
}

/// 初始化依赖注入
Future<void> _initializeDependencyInjection() async {
  DependencyInjection.init();
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
