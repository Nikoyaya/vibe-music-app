import 'package:flutter/material.dart';

/// 歌曲项组件
/// 用于显示单个歌曲信息
class SongItem extends StatelessWidget {
  /// 歌曲信息
  final dynamic song;
  /// 删除歌曲回调
  final Function(dynamic) onDelete;

  const SongItem({
    Key? key,
    required this.song,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: song['coverUrl'] != null
            ? NetworkImage(song['coverUrl'])
            : null,
        child: song['coverUrl'] == null
            ? Icon(Icons.music_note)
            : null,
      ),
      title: Text(song['songName'] ?? '未知歌曲'),
      subtitle:
          Text(song['artistName'] ?? '未知艺术家'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${song['playCount'] ?? 0} 次播放'),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => onDelete(song),
          ),
        ],
      ),
    );
  }
}