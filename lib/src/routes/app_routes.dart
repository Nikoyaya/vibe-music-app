import 'package:flutter/material.dart';
import 'package:vibe_music_app/src/screens/home/home_screen.dart';
import 'package:vibe_music_app/src/screens/player/player_screen.dart';
import 'package:vibe_music_app/src/screens/search/search_screen.dart';
import 'package:vibe_music_app/src/screens/auth/login_screen.dart';
import 'package:vibe_music_app/src/screens/auth/register_screen.dart';
import 'package:vibe_music_app/src/screens/admin/admin_screen.dart';

/// 应用路由管理类
/// 统一管理应用中所有的路由配置
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

  /// 管理员页路由
  static const String admin = '/admin';

  /// 路由映射表
  /// 将路由名称与对应的页面组件关联起来
  static final Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    player: (context) => const PlayerScreen(),
    search: (context) => const SearchScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    admin: (context) => const AdminScreen(),
  };
}
