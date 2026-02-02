import 'package:flutter/material.dart';
import 'dart:math';

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

  /// 小桌面布局（可选）
  final Widget? smallDesktopLayout;

  /// 大桌面布局（可选）
  final Widget? largeDesktopLayout;

  /// 响应式布局构造函数
  ///
  /// [参数说明]:
  /// - [mobileLayout]: 移动端布局组件
  /// - [tabletLayout]: 平板端布局组件
  /// - [desktopLayout]: 桌面端布局组件
  /// - [smallDesktopLayout]: 小桌面布局组件（可选）
  /// - [largeDesktopLayout]: 大桌面布局组件（可选）
  const ResponsiveLayout({
    Key? key,
    required this.mobileLayout,
    required this.tabletLayout,
    required this.desktopLayout,
    this.smallDesktopLayout,
    this.largeDesktopLayout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // 移动端布局
          return mobileLayout;
        } else if (constraints.maxWidth < 1024) {
          // 平板端布局
          return tabletLayout;
        } else if (constraints.maxWidth < 1440) {
          // 小桌面布局
          return smallDesktopLayout ?? desktopLayout;
        } else {
          // 大桌面布局
          return largeDesktopLayout ?? desktopLayout;
        }
      },
    );
  }
}

/// 屏幕尺寸工具类
///
/// 提供判断当前屏幕尺寸类型和获取屏幕尺寸的静态方法
class ScreenSize {
  /// 屏幕断点定义
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double smallDesktopBreakpoint = 1440;
  static const double largeDesktopBreakpoint = 1920;

  /// 判断是否为移动端屏幕
  ///
  /// [参数说明]:
  /// - [context]: 构建上下文
  ///
  /// [返回值]: 如果屏幕宽度小于600，则返回true
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// 判断是否为平板端屏幕
  ///
  /// [参数说明]:
  /// - [context]: 构建上下文
  ///
  /// [返回值]: 如果屏幕宽度大于等于600且小于1024，则返回true
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// 判断是否为小桌面屏幕
  ///
  /// [参数说明]:
  /// - [context]: 构建上下文
  ///
  /// [返回值]: 如果屏幕宽度大于等于1024且小于1440，则返回true
  static bool isSmallDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletBreakpoint && width < smallDesktopBreakpoint;
  }

  /// 判断是否为桌面端屏幕
  ///
  /// [参数说明]:
  /// - [context]: 构建上下文
  ///
  /// [返回值]: 如果屏幕宽度大于等于1024，则返回true
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  /// 判断是否为大桌面屏幕
  ///
  /// [参数说明]:
  /// - [context]: 构建上下文
  ///
  /// [返回值]: 如果屏幕宽度大于等于1440，则返回true
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= smallDesktopBreakpoint;
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

  /// 获取屏幕对角线尺寸
  ///
  /// [参数说明]:
  /// - [context]: 构建上下文
  ///
  /// [返回值]: 屏幕对角线尺寸
  static double getDiagonal(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return sqrt(size.width * size.width + size.height * size.height);
  }

  /// 获取屏幕方向
  ///
  /// [参数说明]:
  /// - [context]: 构建上下文
  ///
  /// [返回值]: 屏幕方向
  static Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// 判断是否为横屏
  ///
  /// [参数说明]:
  /// - [context]: 构建上下文
  ///
  /// [返回值]: 如果屏幕为横屏，则返回true
  static bool isLandscape(BuildContext context) {
    return getOrientation(context) == Orientation.landscape;
  }

  /// 判断是否为竖屏
  ///
  /// [参数说明]:
  /// - [context]: 构建上下文
  ///
  /// [返回值]: 如果屏幕为竖屏，则返回true
  static bool isPortrait(BuildContext context) {
    return getOrientation(context) == Orientation.portrait;
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

  /// 小桌面端内边距
  final EdgeInsets smallDesktopPadding;

  /// 桌面端内边距
  final EdgeInsets desktopPadding;

  /// 自适应容器构造函数
  ///
  /// [参数说明]:
  /// - [child]: 容器内部的子组件
  /// - [mobilePadding]: 移动端内边距，默认16
  /// - [tabletPadding]: 平板端内边距，默认24
  /// - [smallDesktopPadding]: 小桌面端内边距，默认32
  /// - [desktopPadding]: 桌面端内边距，默认40
  const AdaptiveContainer({
    Key? key,
    required this.child,
    this.mobilePadding = const EdgeInsets.all(16),
    this.tabletPadding = const EdgeInsets.all(24),
    this.smallDesktopPadding = const EdgeInsets.all(32),
    this.desktopPadding = const EdgeInsets.all(40),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding;
    if (ScreenSize.isMobile(context)) {
      padding = mobilePadding;
    } else if (ScreenSize.isTablet(context)) {
      padding = tabletPadding;
    } else if (ScreenSize.isSmallDesktop(context)) {
      padding = smallDesktopPadding;
    } else {
      padding = desktopPadding;
    }

    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// 自适应侧边栏宽度组件
///
/// 根据屏幕尺寸自动调整侧边栏宽度
class AdaptiveSidebarWidth extends StatelessWidget {
  /// 侧边栏子组件
  final Widget child;

  /// 移动端侧边栏宽度
  final double mobileWidth;

  /// 平板端侧边栏宽度
  final double tabletWidth;

  /// 小桌面端侧边栏宽度
  final double smallDesktopWidth;

  /// 桌面端侧边栏宽度
  final double desktopWidth;

  /// 自适应侧边栏宽度构造函数
  ///
  /// [参数说明]:
  /// - [child]: 侧边栏子组件
  /// - [mobileWidth]: 移动端侧边栏宽度，默认60
  /// - [tabletWidth]: 平板端侧边栏宽度，默认200
  /// - [smallDesktopWidth]: 小桌面端侧边栏宽度，默认220
  /// - [desktopWidth]: 桌面端侧边栏宽度，默认240
  const AdaptiveSidebarWidth({
    Key? key,
    required this.child,
    this.mobileWidth = 60,
    this.tabletWidth = 200,
    this.smallDesktopWidth = 220,
    this.desktopWidth = 240,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width;
    if (ScreenSize.isMobile(context)) {
      width = mobileWidth;
    } else if (ScreenSize.isTablet(context)) {
      width = tabletWidth;
    } else if (ScreenSize.isSmallDesktop(context)) {
      width = smallDesktopWidth;
    } else {
      width = desktopWidth;
    }

    return Container(
      width: width,
      child: child,
    );
  }
}
