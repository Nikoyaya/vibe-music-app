import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/generated/app_localizations.dart';
import 'package:vibe_music_app/src/pages/home/widgets/controller.dart';
import 'package:vibe_music_app/src/routes/app_routes.dart';
import 'package:vibe_music_app/src/utils/glass_morphism/responsive_layout.dart';
import 'package:vibe_music_app/src/utils/glass_morphism/sidebar_navigation.dart';
import 'package:vibe_music_app/src/pages/home/components/song_list_page.dart';
import 'package:vibe_music_app/src/pages/home/components/profile_page.dart';
import 'package:vibe_music_app/src/pages/home/components/currently_playing_bar.dart';
import 'package:vibe_music_app/src/pages/player/player_page.dart';
import 'package:vibe_music_app/src/pages/favorites/favorites_page.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileLayout: _buildMobileLayout(context),
      tabletLayout: _buildTabletLayout(context),
      desktopLayout: _buildDesktopLayout(context),
    );
  }

  /// 构建移动端布局
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 显示当前选中的页面
          Obx(() => _getCurrentPage()),
          // 正在播放音乐的小悬浮组件（在播放页时隐藏）
          Obx(() => controller.currentPage.value != 1
              ? const Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: CurrentlyPlayingBar(),
                )
              : const SizedBox.shrink()),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Obx(() => Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
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
                selectedIndex: controller.currentPage.value,
                onDestinationSelected: controller.changePage,
                destinations: [
                  NavigationDestination(
                      icon: Icon(Icons.music_note),
                      label: AppLocalizations.of(context)?.songs ?? '歌曲'),
                  NavigationDestination(
                      icon: Icon(Icons.play_circle),
                      label: AppLocalizations.of(context)?.player ?? '播放'),
                  NavigationDestination(
                      icon: Icon(Icons.favorite),
                      label: AppLocalizations.of(context)?.favorites ?? '收藏'),
                  NavigationDestination(
                      icon: Icon(Icons.person),
                      label: AppLocalizations.of(context)?.my ?? '我的'),
                ],
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
            )),
      ),
    );
  }

  /// 构建平板端布局
  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Row(
        children: [
          // 侧边栏导航
          Container(
            width: 200,
            child: Obx(() => SidebarNavigation(
                  currentIndex: _getSidebarIndex(controller.currentPage.value),
                  onDestinationSelected: (index) =>
                      controller.changePage(_getMainPageIndex(index)),
                )),
          ),
          // 主内容区域
          Expanded(
            child: Stack(
              children: [
                // 显示当前选中的页面
                Obx(() => _getCurrentPage()),
                // 正在播放音乐的小悬浮组件（在播放页时隐藏）
                Obx(() => controller.currentPage.value != 1
                    ? const Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: CurrentlyPlayingBar(),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建桌面端布局
  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Row(
        children: [
          // 自适应侧边栏宽度
          AdaptiveSidebarWidth(
            child: Obx(() => SidebarNavigation(
                  currentIndex: _getSidebarIndex(controller.currentPage.value),
                  onDestinationSelected: (index) =>
                      controller.changePage(_getMainPageIndex(index)),
                )),
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
                    title: Text(controller.getCurrentPageTitle()),
                    actions: [
                      // IconButton(
                      //   icon: Icon(Icons.search, color: Colors.white),
                      //   onPressed: () => Get.toNamed(AppRoutes.search),
                      // ),
                      IconButton(
                        icon: Icon(Icons.settings, color: Colors.white),
                        onPressed: controller.navigateToSettings,
                      ),
                    ],
                  ),
                ),
                // 显示当前选中的页面
                Padding(
                  padding: const EdgeInsets.only(top: 70),
                  child: Obx(() => _getCurrentPage()),
                ),
                // 正在播放音乐的小悬浮组件（在播放页时隐藏）
                Obx(() => controller.currentPage.value != 1
                    ? const Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: CurrentlyPlayingBar(),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 获取当前页面
  Widget _getCurrentPage() {
    switch (controller.currentPage.value) {
      case 0:
        return const SongListPage();
      case 1:
        return const PlayerPage();
      case 2:
        return const FavoritesPage();
      case 3:
        return const ProfilePage();
      default:
        return const SongListPage();
    }
  }

  /// 将主页面索引转换为侧边栏索引
  int _getSidebarIndex(int mainPageIndex) {
    switch (mainPageIndex) {
      case 0: // 音乐库
        return 0;
      case 1: // 播放
        return 0; // 播放页在侧边栏中没有对应项，默认为音乐库
      case 2: // 我的收藏
        return 2;
      case 3: // 个人中心
        return 3;
      default:
        return 0;
    }
  }

  /// 将侧边栏索引转换为主页面索引
  int _getMainPageIndex(int sidebarIndex) {
    switch (sidebarIndex) {
      case 0: // 音乐库
        return 0;
      case 1: // 搜索
        Get.toNamed(AppRoutes.search); // 搜索页使用单独的路由
        return 0; // 保持当前页面不变
      case 2: // 我的收藏
        return 2;
      case 3: // 个人中心
        return 3;
      default:
        return 0;
    }
  }
}

/// 顶部导航栏组件
class TopNavigationBar extends StatelessWidget {
  final Widget title;
  final List<Widget>? actions;

  const TopNavigationBar({Key? key, required this.title, this.actions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title is Text ? (title as Text).data ?? '' : title.toString(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ),
            if (actions != null) Row(children: actions!),
          ],
        ),
      ),
    );
  }
}
