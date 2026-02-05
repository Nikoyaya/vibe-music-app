import 'package:get/get.dart';
import 'package:vibe_music_app/src/controllers/auth_controller.dart';
import 'package:vibe_music_app/src/controllers/music_controller.dart';
import 'package:vibe_music_app/src/pages/home/widgets/controller.dart';
import 'package:vibe_music_app/src/pages/favorites/widgets/controller.dart';
import 'package:vibe_music_app/src/pages/search/widgets/controller.dart';
import 'package:vibe_music_app/src/pages/player/widgets/controller.dart';

/// 依赖注入管理类
/// 用于集中管理所有GetX依赖注入
class DependencyInjection {
  /// 初始化所有依赖注入
  static void init() {
    // 核心状态管理依赖（永久存在）
    Get.put(AuthController(), permanent: true);
    Get.put(MusicController(), permanent: true);

    // 页面控制器（延迟初始化）
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.lazyPut(() => PlayerController(), fenix: true);
    Get.lazyPut(() => FavoritesController(), fenix: true);
    Get.lazyPut(() => SearchPageController(), fenix: true);
    // 认证页面控制器不在这里注册，而是在页面中使用Get.create

    // 可以在这里添加更多的依赖注入
    // 例如：
    // Get.lazyPut(() => ApiService(), fenix: true);
    // Get.lazyPut(() => UserRepository(), fenix: true);
  }

  /// 延迟初始化非核心服务
  static void lazyInitializeNonCoreServices() {
    // 这里可以添加非核心服务的延迟初始化
    // 例如：
    // Get.lazyPut(() => AnalyticsService(), fenix: true);
    // Get.lazyPut(() => NotificationService(), fenix: true);
  }
}
