import 'package:permission_handler/permission_handler.dart';

/// 权限服务
/// 负责处理应用所需的各种权限请求
class PermissionService {
  /// 单例实例
  static final PermissionService _instance = PermissionService._internal();

  /// 获取单例实例
  factory PermissionService() => _instance;

  /// 私有构造函数
  PermissionService._internal();

  /// 请求通知权限
  Future<bool> requestNotificationPermission() async {
    try {
      // 检查权限状态
      final status = await Permission.notification.status;

      if (status.isDenied) {
        // 请求权限
        final result = await Permission.notification.request();
        return result.isGranted;
      } else if (status.isGranted) {
        return true;
      } else {
        return false;
      }
    } catch (e, stackTrace) {
      return false;
    }
  }

  /// 请求所有必要的权限
  Future<void> requestAllPermissions() async {
    try {
      // 请求通知权限
      await requestNotificationPermission();
    } catch (e, stackTrace) {}
  }
}
