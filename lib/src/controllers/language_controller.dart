import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';
import '../utils/sp_util.dart';

/// 语言控制器 - 使用GetX实现
/// 管理应用语言设置和系统语言变化监听
class LanguageController extends GetxController {
  // 响应式状态
  final currentLocale = Rx<Locale?>(null);
  final languageCode = 'system'.obs;

  @override
  void onInit() {
    super.onInit();
    // 同步加载语言设置，确保在应用启动时就能正确设置语言
    _loadSavedLanguageSync();

    // 添加系统语言变化监听器
    WidgetsBinding.instance.platformDispatcher.onLocaleChanged = () {
      // 当系统语言变化时，如果当前设置为系统语言，更新应用语言
      if (languageCode.value == 'system') {
        final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
        AppLogger().d(
            '系统语言变化: ${systemLocale.languageCode}_${systemLocale.countryCode}');
        final matchedLocale = matchSystemLocale(systemLocale);
        AppLogger().d('匹配语言: ${matchedLocale.languageCode}_le.countryCode}');
        currentLocale.value = matchedLocale;
        Get.updateLocale(matchedLocale);
        update();
      }
    };
  }

  /// 同步加载保存的语言设置
  void _loadSavedLanguageSync() {
    languageCode.value = SpUtil.get<String>('language_code') ?? 'system';
    _updateLocaleSync();
  }

  /// 同步更新语言设置
  void _updateLocaleSync() {
    if (languageCode.value == 'system') {
      // 获取当前的系统语言
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      // 打印系统语言信息
      AppLogger()
          .d('系统语言: ${systemLocale.languageCode}_${systemLocale.countryCode}');
      // 尝试找到与系统语言匹配的支持的语言
      final matchedLocale = matchSystemLocale(systemLocale);
      // 打印匹配的语言信息
      AppLogger().d(
          '匹配语言: ${matchedLocale.languageCode}_${matchedLocale.countryCode}');
      currentLocale.value = matchedLocale;
      Get.updateLocale(matchedLocale);
    } else if (languageCode.value == 'en') {
      currentLocale.value = Locale('en');
      Get.updateLocale(currentLocale.value!);
    } else if (languageCode.value == 'zh') {
      currentLocale.value = Locale('zh');
      Get.updateLocale(currentLocale.value!);
    } else if (languageCode.value == 'zh_TW') {
      currentLocale.value = Locale('zh', 'TW');
      Get.updateLocale(currentLocale.value!);
    }
  }

  /// 处理特殊语言情况
  /// 例如：澳门(MO)使用繁体中文
  Locale? handleSpecialLanguageCases(Locale? locale) {
    if (locale != null) {
      // 特殊处理：澳门(MO)使用繁体中文
      if (locale.languageCode == 'zh' && locale.countryCode == 'MO') {
        return Locale('zh', 'TW');
      }
    }
    return null;
  }

  /// 匹配系统语言到支持的语言
  Locale matchSystemLocale(Locale systemLocale) {
    // 处理特殊语言情况
    final specialLocale = handleSpecialLanguageCases(systemLocale);
    if (specialLocale != null) {
      return specialLocale;
    }

    // 特殊处理：中文地区语言
    if (systemLocale.languageCode == 'zh') {
      // 获取国家/地区代码
      final countryCode = systemLocale.countryCode;

      // 如果不是中国大陆，使用繁体中文
      if (countryCode != 'CN') {
        return Locale('zh', 'TW');
      }
      // 否则使用简体中文
      return Locale('zh', 'CN');
    }

    // 支持的语言列表
    final supportedLocales = [
      Locale('en'), // 英语
      Locale('zh'), // 简体中文
      Locale('zh', 'TW'), // 繁体中文
    ];

    // 尝试找到完全匹配的语言
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == systemLocale.languageCode &&
          (supportedLocale.countryCode == null ||
              supportedLocale.countryCode == systemLocale.countryCode)) {
        return supportedLocale;
      }
    }

    // 如果没有完全匹配的，尝试只匹配语言代码
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == systemLocale.languageCode) {
        return supportedLocale;
      }
    }

    // 如果系统语言不支持，返回英语
    return Locale('en');
  }

  /// 更改应用语言
  /// [code] 语言代码：'system'、'en'、'zh'、'zh_TW'
  Future<void> changeLanguage(String code) async {
    languageCode.value = code;
    await SpUtil.put('language_code', code);
    _updateLocaleSync();
    update();
  }

  /// 更新语言设置
  Future<void> _updateLocale() async {
    _updateLocaleSync();
  }

  /// 获取支持的语言选项
  List<LanguageOption> get languageOptions => [
        LanguageOption('system', 'systemLanguage', '跟随系统'),
        LanguageOption('en', 'english', 'English'),
        LanguageOption('zh', 'chinese', '简体中文'),
        LanguageOption('zh_TW', 'traditionalChinese', '繁體中文'),
      ];
}

/// 语言选项模型
class LanguageOption {
  final String code;
  final String nameKey;
  final String displayName;

  LanguageOption(this.code, this.nameKey, this.displayName);
}
