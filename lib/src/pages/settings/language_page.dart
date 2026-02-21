import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/generated/app_localizations.dart';
import 'package:vibe_music_app/src/components/glass_morphism_background.dart';
import 'package:vibe_music_app/src/controllers/language_controller.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    final localizations = AppLocalizations.of(context)!;

    return GlassMorphismBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(localizations.language),
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
                localizations.language,
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
                    children: languageController.languageOptions.map((option) {
                      String displayName;
                      switch (option.code) {
                        case 'system':
                          displayName = localizations.systemLanguage;
                          break;
                        case 'en':
                          displayName = localizations.english;
                          break;
                        case 'zh':
                          displayName = localizations.chinese;
                          break;
                        case 'zh_TW':
                          displayName = localizations.traditionalChinese;
                          break;
                        default:
                          displayName = option.code;
                      }

                      return RadioListTile<String>(
                        value: option.code,
                        groupValue: languageController.languageCode.value,
                        onChanged: (value) {
                          if (value != null) {
                            languageController.changeLanguage(value);
                          }
                        },
                        title: Text(displayName),
                        activeColor: Colors.blue,
                      );
                    }).toList(),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
