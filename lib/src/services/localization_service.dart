import 'package:flutter/material.dart';
import 'package:vibe_music_app/generated/app_localizations.dart';

/// 全局本地化服务
/// 用于在非 Widget 类（如控制器）中使用本地化字符串
class LocalizationService {
  static AppLocalizations? _instance;

  /// 初始化本地化服务
  /// 在应用启动时调用，传入 BuildContext
  static void init(BuildContext context) {
    _instance = AppLocalizations.of(context);
  }

  /// 获取本地化实例
  /// 如果未初始化，会抛出异常
  static AppLocalizations get instance {
    if (_instance == null) {
      throw Exception('LocalizationService not initialized. Call init(BuildContext context) first.');
    }
    return _instance!;
  }

  /// 检查本地化服务是否已初始化
  static bool get isInitialized => _instance != null;
}
