import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/src/pages/admin/widgets/controller.dart';
import 'package:vibe_music_app/src/pages/admin/components/song_list.dart';
import 'package:vibe_music_app/src/pages/admin/components/user_list.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('管理面板'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: controller.refreshData,
          ),
        ],
      ),
      body: Column(
        children: [
          // 标签栏
          Obx(() => TabBar(
                onTap: controller.changeTab,
                tabs: const [
                  Tab(text: '用户'),
                  Tab(text: '歌曲'),
                ],
              )),
          // 内容
          Expanded(
            child: Obx(() {
              if (controller.currentTab.value == 0) {
                return UserList(
                  users: controller.users,
                  isLoading: controller.isLoading.value,
                  searchController: controller.userSearchController,
                  onSearch: () => controller.loadUsers(),
                  onClearSearch: controller.clearUserSearch,
                  onDeleteUser: controller.handleDeleteUser,
                );
              } else {
                return SongList(
                  songs: controller.songs,
                  isLoading: controller.isLoading.value,
                  searchController: controller.songSearchController,
                  onSearch: () => controller.loadSongs(),
                  onClearSearch: controller.clearSongSearch,
                  onDeleteSong: controller.handleDeleteSong,
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
