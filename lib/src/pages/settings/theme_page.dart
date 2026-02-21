import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/generated/app_localizations.dart';
import 'package:vibe_music_app/src/components/glass_morphism_background.dart';
import 'package:vibe_music_app/src/controllers/theme_controller.dart';

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final localizations = AppLocalizations.of(context)!;

    return GlassMorphismBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(localizations.theme),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Get.back();
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                localizations.theme,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Obx(() => Column(
                    children: [
                      // 暂时注释掉浅色模式
                      // RadioListTile<ThemeType>(
                      //   value: ThemeType.light,
                      //   groupValue: themeController.themeType.value,
                      //   onChanged: (value) {
                      //     if (value != null) {
                      //       themeController.changeTheme(value);
                      //     }
                      //   },
                      //   title: Text(localizations.lightMode),
                      //   activeColor: Colors.blue,
                      // ),
                      // Divider(),
                      RadioListTile<ThemeType>(
                        value: ThemeType.dark,
                        groupValue: themeController.themeType.value,
                        onChanged: (value) {
                          if (value != null) {
                            themeController.changeTheme(value);
                          }
                        },
                        title: Text(localizations.darkMode),
                        activeColor: Colors.blue,
                      ),
                      Divider(),
                      RadioListTile<ThemeType>(
                        value: ThemeType.glassMorphism,
                        groupValue: themeController.themeType.value,
                        onChanged: (value) {
                          if (value != null) {
                            themeController.changeTheme(value);
                          }
                        },
                        title: Text(localizations.glassMorphismMode),
                        activeColor: Colors.blue,
                      ),
                    ],
                  )),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.themePreview,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
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
                        child: Center(
                          child: Text(
                            localizations.glassMorphismPreview,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
