import 'package:flutter/material.dart';

/// 应用主题配置类
/// 定义了应用的明/暗两种主题样式
class AppTheme {
  /// 亮色主题（西瓜音乐风格）
  static final ThemeData lightTheme = ThemeData(
    /// 亮色主题颜色方案
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF34C759), // 主色调（绿色）
      secondary: const Color(0xFFFF6B6B), // 次要色调（西瓜红）
      surface: Colors.white, // 表面色
      error: Colors.red.shade600, // 错误色
      onPrimary: Colors.white, // 主色调上的文字颜色
      onSecondary: Colors.white, // 次要色调上的文字颜色
      onSurface: const Color(0xFF2E7D32), // 表面色上的文字颜色（深绿色）
      onError: Colors.white, // 错误色上的文字颜色
      brightness: Brightness.light, // 亮度
    ),
    useMaterial3: true, // 使用Material3设计
    scaffoldBackgroundColor: const Color(0xFFF8FFF9), // 脚手架背景色（浅绿色）
    /// 卡片主题
    cardTheme: CardThemeData(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // 圆角
      elevation: 3, // 阴影高度
      color: Colors.white, // 卡片颜色
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12), // 卡片边距
    ),

    /// 文字主题
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        // 大标题
        fontWeight: FontWeight.bold,
        fontSize: 32,
        color: const Color(0xFF2E7D32),
      ),
      headlineMedium: TextStyle(
        // 中标题
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: const Color(0xFF2E7D32),
      ),
      titleMedium: TextStyle(
        // 小标题
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: const Color(0xFF2E7D32),
      ),
      bodyMedium: TextStyle(
        // 中等正文
        fontSize: 16,
        color: const Color(0xFF4CAF50),
      ),
      bodySmall: TextStyle(
        // 小正文
        fontSize: 14,
        color: Colors.grey.shade600,
      ),
    ),

    /// 导航栏主题
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: const Color(0xFF34C759).withValues(alpha: 0.1),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(
          color: Color(0xFF2E7D32),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      iconTheme: WidgetStateProperty.all(
        const IconThemeData(
          color: Color(0xFF2E7D32),
        ),
      ),
    ),
  );

  /// 暗色主题（西瓜音乐风格自适应）
  static final ThemeData darkTheme = ThemeData(
    /// 暗色主题颜色方案
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF4CAF50), // 主色调（深绿色）
      secondary: const Color(0xFFFF6B6B), // 次要色调（西瓜红）
      surface: const Color(0xFF1A2E1D), // 表面色（深绿色调）
      error: Colors.red.shade400, // 错误色
      onPrimary: Colors.white, // 主色调上的文字颜色
      onSecondary: Colors.white, // 次要色调上的文字颜色
      onSurface: Colors.grey.shade100, // 表面色上的文字颜色
      onError: Colors.white, // 错误色上的文字颜色
      brightness: Brightness.dark, // 亮度
    ),
    useMaterial3: true, // 使用Material3设计
    scaffoldBackgroundColor: const Color(0xFF0D1B11), // 脚手架背景色（深黑色）
    /// 卡片主题
    cardTheme: CardThemeData(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // 圆角
      elevation: 3, // 阴影高度
      color: const Color(0xFF1A2E1D), // 卡片颜色（深绿色调）
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12), // 卡片边距
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
        fontSize: 20,
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

    /// 导航栏主题
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: const Color(0xFF4CAF50).withValues(alpha: 0.2),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      iconTheme: WidgetStateProperty.all(
        const IconThemeData(
          color: Colors.white,
        ),
      ),
    ),
  );
}
