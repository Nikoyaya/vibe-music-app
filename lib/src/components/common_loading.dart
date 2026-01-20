import 'package:flutter/material.dart';

/// 通用加载指示器组件
///
/// 用于在应用中显示加载状态，包含一个圆形进度指示器和可选的加载文本
class CommonLoading extends StatelessWidget {
  /// 加载文本
  final String? text;

  /// 加载指示器大小
  final double size;

  /// 加载指示器颜色
  final Color? color;

  /// 加载文本样式
  final TextStyle? textStyle;

  /// 通用加载指示器构造函数
  ///
  /// [参数说明]:
  /// - [text]: 加载文本，默认'加载中...'
  /// - [size]: 加载指示器大小，默认40
  /// - [color]: 加载指示器颜色，默认使用主题的primary颜色
  /// - [textStyle]: 加载文本样式，默认使用主题的bodyMedium样式
  const CommonLoading({
    Key? key,
    this.text = '加载中...',
    this.size = 40,
    this.color,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? Theme.of(context).colorScheme.primary,
            ),
          ),
          if (text != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                text!,
                style: textStyle ?? Theme.of(context).textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }
}

/// 通用加载占位符组件
///
/// 用于在列表或网格中显示加载状态，是一个带有圆形进度指示器的容器
class CommonLoadingPlaceholder extends StatelessWidget {
  /// 占位符高度
  final double? height;

  /// 占位符宽度
  final double? width;

  /// 占位符边框半径
  final BorderRadiusGeometry borderRadius;

  /// 通用加载占位符构造函数
  ///
  /// [参数说明]:
  /// - [height]: 占位符高度，默认null
  /// - [width]: 占位符宽度，默认null
  /// - [borderRadius]: 占位符边框半径，默认0
  const CommonLoadingPlaceholder({
    Key? key,
    this.height,
    this.width,
    this.borderRadius = BorderRadius.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }
}
