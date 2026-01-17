import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:vibe_music_app/src/screens/search/search_screen.dart';
import 'package:vibe_music_app/src/screens/favorites/favorites_screen.dart';
import 'components/currently_playing_bar.dart';
import 'components/song_list_page.dart';
import 'components/profile_page.dart';

/// 主页屏幕
/// 包含底部导航栏和多个子页面
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// 当前选中的页面索引
  int _currentPage = 0;

  /// 底部导航栏对应的页面列表
  final List<Widget> _pages = [
    const SongListPage(), // 歌曲列表页面
    const SearchScreen(), // 搜索页面
    const FavoritesScreen(), // 收藏页面
    const ProfilePage(), // 个人中心页面
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 显示当前选中的页面
          _pages[_currentPage],
          // 正在播放音乐的小悬浮组件
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CurrentlyPlayingBar(),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: _currentPage,
            onDestinationSelected: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            destinations: [
              NavigationDestination(icon: Icon(Icons.music_note), label: '歌曲'),
              NavigationDestination(icon: Icon(Icons.search), label: '搜索'),
              NavigationDestination(icon: Icon(Icons.favorite), label: '收藏'),
              NavigationDestination(icon: Icon(Icons.person), label: '我的'),
            ],
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
