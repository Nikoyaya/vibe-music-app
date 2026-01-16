import 'package:flutter/material.dart';

/// 应用主题配置类
/// 定义了应用的明/暗两种主题样式
class AppTheme {
  /// 亮色主题
  static final ThemeData lightTheme = ThemeData(
    /// 亮色主题颜色方案
    colorScheme: ColorScheme.light(
      primary: Colors.deepPurpleAccent, // 主色调
      secondary: Colors.purple.shade400, // 次要色调
      surface: Colors.white, // 表面色
      background: Colors.grey.shade50, // 背景色
      error: Colors.red.shade600, // 错误色
      onPrimary: Colors.white, // 主色调上的文字颜色
      onSecondary: Colors.white, // 次要色调上的文字颜色
      onSurface: Colors.grey.shade900, // 表面色上的文字颜色
      onError: Colors.white, // 错误色上的文字颜色
      brightness: Brightness.light, // 亮度
    ),
    useMaterial3: true, // 使用Material3设计
    scaffoldBackgroundColor: Colors.grey.shade50, // 脚手架背景色
    /// 卡片主题
    cardTheme: CardThemeData(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // 圆角
      elevation: 2, // 阴影高度
      color: Colors.white, // 卡片颜色
    ),
  );

  /// 暗色主题
  static final ThemeData darkTheme = ThemeData(
    /// 暗色主题颜色方案
    colorScheme: ColorScheme.dark(
      primary: Colors.deepPurpleAccent, // 主色调
      secondary: Colors.purple.shade300, // 次要色调
      surface: Colors.grey.shade900, // 表面色
      background: Colors.black, // 背景色
      error: Colors.red.shade400, // 错误色
      onPrimary: Colors.white, // 主色调上的文字颜色
      onSecondary: Colors.black, // 次要色调上的文字颜色
      onSurface: Colors.grey.shade100, // 表面色上的文字颜色
      onError: Colors.white, // 错误色上的文字颜色
      brightness: Brightness.dark, // 亮度
    ),
    useMaterial3: true, // 使用Material3设计
    scaffoldBackgroundColor: Colors.black, // 脚手架背景色
    /// 卡片主题
    cardTheme: CardThemeData(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // 圆角
      elevation: 3, // 阴影高度
      color: Colors.grey.shade900, // 卡片颜色
    ),

    /// 文字主题
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        // 大标题
        fontWeight: FontWeight.bold,
        fontSize: 32,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        // 中标题
        fontWeight: FontWeight.bold,
        fontSize: 24,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        // 小标题
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        // 中等正文
        fontSize: 16,
        color: Colors.grey.shade300,
      ),
      bodySmall: TextStyle(
        // 小正文
        fontSize: 14,
        color: Colors.grey.shade400,
      ),
    ),
  );
}
