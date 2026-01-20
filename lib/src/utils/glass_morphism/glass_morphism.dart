import 'dart:ui';
import 'package:flutter/material.dart';

/// 玻璃拟态效果工具类
///
/// 提供创建具有玻璃拟态效果的UI组件的静态方法
/// 玻璃拟态效果是一种半透明、模糊背景的设计风格
class GlassMorphism {
  /// 创建玻璃拟态卡片
  ///
  /// [参数说明]:
  /// - [child]: 卡片内部的子组件
  /// - [blur]: 模糊程度，默认10
  /// - [opacity]: 透明度，默认0.2
  /// - [borderRadius]: 圆角半径，默认16
  /// - [padding]: 内边距，默认16
  /// - [borderColor]: 边框颜色，默认白色
  ///
  /// [返回值]: 带有玻璃拟态效果的卡片组件
  static Widget glassCard({
    required Widget child,
    double blur = 10,
    double opacity = 0.2,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(16)),
    EdgeInsets padding = const EdgeInsets.all(16),
    Color borderColor = Colors.white,
  }) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(
              color: borderColor.withOpacity(0.2),
              width: 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(opacity),
                Colors.white.withOpacity(opacity * 0.5),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  /// 创建玻璃拟态容器
  ///
  /// [参数说明]:
  /// - [child]: 容器内部的子组件
  /// - [blur]: 模糊程度，默认10
  /// - [opacity]: 透明度，默认0.1
  /// - [borderRadius]: 圆角半径，默认0
  /// - [padding]: 内边距，默认0
  ///
  /// [返回值]: 带有玻璃拟态效果的容器组件
  static Widget glassContainer({
    required Widget child,
    double blur = 10,
    double opacity = 0.1,
    BorderRadius borderRadius = BorderRadius.zero,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(opacity),
                Colors.white.withOpacity(opacity * 0.5),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  /// 创建玻璃拟态按钮
  ///
  /// [参数说明]:
  /// - [child]: 按钮内部的子组件
  /// - [onPressed]: 按钮点击回调函数
  /// - [blur]: 模糊程度，默认8
  /// - [opacity]: 透明度，默认0.2
  /// - [borderRadius]: 圆角半径，默认8
  /// - [padding]: 内边距，默认水平16，垂直8
  ///
  /// [返回值]: 带有玻璃拟态效果的按钮组件
  static Widget glassButton({
    required Widget child,
    required VoidCallback onPressed,
    double blur = 8,
    double opacity = 0.2,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(8)),
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  }) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(opacity),
                  Colors.white.withOpacity(opacity * 0.5),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}