/// 设备信息工具类库
///
/// 提供跨平台的设备信息获取功能，支持Android、iOS、Web等平台
///
/// 使用示例：
/// ```dart
/// // 获取平台描述
/// String platform = DeviceInfoManager.getPlatformDescription();
///
/// // 获取详细设备信息
/// Map<String, String>? deviceInfo = await DeviceInfoManager.getCurrentPlatformDeviceInfo();
///
/// // 获取格式化信息
/// String formattedInfo = await DeviceInfoManager.getFormattedDeviceInfo();
/// ```
library device_info_utils;

export 'android_device_info.dart';
export 'ios_device_info.dart';
export 'web_device_info.dart';
export 'device_info_manager.dart';