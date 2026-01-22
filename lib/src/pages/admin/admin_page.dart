import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/src/pages/admin/widgets/controller.dart';
import 'package:vibe_music_app/src/pages/admin/widgets/view.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdminController>(
      init: Get.find<AdminController>(),
      builder: (controller) {
        return const AdminView();
      },
    );
  }
}
