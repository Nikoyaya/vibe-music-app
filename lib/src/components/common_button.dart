import 'package:flutter/material.dart';

/// 通用按钮组件
/// 用于在应用中创建一致的按钮样式
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
    final defaultStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return ElevatedButton.icon(
      onPressed: (isLoading || disabled) ? null : onPressed,
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
      label: Text(text),
      style: style ?? defaultStyle,
    );
  }
}
