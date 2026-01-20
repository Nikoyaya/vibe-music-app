import 'package:flutter/material.dart';
import 'package:vibe_music_app/src/utils/glass_morphism/glass_morphism.dart';

class SidebarNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onDestinationSelected;
  
  const SidebarNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GlassMorphism.glassCard(
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Logo和标题
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: const Text(
                'Vibe Music Player',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            
            // 导航项
            ...[
              { 'icon': Icons.music_note, 'label': '音乐库' },
              { 'icon': Icons.movie, 'label': 'MV' },
              { 'icon': Icons.radio, 'label': '电台' },
              { 'icon': Icons.search, 'label': '搜索' },
              { 'icon': Icons.favorite, 'label': '我的收藏' },
              { 'icon': Icons.person, 'label': '个人中心' },
            ].asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> item = entry.value;
              return ListTile(
                leading: Icon(item['icon'] as IconData, color: Colors.white),
                title: Text(item['label'] as String, style: const TextStyle(color: Colors.white)),
                selected: currentIndex == index,
                selectedTileColor: Colors.white.withOpacity(0.1),
                onTap: () => onDestinationSelected(index),
              );
            }).toList(),
            
            const Spacer(),
            
            // 用户信息
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text('用户名', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TopNavigationBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  
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

class BottomNavigationBarGlass extends StatelessWidget {
  final int currentIndex;
  final Function(int) onDestinationSelected;
  final List<NavigationDestination> items;
  
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
        indicatorColor: Colors.white.withOpacity(0.1),
      ),
    );
  }
}