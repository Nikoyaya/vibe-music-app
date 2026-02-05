import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/generated/app_localizations.dart';
import 'package:vibe_music_app/src/controllers/auth_controller.dart';
import 'package:vibe_music_app/src/utils/glass_morphism/glass_morphism.dart';

/// 侧边栏导航组件
///
/// 用于在平板和桌面端显示侧边导航栏，包含应用标题、导航项和用户信息
class SidebarNavigation extends StatelessWidget {
  /// 当前选中的导航项索引
  final int currentIndex;

  /// 导航项选择回调函数
  final Function(int) onDestinationSelected;

  /// 侧边栏导航构造函数
  ///
  /// [参数说明]:
  /// - [currentIndex]: 当前选中的导航项索引
  /// - [onDestinationSelected]: 导航项选择回调函数
  const SidebarNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final authProvider = Get.find<AuthController>();

    return GlassMorphism.glassCard(
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Logo和标题
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                localizations?.appTitle ?? 'Vibe Music Player',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            // 导航项
            ...[
              {'icon': Icons.music_note, 'label': localizations?.home ?? '音乐库'},
              {
                'icon': Icons.play_circle,
                'label': localizations?.player ?? '播放器'
              },
              {
                'icon': Icons.favorite,
                'label': localizations?.favorites ?? '我的收藏'
              },
              {'icon': Icons.person, 'label': localizations?.my ?? '个人中心'},
            ].asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> item = entry.value;
              return ListTile(
                leading: Icon(item['icon'] as IconData, color: Colors.white),
                title: Text(item['label'] as String,
                    style: const TextStyle(color: Colors.white)),
                selected: currentIndex == index,
                selectedTileColor: Colors.white.withValues(alpha: 0.1),
                onTap: () => onDestinationSelected(index),
              );
            }),

            const Spacer(),

            // 用户信息
            Obx(() {
              final isAuthenticated = authProvider.isAuthenticated;
              final user = authProvider.user;
              return Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (isAuthenticated && user?.userAvatar != null)
                      CircleAvatar(
                        backgroundImage: NetworkImage(user!.userAvatar!),
                        radius: 20,
                      )
                    else
                      CircleAvatar(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isAuthenticated && user?.username != null
                            ? user!.username!
                            : localizations?.pleaseLogin ?? '未登录',
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// 顶部导航栏组件
///
/// 用于在桌面端显示顶部导航栏，包含页面标题和操作按钮
class TopNavigationBar extends StatelessWidget {
  /// 页面标题
  final String title;

  /// 操作按钮列表
  final List<Widget>? actions;

  /// 顶部导航栏构造函数
  ///
  /// [参数说明]:
  /// - [title]: 页面标题
  /// - [actions]: 操作按钮列表
  const TopNavigationBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return GlassMorphism.glassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (actions != null) ...[
            Row(
              children: actions!,
            ),
          ],
        ],
      ),
    );
  }
}

/// 玻璃拟态底部导航栏组件
///
/// 用于显示带有玻璃拟态效果的底部导航栏
class BottomNavigationBarGlass extends StatelessWidget {
  /// 当前选中的导航项索引
  final int currentIndex;

  /// 导航项选择回调函数
  final Function(int) onDestinationSelected;

  /// 导航项列表
  final List<NavigationDestination> items;

  /// 玻璃拟态底部导航栏构造函数
  ///
  /// [参数说明]:
  /// - [currentIndex]: 当前选中的导航项索引
  /// - [onDestinationSelected]: 导航项选择回调函数
  /// - [items]: 导航项列表
  const BottomNavigationBarGlass({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return GlassMorphism.glassCard(
      padding: EdgeInsets.zero,
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: items,
        elevation: 0,
        backgroundColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: Colors.white.withValues(alpha: 0.1),
      ),
    );
  }
}
