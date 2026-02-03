import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/generated/app_localizations.dart';
import 'package:vibe_music_app/src/providers/language_provider.dart';
import 'package:vibe_music_app/src/routes/app_routes.dart';
import 'package:vibe_music_app/src/services/localization_service.dart';
import 'package:vibe_music_app/src/theme/app_theme.dart';

/// 应用配置类
/// 负责提供应用的全局配置
class AppConfig {
  /// 应用标题
  static const String appTitle = 'Vibe Music';

  /// 构建应用主组件
  static Widget buildApp() {
    return const VibeMusicApp();
  }

  /// 获取本地化代理
  static List<LocalizationsDelegate<dynamic>> getLocalizationsDelegates() {
    return [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];
  }

  /// 获取支持的语言列表
  static List<Locale> getSupportedLocales() {
    return [
      Locale('en'), // 英语
      Locale('zh'), // 简体中文
      Locale('zh', 'TW'), // 繁体中文
    ];
  }

  /// 获取当前语言
  static Locale? getCurrentLocale() {
    if (Get.isRegistered<LanguageProvider>()) {
      return Get.find<LanguageProvider>().currentLocale;
    }
    return null;
  }

  /// 语言解析回调
  static Locale? localeResolutionCallback(Locale? locale, Iterable<Locale> supportedLocales) {
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
  }
}

/// Vibe Music 应用主组件
class VibeMusicApp extends StatelessWidget {
  const VibeMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 在构建 GetMaterialApp 之前先注册 LanguageProvider
    if (!Get.isRegistered<LanguageProvider>()) {
      Get.put(LanguageProvider());
    }

    return GetMaterialApp(
      title: AppConfig.appTitle, // 应用标题
      theme: AppTheme.lightTheme, // 亮色主题
      darkTheme: AppTheme.darkTheme, // 暗色主题
      themeMode: ThemeMode.dark, // 默认使用深色主题
      initialRoute: AppRoutes.home, // 初始路由为主页
      getPages: AppRoutes.routes, // 应用路由配置
      debugShowCheckedModeBanner: false, // 隐藏调试横幅
      // 构建器回调，用于初始化本地化服务
      builder: (context, child) {
        // 初始化本地化服务
        LocalizationService.init(context);
        return child!;
      },
      // 国际化配置
      localizationsDelegates: AppConfig.getLocalizationsDelegates(),
      supportedLocales: AppConfig.getSupportedLocales(),
      locale: AppConfig.getCurrentLocale(),
      localeResolutionCallback: AppConfig.localeResolutionCallback,
    );
  }
}
