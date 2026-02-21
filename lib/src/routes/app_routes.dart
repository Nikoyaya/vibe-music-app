import 'package:get/get.dart';
import 'package:vibe_music_app/src/pages/home/home_page.dart';
import 'package:vibe_music_app/src/pages/player/player_page.dart';
import 'package:vibe_music_app/src/pages/search/search_page.dart';
import 'package:vibe_music_app/src/pages/auth/login/login_page.dart';
import 'package:vibe_music_app/src/pages/auth/register/register_page.dart';
import 'package:vibe_music_app/src/pages/favorites/favorites_page.dart';
import 'package:vibe_music_app/src/pages/settings/settings_page.dart';
import 'package:vibe_music_app/src/pages/settings/language_page.dart';
import 'package:vibe_music_app/src/pages/settings/theme_page.dart';

/// 应用路由管理类
/// 使用GetX的命名路由系统
class AppRoutes {
  /// 首页路由
  static const String home = '/';

  /// 播放器路由
  static const String player = '/player';

  /// 搜索页路由
  static const String search = '/search';

  /// 登录页路由
  static const String login = '/login';

  /// 注册页路由
  static const String register = '/register';

  /// 收藏页路由
  static const String favorites = '/favorites';

  /// 设置页路由
  static const String settings = '/settings';

  /// 语言选择页路由
  static const String language = '/settings/language';

  /// 主题选择页路由
  static const String theme = '/settings/theme';

  /// 路由映射表
  static final List<GetPage> routes = [
    GetPage(
      name: home,
      page: () => const HomePage(),
      transition: Transition.fade,
    ),
    // GetPage(
    //   name: player,
    //   page: () => const PlayerPage(),
    //   transition: Transition.fade,
    // ),
    GetPage(
      name: search,
      page: () => const SearchPage(),
      transition: Transition.fade,
    ),
    GetPage(
      name: login,
      page: () => const LoginPage(),
      transition: Transition.fade,
    ),
    GetPage(
      name: register,
      page: () => const RegisterPage(),
      transition: Transition.fade,
    ),
    // GetPage(
    //   name: favorites,
    //   page: () => const FavoritesPage(),
    //   transition: Transition.fade,
    // ),
    GetPage(
      name: settings,
      page: () => const SettingsPage(),
      transition: Transition.fade,
    ),
    GetPage(
      name: language,
      page: () => const LanguagePage(),
      transition: Transition.fade,
    ),
    GetPage(
      name: theme,
      page: () => const ThemePage(),
      transition: Transition.fade,
    ),
  ];
}
