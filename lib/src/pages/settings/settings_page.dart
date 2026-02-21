import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/generated/app_localizations.dart';
import 'package:vibe_music_app/src/components/glass_morphism_background.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return GlassMorphismBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(localizations.settings),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Get.back();
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.color_lens),
              title: Text(localizations.theme),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Get.toNamed('/settings/theme');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.language),
              title: Text(localizations.language),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Get.toNamed('/settings/language');
              },
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
