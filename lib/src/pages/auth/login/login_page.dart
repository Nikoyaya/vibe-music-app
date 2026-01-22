import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/src/pages/auth/login/widgets/controller.dart';
import 'package:vibe_music_app/src/pages/auth/login/widgets/view.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用Get.create确保每次都获得新的控制器实例
    Get.create<LoginController>(() => LoginController());
    return LoginView();
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.create<LoginController>(() => LoginController());
  }
}
