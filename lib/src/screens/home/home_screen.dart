import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:vibe_music_app/src/screens/search/search_screen.dart';
import 'package:vibe_music_app/src/screens/favorites/favorites_screen.dart';
import 'components/currently_playing_bar.dart';
import 'components/song_list_page.dart';
import 'components/profile_page.dart';

import 'package:vibe_music_app/src/utils/glass_morphism/responsive_layout.dart';
import 'package:vibe_music_app/src/utils/glass_morphism/sidebar_navigation.dart';

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
    return ResponsiveLayout(
      mobileLayout: _buildMobileLayout(),
      tabletLayout: _buildTabletLayout(),
      desktopLayout: _buildDesktopLayout(),
    );
  }

  /// 构建移动端布局
  Widget _buildMobileLayout() {
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

  /// 构建平板端布局
  Widget _buildTabletLayout() {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Row(
        children: [
          // 侧边栏导航
          Container(
            width: 200,
            child: SidebarNavigation(
              currentIndex: _currentPage,
              onDestinationSelected: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
            ),
          ),
          // 主内容区域
          Expanded(
            child: Stack(
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
          ),
        ],
      ),
    );
  }

  /// 构建桌面端布局
  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Row(
        children: [
          // 侧边栏导航
          Container(
            width: 240,
            child: SidebarNavigation(
              currentIndex: _currentPage,
              onDestinationSelected: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
            ),
          ),
          // 主内容区域
          Expanded(
            child: Stack(
              children: [
                // 顶部导航栏
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: TopNavigationBar(
                    title: _getPageTitle(_currentPage),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.settings, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                // 显示当前选中的页面
                Padding(
                  padding: const EdgeInsets.only(top: 70),
                  child: _pages[_currentPage],
                ),
                // 正在播放音乐的小悬浮组件
                const Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: CurrentlyPlayingBar(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 获取页面标题
  /// [index] - 页面索引
  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return '音乐库';
      case 1:
        return '搜索';
      case 2:
        return '我的收藏';
      case 3:
        return '个人中心';
      default:
        return 'Glass Music Player';
    }
  }
}
