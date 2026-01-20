import 'package:device_info_plus/device_info_plus.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';

/// Web设备信息工具类
///
/// 用于获取Web平台的浏览器和设备详细信息
class WebDeviceInfo {
  final WebBrowserInfo? _webBrowserInfo;

  WebDeviceInfo({WebBrowserInfo? webInfo}) : _webBrowserInfo = webInfo;

  /// 获取浏览器名称
  String get browserName {
    if (_webBrowserInfo == null) {
      return '未知浏览器';
    }
    final browserName = _webBrowserInfo?.browserName.name;
    final ua = browserName ?? 'Unknown Browser';
    AppLogger().d('ua: $ua');
    if (ua.contains('chrome') && !ua.contains('edg')) return 'Chrome';
    if (ua.contains('firefox')) return 'Firefox';
    if (ua.contains('safari') && !ua.contains('chrome')) return 'Safari';
    if (ua.contains('edg')) return 'Edge';
    if (ua.contains('opera') || ua.contains('opr')) return 'Opera';
    if (ua.contains('trident') || ua.contains('msie'))
      return 'Internet Explorer';
    return '未知浏览器';
  }

  /// 获取用户代理字符串
  String get userAgent => _webBrowserInfo?.userAgent ?? '未知';

  /// 获取应用版本
  String get appVersion => _webBrowserInfo?.appVersion ?? '未知';

  /// 获取应用代码名称
  String get appCodeName => _webBrowserInfo?.appCodeName ?? '未知';

  /// 获取平台信息
  String get platform => _webBrowserInfo?.platform ?? '未知';

  /// 获取浏览器供应商信息
  String get vendor => _webBrowserInfo?.vendor ?? '未知';

  /// 获取浏览器语言设置
  String get language => _webBrowserInfo?.language ?? '未知';

  /// 获取完整的设备信息Map
  Map<String, String> getDeviceInfoMap() {
    return {
      '浏览器名称': browserName,
      '用户代理': userAgent,
      '应用版本': appVersion,
      '应用代码': appCodeName,
      '平台': platform,
      '供应商': vendor,
      '语言': language,
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
