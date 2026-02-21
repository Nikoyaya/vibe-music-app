import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/src/controllers/theme_controller.dart';

/// 毛玻璃背景组件
/// 用于在毛玻璃主题时显示渐变背景
class GlassMorphismBackground extends StatelessWidget {
  final Widget child;

  const GlassMorphismBackground({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isGlassMorphism = themeController.isGlassMorphismTheme();

    return isGlassMorphism
        ? Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6366F1), // 靛蓝色
                  Color(0xFF8B5CF6), // 紫色
                  Color(0xFFEC4899), // 粉红色
                ],
              ),
            ),
            child: child,
          )
        : child;
  }
}

/// 带有透明背景的Scaffold，用于毛玻璃主题
class GlassMorphismScaffold extends StatelessWidget {
  final Widget? appBar;
  final Widget body;

  const GlassMorphismScaffold({Key? key, this.appBar, required this.body})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isGlassMorphism = themeController.isGlassMorphismTheme();

    return GlassMorphismBackground(
      child: Scaffold(
        backgroundColor: isGlassMorphism ? Colors.transparent : null,
        appBar: appBar != null
            ? (appBar is PreferredSizeWidget
                ? appBar as PreferredSizeWidget
                : null)
            : null,
        body: body,
      ),
    );
  }
}
