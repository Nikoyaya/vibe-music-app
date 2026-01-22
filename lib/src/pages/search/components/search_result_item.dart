import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_music_app/src/models/song_model.dart';
import 'package:vibe_music_app/src/providers/music_provider.dart';
import 'package:vibe_music_app/src/providers/auth_provider.dart';

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
    final musicProvider = Provider.of<MusicProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isFavorited = musicProvider.isSongFavorited(song);

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
              if (!authProvider.isAuthenticated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请先登录')),
                );
                return;
              }

              bool success;
              if (isFavorited) {
                success = await musicProvider.removeFromFavorites(song);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已取消收藏')),
                  );
                }
              } else {
                success = await musicProvider.addToFavorites(song);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已添加到收藏')),
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
