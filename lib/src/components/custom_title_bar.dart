import 'package:flutter/material.dart';
import 'package:vibe_music_app/src/theme/app_theme.dart';

/// 自定义标题栏组件
/// 用于桌面端应用的自定义窗口标题栏
class CustomTitleBar extends StatelessWidget {
  /// 标题栏高度
  final double height;

  /// 标题文本
  final String title;

  /// 标题栏背景色
  final Color? backgroundColor;

  /// 标题文本颜色
  final Color? titleColor;

  /// 是否显示应用图标
  final bool showIcon;

  /// 图标路径
  final String iconPath;

  const CustomTitleBar({
    Key? key,
    this.height = 50.0,
    this.title = 'Vibe Music',
    this.backgroundColor,
    this.titleColor,
    this.showIcon = true,
    this.iconPath = 'assets/images/icons/icon.png',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.darkTheme;
    final bgColor = backgroundColor ?? theme.colorScheme.surface;
    final textColor = titleColor ?? theme.colorScheme.onSurface;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          // 左侧：应用图标和标题
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  if (showIcon)
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Image.asset(
                        'assets/images/icons/icon.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 右侧：窗口控制按钮
          Row(
            children: [
              // 最小化按钮
              WindowButton(
                icon: const MinimizeIcon(),
                onPressed: () {},
                backgroundColor: bgColor,
                iconColor: textColor.withOpacity(0.7),
                hoverColor: Colors.grey.withOpacity(0.2),
              ),

              // 最大化按钮
              WindowButton(
                icon: const MaximizeIcon(),
                onPressed: () {},
                backgroundColor: bgColor,
                iconColor: textColor.withOpacity(0.7),
                hoverColor: Colors.grey.withOpacity(0.2),
              ),

              // 关闭按钮
              WindowButton(
                icon: const CloseIcon(),
                onPressed: () {},
                backgroundColor: bgColor,
                iconColor: textColor.withOpacity(0.7),
                hoverColor: Colors.red.withOpacity(0.8),
                hoverIconColor: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 窗口按钮组件
class WindowButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final Color hoverColor;
  final Color? hoverIconColor;
  final double size;

  const WindowButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    required this.iconColor,
    required this.hoverColor,
    this.hoverIconColor,
    this.size = 46.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: size,
          height: size,
          color: backgroundColor,
          child: Center(
            child: IconTheme(
              data: IconThemeData(
                color: hoverIconColor ?? iconColor,
                size: 16,
              ),
              child: icon,
            ),
          ),
        ),
      ),
    );
  }
}

/// 最小化图标
class MinimizeIcon extends StatelessWidget {
  const MinimizeIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 1,
      decoration: BoxDecoration(
        color: IconTheme.of(context).color!,
        borderRadius: BorderRadius.circular(0.5),
      ),
    );
  }
}

/// 最大化图标
class MaximizeIcon extends StatelessWidget {
  const MaximizeIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        border: Border.all(
          color: IconTheme.of(context).color!,
          width: 1,
        ),
      ),
    );
  }
}

/// 还原图标
class RestoreIcon extends StatelessWidget {
  const RestoreIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: IconTheme.of(context).color!,
          ),
        ),
        Positioned(
          bottom: 2,
          right: 2,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.colorScheme.surface,
            ),
          ),
        ),
      ],
    );
  }
}

/// 关闭图标
class CloseIcon extends StatelessWidget {
  const CloseIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      child: CustomPaint(
        painter: _CloseIconPainter(
          color: IconTheme.of(context).color!,
        ),
      ),
    );
  }
}

/// 关闭图标绘制器
class _CloseIconPainter extends CustomPainter {
  final Color color;

  _CloseIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // 绘制交叉线
    canvas.drawLine(
      Offset(2, 2),
      Offset(size.width - 2, size.height - 2),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - 2, 2),
      Offset(2, size.height - 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
