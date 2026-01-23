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

  /// 删除歌曲回调
  final Function(int) onRemoveSong;

  const PlayerPlaylist({
    Key? key,
    required this.playlist,
    required this.currentIndex,
    required this.onSongTap,
    required this.onToggleFavorite,
    required this.isSongFavorited,
    required this.onRemoveSong,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.of(context).size.height * 0.4, // 增加最大高度为屏幕高度的40%
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(38), // 增加阴影透明度
              blurRadius: 15,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          children: [
            // 播放列表标题栏
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '播放列表',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '${playlist.length} 首歌曲',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // 播放列表内容
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                trackVisibility: false,
                thickness: 6,
                radius: const Radius.circular(3),
                child: ListView.separated(
                  itemCount: playlist.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    thickness: 1,
                    color: Theme.of(context).colorScheme.outlineVariant,
                    indent: 80,
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
                              .withAlpha(150) // 增加透明度，使高亮更明显
                          : Colors.transparent,
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 歌曲序号或播放图标
                            Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              child: isCurrent
                                  ? Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.play_arrow,
                                          color: Colors.white, size: 16),
                                    )
                                  : Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 8),
                            // 歌曲封面
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceVariant,
                              ),
                              child: song.coverUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        song.coverUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(Icons.music_note,
                                              size: 20, color: Colors.grey);
                                        },
                                      ),
                                    )
                                  : const Icon(Icons.music_note,
                                      size: 20, color: Colors.grey),
                            ),
                          ],
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
                            fontSize: 14,
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
                            fontSize: 12,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                isSongFavorited(song)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isSongFavorited(song)
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                                size: 20,
                              ),
                              onPressed: () => onToggleFavorite(song),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Theme.of(context).colorScheme.error,
                                size: 20,
                              ),
                              onPressed: () => onRemoveSong(index),
                            ),
                          ],
                        ),
                        onTap: () => onSongTap(index),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
