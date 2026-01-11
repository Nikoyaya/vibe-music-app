import 'package:flutter/material.dart';
import 'package:vibe_music_app/src/screens/home/home_screen.dart';
import 'package:vibe_music_app/src/screens/player/player_screen.dart';
import 'package:vibe_music_app/src/screens/search/search_screen.dart';
import 'package:vibe_music_app/src/screens/auth/login_screen.dart';
import 'package:vibe_music_app/src/screens/auth/register_screen.dart';
import 'package:vibe_music_app/src/screens/admin/admin_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String player = '/player';
  static const String search = '/search';
  static const String login = '/login';
  static const String register = '/register';
  static const String admin = '/admin';

  static final Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    player: (context) => const PlayerScreen(),
    search: (context) => const SearchScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    admin: (context) => const AdminScreen(),
  };
}