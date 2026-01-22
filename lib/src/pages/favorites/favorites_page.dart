import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/src/pages/favorites/widgets/controller.dart';
import 'package:vibe_music_app/src/pages/favorites/widgets/view.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FavoritesController>(
      init: Get.find<FavoritesController>(),
      builder: (controller) {
        return const FavoritesView();
      },
    );
  }
}
