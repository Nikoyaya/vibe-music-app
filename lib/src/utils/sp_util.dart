import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';

/// SharedPreferences 工具类
///
/// 提供基于键值对的本地数据持久化存储功能
/// 支持存储基本数据类型（String, int, bool, double）和复杂对象（通过JSON序列化）
/// 使用单例模式确保全局唯一实例
class SpUtil {
  /// 单例实例
  static SpUtil? _instance;

  /// SharedPreferences 实例
  static late SharedPreferences _prefs;

  /// 私有构造函数
  SpUtil._();

  /// 初始化 SharedPreferences 工具类
  ///
  /// 必须在应用程序启动时（main函数中）调用并await等待初始化完成
  /// 该方法确保单例模式的正确初始化
  ///
  /// @return Future<SpUtil> 返回单例实例
  static Future<SpUtil> init() async {
    if (_instance == null) {
      _instance = SpUtil._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  /// 存储数据到本地存储
  ///
  /// 支持存储多种数据类型：String, int, bool, double, List<String>
  /// 对于 Map/List/自定义对象等复杂类型，会自动进行JSON序列化存储
  ///
  /// @param key 存储的键名
  /// @param value 要存储的值
  /// @return Future<bool> 存储是否成功
  static Future<bool> put<T>(String key, Object value) {
    // 根据数据类型选择对应的存储方法
    if (value is String) return _prefs.setString(key, value);
    if (value is int) return _prefs.setInt(key, value);
    if (value is bool) return _prefs.setBool(key, value);
    if (value is double) return _prefs.setDouble(key, value);
    if (value is List<String>) return _prefs.setStringList(key, value);

    // Map/List/自定义对象统一使用JSON序列化存储
    return _prefs.setString(key, jsonEncode(value));
  }

  /// 从本地存储获取数据
  ///
  /// 获取指定键名对应的值，支持泛型自动类型转换
  /// 对于JSON格式的字符串会自动反序列化为对应类型
  ///
  /// @param key 要获取的键名
  /// @param defaultValue 默认值，当键不存在时返回此值
  /// @return T? 获取到的值，如果不存在则返回默认值
  static T? get<T>(String key, {T? defaultValue}) {
    final value = _prefs.get(key); // 获取原始值
    if (value == null) return defaultValue; // 值为空时返回默认值

    // 处理JSON格式的复杂对象
    if (T != dynamic && value is String && _isJson(value)) {
      try {
        return jsonDecode(value) as T; // JSON反序列化
      } catch (e) {
        AppLogger().e('SpUtil 反序列化失败: $e'); // 记录反序列化错误日志
      }
    }
    return value as T; // 返回转换后的值
  }

  /// 判断字符串是否为JSON格式
  ///
  /// 检查字符串是否以 '{' 开头 '}' 结尾（对象格式）
  /// 或以 '[' 开头 ']' 结尾（数组格式）
  ///
  /// @param str 要检查的字符串
  /// @return bool 是否为JSON格式
  static bool _isJson(String str) {
    return (str.startsWith('{') && str.endsWith('}')) || // JSON对象格式
        (str.startsWith('[') && str.endsWith(']')); // JSON数组格式
  }

  /// 删除指定键名的数据
  ///
  /// @param key 要删除的键名
  /// @return Future<bool> 删除是否成功
  static Future<bool> remove(String key) => _prefs.remove(key);

  /// 清空所有存储的数据
  ///
  /// 注意：此操作会删除应用所有的本地存储数据，请谨慎使用
  ///
  /// @return Future<bool> 清空是否成功
  static Future<bool> clear() => _prefs.clear();
}
