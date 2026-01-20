import 'package:device_info_plus/device_info_plus.dart';

/// Android设备信息工具类
///
/// 用于获取Android平台的设备详细信息
class CustomAndroidDeviceInfo {
  final AndroidDeviceInfo? _androidInfo;

  CustomAndroidDeviceInfo({required AndroidDeviceInfo? androidInfo})
      : _androidInfo = androidInfo;

  /// 获取设备型号
  String get model => _androidInfo?.model ?? '未知';

  /// 获取设备品牌
  String get brand => _androidInfo?.brand ?? '未知';

  /// 获取设备内部代号
  String get device => _androidInfo?.device ?? '未知';

  /// 获取Android版本号
  String get androidVersion => _androidInfo?.version.release ?? '未知';

  /// 获取设备ID
  String get deviceId => _androidInfo?.id ?? '未知';

  /// 获取SDK版本号
  String get sdkVersion => _androidInfo?.version.sdkInt?.toString() ?? '未知';

  /// 判断是否为物理设备
  String get isPhysicalDevice =>
      _androidInfo?.isPhysicalDevice?.toString() ?? '未知';

  /// 获取完整的设备信息Map
  Map<String, String> getDeviceInfoMap() {
    return {
      '设备型号': model,
      '品牌': brand,
      '设备': device,
      'Android 版本': androidVersion,
      '设备ID': deviceId,
      'SDK 版本': sdkVersion,
      '是否物理设备': isPhysicalDevice,
    };
  }

  /// 获取格式化的设备信息字符串
  String getFormattedInfo() {
    final info = getDeviceInfoMap();
    return info.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');
  }
}
