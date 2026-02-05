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
      print('请求通知权限');

      // 检查权限状态
      final status = await Permission.notification.status;
      print('通知权限当前状态: $status');

      if (status.isDenied) {
        // 请求权限
        print('通知权限被拒绝，开始请求');
        final result = await Permission.notification.request();
        print('通知权限请求结果: $result');
        return result.isGranted;
      } else if (status.isGranted) {
        print('通知权限已授予');
        return true;
      } else {
        print('通知权限状态: $status');
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ 请求通知权限失败: $e');
      print('❌ 堆栈跟踪: $stackTrace');
      return false;
    }
  }

  /// 请求所有必要的权限
  Future<void> requestAllPermissions() async {
    try {
      print('请求所有必要的权限');

      // 请求通知权限
      await requestNotificationPermission();

      print('权限请求完成');
    } catch (e, stackTrace) {
      print('❌ 请求权限失败: $e');
      print('❌ 堆栈跟踪: $stackTrace');
    }
  }
}
