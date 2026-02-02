import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vibe_music_app/generated/app_localizations.dart';
import 'package:vibe_music_app/src/providers/auth_provider.dart';
import 'package:vibe_music_app/src/routes/app_routes.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';

class LoginController extends GetxController {
  // 表单状态
  final GlobalKey<FormState> formKey;

  // 控制器
  final usernameOrEmailController = TextEditingController();
  final passwordController = TextEditingController();

  // 状态
  var isLoading = false.obs;

  // 认证提供者
  late AuthProvider _authProvider;

  // 构造函数
  LoginController()
      : formKey = GlobalKey<FormState>(
            debugLabel: 'LoginForm_${DateTime.now().millisecondsSinceEpoch}') {
    _authProvider = Get.find<AuthProvider>();
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    usernameOrEmailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// 处理登录
  Future<void> handleLogin() async {
    if (formKey.currentState?.validate() ?? false) {
      isLoading.value = true;

      try {
        final success = await _authProvider.login(
          usernameOrEmailController.text,
          passwordController.text,
        );

        final localizations = AppLocalizations.of(Get.context!);
        if (success) {
          // 登录成功，跳转到首页
          Get.offAllNamed(AppRoutes.home);
        } else if (_authProvider.errorMessage != null) {
          // 登录失败，显示错误信息
          Get.snackbar(
              localizations?.error ?? 'Error', _authProvider.errorMessage!);
        }
      } catch (e, stackTrace) {
        AppLogger().e('登录错误: $e', stackTrace: stackTrace);
        final localizations = AppLocalizations.of(Get.context!);
        Get.snackbar(localizations?.error ?? 'Error',
            localizations?.error ?? 'An unexpected error occurred');
      } finally {
        isLoading.value = false;
      }
    }
  }

  /// 导航到注册页面
  void navigateToRegister() {
    Get.toNamed(AppRoutes.register);
  }

  /// 返回上一页或导航到首页
  void goBack() {
    if (Navigator.canPop(Get.context!)) {
      Get.back();
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }
}
