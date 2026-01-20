import 'package:flutter/foundation.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';
import 'package:vibe_music_app/src/utils/deviceInfoUtils/android_device_info.dart';
import 'package:vibe_music_app/src/utils/deviceInfoUtils/ios_device_info.dart';
import 'package:vibe_music_app/src/utils/deviceInfoUtils/web_device_info.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// 设备信息管理器
///
/// 统一管理不同平台的设备信息获取，支持Android、iOS、Web等平台
class DeviceInfoManager {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// 获取平台描述信息
  ///
  /// 返回当前运行平台的描述信息，包含平台类型和友好的emoji图标
  static String getPlatformDescription() {
    if (kIsWeb) return '🌐 网页浏览器';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return '🤖 Android设备';
      case TargetPlatform.iOS:
        return '🍎 iOS设备';
      case TargetPlatform.macOS:
        return '💻 Mac电脑';
      case TargetPlatform.windows:
        return '🖥️ Windows电脑';
      case TargetPlatform.linux:
        return '🐧 Linux系统';
      default:
        return '❓ 未知平台';
    }
  }

  /// 获取Android设备信息
  ///
  /// 返回CustomAndroidDeviceInfo实例，包含详细的设备信息
  static Future<CustomAndroidDeviceInfo?> getAndroidDeviceInfo() async {
    try {
      final androidInfo = await _deviceInfoPlugin.androidInfo;
      return CustomAndroidDeviceInfo(androidInfo: androidInfo);
    } catch (e, stackTrace) {
      AppLogger().d('Android设备信息获取失败: $e');
      AppLogger().d('Stack trace: $stackTrace');
      return null;
    }
  }

  /// 获取iOS设备信息
  ///
  /// 返回IOSDeviceInfo实例，包含详细的设备信息
  static Future<IOSDeviceInfo?> getIOSDeviceInfo() async {
    try {
      final iosInfo = await _deviceInfoPlugin.iosInfo;
      return IOSDeviceInfo(iosInfo: iosInfo);
    } catch (e, stackTrace) {
      AppLogger().d('iOS设备信息获取失败: $e');
      AppLogger().d('Stack trace: $stackTrace');
      return null;
    }
  }

  /// 获取当前平台的设备信息
  ///
  /// 根据当前运行平台自动获取相应的设备信息
  /// 返回Map格式的设备信息，如果获取失败返回null
  static Future<Map<String, String>?> getCurrentPlatformDeviceInfo() async {
    try {
      if (kIsWeb) {
        // Web平台提供详细的浏览器和设备信息
        final webBrowserInfo = await _deviceInfoPlugin.webBrowserInfo;
        final webInfo = WebDeviceInfo(webInfo: webBrowserInfo);
        return webInfo.getDeviceInfoMap();
      }

      AppLogger().d('正在获取平台设备信息，当前平台: $defaultTargetPlatform');

      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          AppLogger().d('开始获取Android设备信息...');
          final androidInfo = await getAndroidDeviceInfo();
          AppLogger()
              .d('Android设备信息获取结果: ${androidInfo != null ? "成功" : "失败"}');
          return androidInfo?.getDeviceInfoMap();
        case TargetPlatform.iOS:
          AppLogger().d('开始获取iOS设备信息...');
          final iosInfo = await getIOSDeviceInfo();
          AppLogger().d('iOS设备信息获取结果: ${iosInfo != null ? "成功" : "失败"}');
          return iosInfo?.getDeviceInfoMap();
        case TargetPlatform.macOS:
        case TargetPlatform.windows:
        case TargetPlatform.linux:
          // 桌面平台暂不提供详细设备信息
          return {'平台': getPlatformDescription(), '信息': '桌面平台详细设备信息暂未实现'};
        default:
          return {'平台': '未知平台', '信息': '不支持该平台的设备信息获取'};
      }
    } catch (e, stackTrace) {
      AppLogger().d('获取平台设备信息总体失败: $e');
      AppLogger().d('Stack trace: $stackTrace');
      return null;
    }
  }

  /// 获取格式化的当前设备信息字符串
  ///
  /// 返回易读的设备信息描述字符串
  static Future<String> getFormattedDeviceInfo() async {
    final info = await getCurrentPlatformDeviceInfo();
    if (info == null) {
      return '无法获取设备信息';
    }

    final platformDesc = getPlatformDescription();
    final infoString = info.entries
        .map((entry) => '  ${entry.key}: ${entry.value}')
        .join('\n');

    return '$platformDesc:\n$infoString';
  }
}
