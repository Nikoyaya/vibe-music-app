import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/generated/app_localizations.dart';
import 'package:vibe_music_app/src/providers/auth_provider.dart';
import 'package:vibe_music_app/src/routes/app_routes.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';

/// 全局通知服务
/// 提供全局的提示和对话框功能
class GlobalNotificationService {
  /// 单例实例
  static final GlobalNotificationService _instance =
      GlobalNotificationService._internal();

  /// 获取单例实例
  factory GlobalNotificationService() => _instance;

  /// 私有构造函数
  GlobalNotificationService._internal();

  /// 对话框显示状态标志
  bool _isLoginExpiredDialogShowing = false;

  /// 显示登录过期提示对话框
  /// [context]: 上下文
  Future<void> showLoginExpiredDialog(BuildContext context) async {
    // 防止重复显示对话框
    if (_isLoginExpiredDialogShowing) {
      AppLogger().w('登录过期提示对话框已经在显示中，跳过重复显示');
      return;
    }

    final localizations = AppLocalizations.of(context);

    try {
      _isLoginExpiredDialogShowing = true;
      AppLogger().d('开始显示登录过期提示对话框');

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(localizations?.error ?? 'Error'),
            content: Text(localizations?.loginExpired ??
                'Login expired, please log in again'),
            actions: [
              // 确认按钮 - 仅关闭对话框
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(localizations?.ok ?? 'OK'),
              ),
              // 去登录按钮 - 跳转到登录页面
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _handleGoToLogin();
                },
                child: Text(localizations?.goToLogin ?? 'Go to login'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      AppLogger().e('显示登录过期提示对话框失败: $e');
    } finally {
      _isLoginExpiredDialogShowing = false;
      AppLogger().d('登录过期提示对话框显示完成');
    }
  }

  /// 处理去登录操作
  void _handleGoToLogin() {
    try {
      // 清除认证信息
      if (Get.isRegistered<AuthProvider>()) {
        final authProvider = Get.find<AuthProvider>();
        // 调用登出方法清除本地存储
        authProvider.logout();
      }

      // 跳转到登录页面
      Get.offAllNamed(AppRoutes.login);

      AppLogger().d('用户点击了去登录按钮，已跳转到登录页面');
    } catch (e) {
      AppLogger().e('处理去登录操作失败: $e');
      // 即使出错也要跳转到登录页面
      Get.offAllNamed(AppRoutes.login);
    }
  }

  /// 显示通用错误对话框
  /// [context]: 上下文
  /// [message]: 错误消息
  Future<void> showErrorDialog(BuildContext context, String message) async {
    final localizations = AppLocalizations.of(context);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations?.error ?? 'Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(localizations?.ok ?? 'OK'),
            ),
          ],
        );
      },
    );
  }
}
