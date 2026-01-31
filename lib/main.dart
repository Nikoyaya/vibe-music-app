import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/generated/app_localizations.dart';
import 'package:vibe_music_app/src/routes/app_routes.dart';
import 'package:vibe_music_app/src/theme/app_theme.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';
import 'package:vibe_music_app/src/utils/database/index.dart';
import 'package:vibe_music_app/src/providers/language_provider.dart';
import 'package:vibe_music_app/src/services/localization_service.dart';

import 'package:vibe_music_app/src/utils/sp_util.dart';
import 'package:vibe_music_app/src/utils/di/dependency_injection.dart';

Future<void> main() async {
  final stopwatch = Stopwatch()..start();

  // 确保Flutter绑定已初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 先初始化日志工具
  AppLogger().initialize();
  AppLogger().d('✅ Flutter绑定初始化完成');

  // 初始化其他组件
  await _initializeEnvironment();
  await _initializeUtilities();

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
  // 初始化SpUtil存储工具
  await SpUtil.init();

  // 初始化数据库
  await DatabaseManager().initDatabase();

  // 数据库将在首次使用时自动初始化
  AppLogger().d('✅ 工具类初始化完成');
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
      // 构建器回调，用于初始化本地化服务
      builder: (context, child) {
        // 初始化 LanguageProvider
        if (!Get.isRegistered<LanguageProvider>()) {
          Get.put(LanguageProvider());
        }
        // 初始化本地化服务
        LocalizationService.init(context);
        return child!;
      },
      // 国际化配置
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'), // 英语
        Locale('zh'), // 简体中文
        Locale('zh', 'TW'), // 繁体中文
      ],
      locale: Get.isRegistered<LanguageProvider>()
          ? Get.find<LanguageProvider>().currentLocale
          : null,
      localeResolutionCallback: (locale, supportedLocales) {
        if (Get.isRegistered<LanguageProvider>()) {
          final languageProvider = Get.find<LanguageProvider>();
          // 如果用户选择了系统语言，使用系统语言
          if (languageProvider.languageCode == 'system') {
            // 优先使用系统语言
            if (locale != null) {
              // 尝试找到与系统语言匹配的支持的语言
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode &&
                    (supportedLocale.countryCode == null ||
                        supportedLocale.countryCode == locale.countryCode)) {
                  return supportedLocale;
                }
              }
              // 如果没有完全匹配的，尝试只匹配语言代码
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  return supportedLocale;
                }
              }
            }
            // 如果系统语言不支持，返回支持的语言列表中的第一个
            return supportedLocales.first;
          }
          // 否则使用用户选择的语言
          return languageProvider.currentLocale ?? supportedLocales.first;
        }
        // 如果 LanguageProvider 未注册，直接使用系统语言
        if (locale != null) {
          // 尝试找到与系统语言匹配的支持的语言
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode &&
                (supportedLocale.countryCode == null ||
                    supportedLocale.countryCode == locale.countryCode)) {
              return supportedLocale;
            }
          }
          // 如果没有完全匹配的，尝试只匹配语言代码
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
        }
        // 如果系统语言不支持，返回支持的语言列表中的第一个
        return supportedLocales.first;
      },
    );
  }
}
