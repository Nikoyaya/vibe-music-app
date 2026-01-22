import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/src/pages/player/widgets/controller.dart';
import 'package:vibe_music_app/src/pages/player/widgets/view.dart';

class PlayerPage extends StatelessWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlayerController>(
      init: Get.find<PlayerController>(),
      builder: (controller) {
        return const PlayerView();
      },
    );
  }
}
