import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/generated/app_localizations.dart';
import 'package:vibe_music_app/src/models/song_model.dart';
import 'package:vibe_music_app/src/controllers/music_controller.dart';
import 'package:vibe_music_app/src/controllers/auth_controller.dart';
import 'package:vibe_music_app/src/utils/snackbar_manager.dart';

/// 搜索结果项组件
/// 用于显示单个搜索结果
class SearchResultItem extends StatelessWidget {
  /// 歌曲信息
  final Song song;

  /// 点击回调
  final Function(Song) onTap;

  const SearchResultItem({
    Key? key,
    required this.song,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final coverUrl = song.coverUrl;
    final musicController = Get.find<MusicController>();
    final authController = Get.find<AuthController>();
    final isFavorited = musicController.isSongFavorited(song);

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: coverUrl != null ? NetworkImage(coverUrl) : null,
        child: coverUrl == null ? Icon(Icons.music_note) : null,
      ),
      title: Text(song.songName ?? '未知歌曲'),
      subtitle: Text(song.artistName ?? '未知艺术家'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_border,
              color: isFavorited ? Theme.of(context).colorScheme.primary : null,
            ),
            onPressed: () async {
              final localizations = AppLocalizations.of(context);
              if (!authController.isAuthenticated) {
                SnackbarManager().showSnackbar(
                  title: localizations?.tip ?? '提示',
                  message: localizations?.pleaseLogin ?? '请先登录',
                  icon: Icon(Icons.info, color: Colors.white),
                  duration: Duration(seconds: 2),
                  color: Colors.blue,
                );
                return;
              }

              bool success;
              if (isFavorited) {
                success = await musicController.removeFromFavorites(song);
                if (success) {
                  SnackbarManager().showSnackbar(
                    title: localizations?.success ?? '成功',
                    message: localizations?.removedFromFavorites ?? '已取消收藏',
                    icon: Icon(Icons.check_circle, color: Colors.white),
                    duration: Duration(seconds: 2),
                  );
                }
              } else {
                success = await musicController.addToFavorites(song);
                if (success) {
                  SnackbarManager().showSnackbar(
                    title: localizations?.success ?? '成功',
                    message: localizations?.addedToFavorites ?? '已添加到收藏',
                    icon: Icon(Icons.check_circle, color: Colors.white),
                    duration: Duration(seconds: 2),
                  );
                }
              }
            },
          ),
          Icon(Icons.play_arrow),
        ],
      ),
      onTap: () => onTap(song),
    );
  }
}
