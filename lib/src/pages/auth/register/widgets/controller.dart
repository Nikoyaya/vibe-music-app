import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:vibe_music_app/src/providers/auth_provider.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';

class RegisterController extends GetxController {
  // 表单状态
  final GlobalKey<FormState> formKey;

  // 控制器
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final verificationCodeController = TextEditingController();

  // 状态
  var isLoading = false.obs;
  var isSendingCode = false.obs;
  var verificationSent = false.obs;
  var countdown = 0.obs;
  late Timer _countdownTimer;

  // 认证提供者
  late AuthProvider _authProvider;

  // 构造函数
  RegisterController()
      : formKey = GlobalKey<FormState>(
            debugLabel:
                'RegisterForm_${DateTime.now().millisecondsSinceEpoch}') {
    _authProvider = Get.find<AuthProvider>();
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    verificationCodeController.dispose();
    if (_countdownTimer.isActive) {
      _countdownTimer.cancel();
    }
    super.onClose();
  }

  /// 发送验证码
  Future<void> sendVerificationCode() async {
    if (emailController.text.isEmpty || !emailController.text.contains('@')) {
      Get.snackbar('Error', 'Please enter a valid email');
      return;
    }

    if (countdown.value > 0) {
      return;
    }

    isSendingCode.value = true;

    try {
      final success =
          await _authProvider.sendVerificationCode(emailController.text);

      if (success) {
        verificationSent.value = true;
        Get.snackbar('Success', 'Verification code sent!');
      } else {
        Get.snackbar('Error', 'Failed to send verification code');
      }
    } catch (e, stackTrace) {
      AppLogger().e('Send verification code error: $e', stackTrace: stackTrace);
      Get.snackbar('Error', 'An unexpected error occurred');
    } finally {
      isSendingCode.value = false;
      startCountdown();
    }
  }

  /// 开始倒计时
  void startCountdown() {
    countdown.value = 60;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        _countdownTimer.cancel();
      }
    });
  }

  /// 处理注册
  Future<void> handleRegister() async {
    if (formKey.currentState?.validate() ?? false) {
      if (passwordController.text != confirmPasswordController.text) {
        Get.snackbar('Error', 'Passwords do not match');
        return;
      }

      if (!verificationSent.value || verificationCodeController.text.isEmpty) {
        Get.snackbar('Error', 'Please verify your email first');
        return;
      }

      isLoading.value = true;

      try {
        final success = await _authProvider.register(
          emailController.text,
          usernameController.text,
          passwordController.text,
          verificationCodeController.text,
        );

        if (success) {
          Get.snackbar('Success', 'Registration successful! Please login.');
          Get.offAllNamed('/login');
        } else if (_authProvider.errorMessage != null) {
          Get.snackbar('Error', _authProvider.errorMessage!);
        }
      } catch (e, stackTrace) {
        AppLogger().e('Register error: $e', stackTrace: stackTrace);
        Get.snackbar('Error', 'An unexpected error occurred');
      } finally {
        isLoading.value = false;
      }
    }
  }

  /// 返回上一页或导航到登录页
  void goBack() {
    if (Navigator.canPop(Get.context!)) {
      Get.back();
    } else {
      Get.offAllNamed('/login');
    }
  }

  /// 导航到登录页面
  void navigateToLogin() {
    Get.offAllNamed('/login');
  }
}
