import 'package:flutter/material.dart';
import 'package:vibe_music_app/src/models/song_model.dart';

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
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: coverUrl != null
            ? NetworkImage(coverUrl)
            : null,
        child: coverUrl == null
            ? Icon(Icons.music_note)
            : null,
      ),
      title: Text(song.songName ?? '未知歌曲'),
      subtitle: Text(song.artistName ?? '未知艺术家'),
      trailing: Icon(Icons.play_arrow),
      onTap: () => onTap(song),
    );
  }
}