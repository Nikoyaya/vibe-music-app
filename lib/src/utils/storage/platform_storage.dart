import 'package:vibe_music_app/src/utils/app_logger.dart';
import 'package:vibe_music_app/src/utils/sp_util.dart';

/// 平台存储适配器
/// 为不同平台提供统一的存储接口
class PlatformStorage {
  /// 单例实例
  static final PlatformStorage _instance = PlatformStorage._internal();

  /// 工厂构造函数
  factory PlatformStorage() => _instance;

  /// 私有构造函数
  PlatformStorage._internal();

  /// 初始化存储
  Future<void> init() async {
    try {
      await SpUtil.init();
      AppLogger().d('存储初始化成功');
    } catch (e) {
      AppLogger().e('存储初始化失败: $e');
    }
  }

  /// 存储数据
  Future<bool> set(String key, dynamic value) async {
    try {
      return await SpUtil.put(key, value);
    } catch (e) {
      AppLogger().e('存储数据失败: $e');
      return false;
    }
  }

  /// 获取数据
  Future<dynamic> get(String key) async {
    try {
      return SpUtil.get(key);
    } catch (e) {
      AppLogger().e('获取数据失败: $e');
      return null;
    }
  }

  /// 获取字符串数据
  Future<String?> getString(String key) async {
    try {
      return SpUtil.get(key) as String?;
    } catch (e) {
      AppLogger().e('获取字符串数据失败: $e');
      return null;
    }
  }

  /// 获取复杂对象
  Future<T?> getObject<T>(String key) async {
    try {
      return SpUtil.get(key) as T?;
    } catch (e) {
      AppLogger().e('获取对象失败: $e');
      return null;
    }
  }

  /// 删除数据
  Future<bool> remove(String key) async {
    try {
      return await SpUtil.remove(key);
    } catch (e) {
      AppLogger().e('删除数据失败: $e');
      return false;
    }
  }

  /// 清除所有数据
  Future<bool> clear() async {
    try {
      return await SpUtil.clear();
    } catch (e) {
      AppLogger().e('清除所有数据失败: $e');
      return false;
    }
  }

  /// 检查键是否存在
  Future<bool> containsKey(String key) async {
    try {
      return SpUtil.get(key) != null;
    } catch (e) {
      AppLogger().e('检查键是否存在失败: $e');
      return false;
    }
  }
}
