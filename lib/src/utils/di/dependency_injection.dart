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
    // 状态管理依赖
    Get.put(AuthController(), permanent: true);
    Get.put(MusicController(), permanent: true);

    // 页面控制器
    Get.put(HomeController(), permanent: true);
    Get.put(FavoritesController(), permanent: true);
    Get.put(SearchPageController(), permanent: true);
    Get.put(PlayerController(), permanent: true);
    // 认证页面控制器不在这里注册，而是在页面中使用Get.create

    // 可以在这里添加更多的依赖注入
    // 例如：
    // Get.put(ApiService());
    // Get.put(UserRepository());
  }
}
