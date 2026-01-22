import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/src/pages/auth/register/widgets/controller.dart';
import 'package:vibe_music_app/src/pages/auth/register/widgets/view.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用Get.create确保每次都获得新的控制器实例
    Get.create<RegisterController>(() => RegisterController());
    return RegisterView();
  }
}

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.create<RegisterController>(() => RegisterController());
  }
}
