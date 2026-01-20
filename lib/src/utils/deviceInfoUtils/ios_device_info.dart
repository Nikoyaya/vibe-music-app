import 'package:device_info_plus/device_info_plus.dart';

/// iOS设备信息工具类
///
/// 用于获取iOS平台的设备详细信息
class IOSDeviceInfo {
  final IosDeviceInfo? _iosInfo;


  IOSDeviceInfo({required IosDeviceInfo? iosInfo})
      : _iosInfo = iosInfo;

  /// 获取设备名称
  String get deviceName => _iosInfo?.name ?? '未知';

  /// 获取系统名称
  String get systemName => _iosInfo?.systemName ?? '未知';

  /// 获取系统版本号
  String get systemVersion => _iosInfo?.systemVersion ?? '未知';

  /// 获取设备型号
  String get model => _iosInfo?.model ?? '未知';

  /// 获取本地化设备型号
  String get localizedModel => _iosInfo?.localizedModel ?? '未知';

  /// 获取设备标识符（供应商标识符）
  String get identifier => _iosInfo?.identifierForVendor ?? '未知';

  /// 获取完整的设备信息Map
  Map<String, String> getDeviceInfoMap() {
    return {
      '设备名称': deviceName,
      '系统名称': systemName,
      '系统版本': systemVersion,
      '设备型号': model,
      '本地设备型号': localizedModel,
      '标识符': identifier,
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