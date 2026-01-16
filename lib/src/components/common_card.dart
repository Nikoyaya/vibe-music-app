import 'package:flutter/material.dart';

/// 通用卡片组件
/// 用于在应用中创建一致的卡片样式
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

  const CommonCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(vertical: 8),
    this.borderRadius,
    this.boxShadow,
    this.backgroundColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultBorderRadius = BorderRadius.circular(12);
    final defaultBoxShadow = [
      BoxShadow(
        color: Colors.black.withAlpha(26),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];

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

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}
