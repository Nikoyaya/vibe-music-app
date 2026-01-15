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
      body: _pages[_currentPage], // 显示当前选中的页面
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 正在播放音乐的小悬浮组件
          const CurrentlyPlayingBar(),
          // 底部导航栏
          SafeArea(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  color: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.8),
                  child: NavigationBar(
                    selectedIndex: _currentPage,
                    onDestinationSelected: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    destinations: [
                      NavigationDestination(
                          icon: Icon(Icons.music_note), label: 'Songs'),
                      NavigationDestination(
                          icon: Icon(Icons.search), label: 'Search'),
                      NavigationDestination(
                          icon: Icon(Icons.favorite), label: 'Favorites'),
                      NavigationDestination(
                          icon: Icon(Icons.person), label: 'Profile'),
                    ],
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
