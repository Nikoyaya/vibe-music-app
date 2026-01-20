import 'package:flutter/material.dart';

/// 通用按钮组件
///
/// 用于在应用中创建一致的按钮样式，支持加载状态、禁用状态和图标
class CommonButton extends StatelessWidget {
  /// 按钮文本
  final String text;

  /// 按钮点击回调
  final VoidCallback onPressed;

  /// 按钮样式
  final ButtonStyle? style;

  /// 按钮图标
  final Widget? icon;

  /// 是否为加载状态
  final bool isLoading;

  /// 是否禁用
  final bool disabled;

  /// 通用按钮构造函数
  ///
  /// [参数说明]:
  /// - [text]: 按钮显示的文本
  /// - [onPressed]: 按钮点击时的回调函数
  /// - [style]: 按钮样式，默认使用ElevatedButton的默认样式
  /// - [icon]: 按钮左侧的图标，默认无图标
  /// - [isLoading]: 是否显示加载状态，默认false
  /// - [disabled]: 是否禁用按钮，默认false
  const CommonButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.style,
    this.icon,
    this.isLoading = false,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 默认按钮样式
    final defaultStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return ElevatedButton.icon(
      // 当加载状态或禁用状态时，按钮不可点击
      onPressed: (isLoading || disabled) ? null : onPressed,
      // 加载状态显示圆形进度指示器，否则显示图标或空容器
      icon: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            )
          : icon ?? const SizedBox.shrink(),
      // 按钮文本
      label: Text(text),
      // 使用自定义样式或默认样式
      style: style ?? defaultStyle,
    );
  }
}
