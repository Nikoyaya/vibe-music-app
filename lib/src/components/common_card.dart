import 'package:flutter/material.dart';

/// 通用卡片组件
///
/// 用于在应用中创建一致的卡片样式，支持自定义内边距、外边距、边框半径、阴影和背景色
class CommonCard extends StatelessWidget {
  /// 卡片子组件
  final Widget child;

  /// 卡片内边距
  final EdgeInsetsGeometry padding;

  /// 卡片外边距
  final EdgeInsetsGeometry margin;

  /// 卡片边框半径
  final BorderRadiusGeometry? borderRadius;

  /// 卡片阴影
  final List<BoxShadow>? boxShadow;

  /// 卡片背景色
  final Color? backgroundColor;

  /// 卡片点击回调
  final GestureDragCancelCallback? onTap;

  /// 通用卡片构造函数
  ///
  /// [参数说明]:
  /// - [child]: 卡片内部的子组件
  /// - [padding]: 卡片内边距，默认16
  /// - [margin]: 卡片外边距，默认垂直方向8
  /// - [borderRadius]: 卡片边框半径，默认12
  /// - [boxShadow]: 卡片阴影，默认使用轻微的黑色阴影
  /// - [backgroundColor]: 卡片背景色，默认使用主题的surfaceContainerHighest颜色
  /// - [onTap]: 卡片点击回调函数，默认null
  const CommonCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(vertical: 8),
    this.borderRadius,
    this.boxShadow,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 默认边框半径
    final defaultBorderRadius = BorderRadius.circular(12);
    // 默认阴影效果
    final defaultBoxShadow = [
      BoxShadow(
        color: Colors.black.withAlpha(26),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];

    // 创建卡片容器
    final card = Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? defaultBorderRadius,
        boxShadow: boxShadow ?? defaultBoxShadow,
        color: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: child,
    );

    // 如果有点击回调，则包装为GestureDetector
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    // 否则直接返回卡片
    return card;
  }
}
