import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vibe_music_app/generated/app_localizations.dart';
import 'package:vibe_music_app/src/pages/favorites/widgets/controller.dart';

class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.favorites ?? '我的收藏'),
      ),
      body: Center(
        child: Obx(() {
          if (!controller.isAuthenticated.value) {
            return buildLoginPrompt(context);
          }

          // 如果是第一页且仍在加载，显示加载指示器
          if (controller.allSongs.isEmpty && controller.isLoadingMore.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.allSongs.isEmpty) {
            return Center(
              child:
                  Text(AppLocalizations.of(context)?.noResults ?? '您还没有收藏任何音乐'),
            );
          }

          return ListView.builder(
            controller: controller.scrollController,
            itemCount: controller.allSongs.length +
                (controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              // 如果已到达末尾且正在加载更多，显示加载指示器
              if (index == controller.allSongs.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final song = controller.allSongs[index];
              final coverUrl = song.coverUrl;
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: coverUrl != null
                      ? CachedNetworkImageProvider(
                          coverUrl,
                          maxWidth: 100,
                          maxHeight: 100,
                          scale: 0.8,
                        )
                      : null,
                  child: coverUrl == null ? Icon(Icons.music_note) : null,
                ),
                title: Text(song.songName ?? '未知歌曲'),
                subtitle: Text(song.artistName ??
                    (AppLocalizations.of(context)?.artist ?? '未知艺术家')),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () =>
                          controller.handleRemoveFromFavorites(index),
                    ),
                    Icon(Icons.play_arrow),
                  ],
                ),
                onTap: () => controller.handleSongTap(index),
              );
            },
          );
        }),
      ),
    );
  }

  /// 构建收藏歌曲列表
  Widget buildFavoriteSongsList() {
    // 此方法不再使用，已合并到build方法中
    return Container();
  }

  /// 构建登录提示
  Widget buildLoginPrompt(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.favorite,
          size: 64,
          color: Colors.grey,
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)?.pleaseLogin ?? '请登录查看您的收藏音乐',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: controller.navigateToLogin,
          icon: Icon(Icons.login),
          label: Text(AppLocalizations.of(context)?.login ?? '去登录'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            textStyle: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
