import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/src/utils/sp_util.dart';

/// 主题类型枚举
enum ThemeType {
  light,
  dark,
  glassMorphism,
}

/// 主题控制器
/// 负责管理应用的主题状态
class ThemeController extends GetxController {
  /// 主题类型
  final Rx<ThemeType> themeType = ThemeType.dark.obs;

  /// 初始化
  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  /// 加载主题
  void _loadTheme() {
    final themeIndex = SpUtil.get<int>('theme_type');
    if (themeIndex != null) {
      themeType.value = ThemeType.values[themeIndex];
    }
  }

  /// 切换主题
  Future<void> changeTheme(ThemeType type) async {
    themeType.value = type;
    await SpUtil.put('theme_type', type.index);
    update();
    // 重建整个应用以应用新主题
    Get.forceAppUpdate();
  }

  /// 获取当前主题模式
  ThemeMode getThemeMode() {
    switch (themeType.value) {
      case ThemeType.light:
        return ThemeMode.light;
      case ThemeType.dark:
        return ThemeMode.dark;
      case ThemeType.glassMorphism:
        return ThemeMode.dark; // 毛玻璃主题使用暗色模式作为基础
      default:
        return ThemeMode.dark;
    }
  }

  /// 检查是否为毛玻璃主题
  bool isGlassMorphismTheme() {
    return themeType.value == ThemeType.glassMorphism;
  }
}
