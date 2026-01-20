import 'package:flutter/material.dart';

/// 响应式布局组件
///
/// 根据屏幕宽度自动切换不同的布局
/// 支持移动端、平板端和桌面端三种布局模式
class ResponsiveLayout extends StatelessWidget {
  /// 移动端布局
  final Widget mobileLayout;
  /// 平板端布局
  final Widget tabletLayout;
  /// 桌面端布局
  final Widget desktopLayout;
  
  /// 响应式布局构造函数
  ///
  /// [参数说明]:
  /// - [mobileLayout]: 移动端布局组件
  /// - [tabletLayout]: 平板端布局组件
  /// - [desktopLayout]: 桌面端布局组件
  const ResponsiveLayout({
    super.key,
    required this.mobileLayout,
    required this.tabletLayout,
    required this.desktopLayout,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // 移动端布局
          return mobileLayout;
        } else if (constraints.maxWidth < 1200) {
          // 平板端布局
          return tabletLayout;
        } else {
          // 桌面端布局
          return desktopLayout;
        }
      },
    );
  }
}

/// 屏幕尺寸工具类
///
/// 提供判断当前屏幕尺寸类型和获取屏幕尺寸的静态方法
class ScreenSize {
  /// 判断是否为移动端屏幕
  ///
  /// [参数说明]:
  /// - [context]: 构建上下文
  ///
  /// [返回值]: 如果屏幕宽度小于600，则返回true
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  /// 判断是否为平板端屏幕
  ///
  /// [参数说明]:
  /// - [context]: 构建上下文
  ///
  /// [返回值]: 如果屏幕宽度大于等于600且小于1200，则返回true
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }

  /// 判断是否为桌面端屏幕
  ///
  /// [参数说明]:
  /// - [context]: 构建上下文
  ///
  /// [返回值]: 如果屏幕宽度大于等于1200，则返回true
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  /// 获取屏幕宽度
  ///
  /// [参数说明]:
  /// - [context]: 构建上下文
  ///
  /// [返回值]: 屏幕宽度
  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// 获取屏幕高度
  ///
  /// [参数说明]:
  /// - [context]: 构建上下文
  ///
  /// [返回值]: 屏幕高度
  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}

/// 自适应容器组件
///
/// 根据屏幕尺寸自动调整内边距
class AdaptiveContainer extends StatelessWidget {
  /// 容器内部的子组件
  final Widget child;
  /// 移动端内边距
  final EdgeInsets mobilePadding;
  /// 平板端内边距
  final EdgeInsets tabletPadding;
  /// 桌面端内边距
  final EdgeInsets desktopPadding;
  
  /// 自适应容器构造函数
  ///
  /// [参数说明]:
  /// - [child]: 容器内部的子组件
  /// - [mobilePadding]: 移动端内边距，默认16
  /// - [tabletPadding]: 平板端内边距，默认24
  /// - [desktopPadding]: 桌面端内边距，默认32
  const AdaptiveContainer({
    super.key,
    required this.child,
    this.mobilePadding = const EdgeInsets.all(16),
    this.tabletPadding = const EdgeInsets.all(24),
    this.desktopPadding = const EdgeInsets.all(32),
  });

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding;
    if (ScreenSize.isMobile(context)) {
      padding = mobilePadding;
    } else if (ScreenSize.isTablet(context)) {
      padding = tabletPadding;
    } else {
      padding = desktopPadding;
    }

    return Padding(
      padding: padding,
      child: child,
    );
  }
}