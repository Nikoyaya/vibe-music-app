import 'package:flutter/material.dart';
import 'package:vibe_music_app/src/models/song_model.dart';

/// 播放列表组件
/// 用于显示和管理当前播放列表
class PlayerPlaylist extends StatelessWidget {
  /// 播放列表
  final List<Song> playlist;
  /// 当前播放索引
  final int currentIndex;
  /// 点击歌曲回调
  final Function(int) onSongTap;
  /// 收藏状态回调
  final Function(Song) onToggleFavorite;
  /// 检查歌曲是否被收藏的函数
  final bool Function(Song) isSongFavorited;

  const PlayerPlaylist({
    Key? key,
    required this.playlist,
    required this.currentIndex,
    required this.onSongTap,
    required this.onToggleFavorite,
    required this.isSongFavorited,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.3, // 最大高度为屏幕高度的30%
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26), // 使用withAlpha替代withValues
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ListView.separated(
          itemCount: playlist.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
            indent: 72,
            endIndent: 16,
          ),
          itemBuilder: (context, index) {
            final song = playlist[index];
            final isCurrent = index == currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              color: isCurrent
                  ? Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withAlpha(128) // 使用withAlpha替代withValues
                  : Colors.transparent,
              child: ListTile(
                leading: isCurrent
                    ? Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.play_arrow,
                            color: Colors.white, size: 20),
                      )
                    : Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                title: Text(
                  song.songName ?? '未知',
                  style: TextStyle(
                    color: isCurrent
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight:
                        isCurrent ? FontWeight.bold : FontWeight.normal,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                subtitle: Text(
                  song.artistName ?? '',
                  style: TextStyle(
                    color: isCurrent
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    isSongFavorited(song)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: isSongFavorited(song)
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    size: 18,
                  ),
                  onPressed: () => onToggleFavorite(song),
                ),
                onTap: () => onSongTap(index),
              ),
            );
          },
        ),
      ),
    );
  }
}