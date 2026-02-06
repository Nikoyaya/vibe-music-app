import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/generated/app_localizations.dart';
import 'package:vibe_music_app/src/controllers/music_controller.dart';
import 'package:vibe_music_app/src/pages/player/widgets/controller.dart';
import 'package:vibe_music_app/src/pages/player/components/player_cover_art.dart';
import 'package:vibe_music_app/src/pages/player/components/player_song_info.dart';
import 'package:vibe_music_app/src/pages/player/components/player_progress_bar.dart';
import 'package:vibe_music_app/src/pages/player/components/player_controls.dart';
import 'package:vibe_music_app/src/pages/player/components/player_volume_controls.dart';
import 'package:vibe_music_app/src/pages/player/components/player_playlist.dart';
import 'package:vibe_music_app/src/utils/glass_morphism/responsive_layout.dart';

class PlayerView extends GetView<PlayerController> {
  const PlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ScreenSize.isDesktop(context);

    final mainContent = Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.nowPlaying ?? '正在播放'),
        actions: [
          GetBuilder<PlayerController>(
            init: Get.find<PlayerController>(),
            id: 'favoriteButton',
            builder: (controller) {
              final musicController = Get.find<MusicController>();
              final currentSong = musicController.currentSong;
              final isFavorited = currentSong != null &&
                  musicController.isSongFavorited(currentSong);
              final isLoading = currentSong?.id != null
                  ? controller.favoriteLoadingStates[currentSong!.id!] ?? false
                  : false;
              return IconButton(
                onPressed: isLoading ? null : controller.toggleFavorite,
                icon: isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      )
                    : Icon(
                        isFavorited ? Icons.favorite : Icons.favorite_border,
                        size: 24,
                        color: isFavorited
                            ? Colors.red
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.queue_music),
            onPressed: controller.togglePlaylistExpanded,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height - kToolbarHeight,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onVerticalDragUpdate: (details) {
                        // 垂直滑动调整音量
                        controller.adjustVolume(details.delta.dy);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 专辑封面
                          Obx(() => PlayerCoverArt(
                                coverUrl: controller.currentSong?.coverUrl,
                              )),
                          const SizedBox(height: 32),
                          // 歌曲信息
                          Obx(() => PlayerSongInfo(
                                songName: controller.currentSong?.songName,
                                artistName: controller.currentSong?.artistName,
                              )),
                          const SizedBox(height: 32),
                          // 进度条 - 使用StreamBuilder只监听进度变化
                          StreamBuilder<Duration>(
                            stream: controller.positionStream,
                            builder: (context, positionSnapshot) {
                              final position =
                                  positionSnapshot.data ?? Duration.zero;
                              final duration = controller.duration;

                              return PlayerProgressBar(
                                position: position,
                                duration: duration,
                                onSeek: controller.seekTo,
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          // 控制按钮
                          Obx(() => PlayerControls(
                                isPlaying: controller.isPlaying,
                                isShuffle: controller.isShuffle,
                                repeatMode: controller.repeatMode,
                                volume: controller.volume,
                                onPlay: controller.play,
                                onPause: controller.pause,
                                onPrevious: controller.previous,
                                onNext: controller.next,
                                onToggleShuffle: controller.toggleShuffle,
                                onToggleRepeat: controller.toggleRepeat,
                                onToggleVolumeControls:
                                    controller.toggleVolumeIndicator,
                              )),
                          // 音量控制 - 显示在单独的行，避免水平溢出
                          Obx(() => controller.showVolumeIndicator.value
                              ? StreamBuilder<double>(
                                  stream: controller.volumeStream,
                                  initialData: controller.volume,
                                  builder: (context, volumeSnapshot) {
                                    return PlayerVolumeControls(
                                      volume: volumeSnapshot.data ?? 0.5,
                                      onVolumeChanged: controller.setVolume,
                                    );
                                  },
                                )
                              : const SizedBox()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 音量指示器 - 使用StreamBuilder监听音量变化
          Obx(() => controller.showVolumeIndicator.value
              ? StreamBuilder<double>(
                  stream: controller.volumeStream,
                  initialData: controller.volume,
                  builder: (context, volumeSnapshot) {
                    final currentVolume = volumeSnapshot.data ?? 0.5;
                    return Positioned(
                      top: 80,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(76),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              currentVolume > 0.5
                                  ? Icons.volume_up
                                  : currentVolume > 0
                                      ? Icons.volume_down
                                      : Icons.volume_off,
                              size: 32,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(currentVolume * 100).round()}%',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : const SizedBox()),
        ],
      ),
    );

    // 桌面端使用右侧滑动面板
    if (isDesktop) {
      return Stack(
        children: [
          mainContent,
          // 右侧播放列表面板
          _buildDesktopPlaylistPanel(context),
        ],
      );
    }

    // 移动端使用底部弹出面板
    return Stack(
      children: [
        mainContent,
        // 点击外部区域收起播放列表的遮罩层
        Obx(() => controller.isExpanded.value && controller.playlist.isNotEmpty
            ? Positioned.fill(
                child: GestureDetector(
                  onTap: controller.togglePlaylistExpanded,
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              )
            : const SizedBox()),
        // 播放列表（可展开）
        Obx(() => controller.isExpanded.value && controller.playlist.isNotEmpty
            ? PlayerPlaylist(
                playlist: controller.playlist,
                currentIndex: controller.currentIndex,
                onSongTap: controller.playSongAtIndex,
                onToggleFavorite: controller.handlePlaylistFavoriteToggle,
                isSongFavorited: controller.isSongFavorited,
                onRemoveSong: controller.removeFromPlaylist,
                onClearPlaylist: controller.clearPlaylist,
              )
            : const SizedBox()),
      ],
    );
  }

  /// 构建桌面端右侧播放列表面板
  Widget _buildDesktopPlaylistPanel(BuildContext context) {
    return Obx(() => AnimatedPositioned(
          right: controller.isExpanded.value ? 0 : -400,
          top: 0,
          bottom: 0,
          width: 400,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(100),
                  blurRadius: 20,
                  offset: Offset(-10, 0),
                ),
              ],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                // 面板标题栏
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                      Row(
                        children: [
                          // 清空播放列表按钮
                          IconButton(
                            icon: Icon(Icons.delete_sweep),
                            onPressed: controller.clearPlaylist,
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: controller.togglePlaylistExpanded,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 播放列表内容
                Expanded(
                  child: _buildDesktopPlaylistContent(context),
                ),
              ],
            ),
          ),
        ));
  }

  /// 构建桌面端播放列表内容
  Widget _buildDesktopPlaylistContent(BuildContext context) {
    return Obx(() => Container(
          child: ListView.separated(
            itemCount: controller.playlist.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 1,
              color: Theme.of(context).colorScheme.outlineVariant,
              indent: 80,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final song = controller.playlist[index];
              final isCurrent = index == controller.currentIndex;
              return AnimatedContainer(
                duration: Duration(milliseconds: 200),
                color: isCurrent
                    ? Theme.of(context).colorScheme.primary.withAlpha(20)
                    : Colors.transparent,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.play_arrow,
                                    color: Colors.white, size: 16),
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      // 歌曲封面
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).colorScheme.surfaceVariant,
                        ),
                        child: song.coverUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  song.coverUrl!,
                                  fit: BoxFit.cover,
                                  width: 40,
                                  height: 40,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceVariant,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(Icons.music_note, size: 20),
                                    );
                                  },
                                ),
                              )
                            : Icon(Icons.music_note, size: 20),
                      ),
                    ],
                  ),
                  title: Text(
                    song.songName ?? '未知歌曲',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    song.artistName ?? '未知艺术家',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 收藏按钮
                      IconButton(
                        onPressed: () {
                          controller.handlePlaylistFavoriteToggle(song);
                        },
                        icon: song.id != null &&
                                (controller.favoriteLoadingStates[song.id!] ??
                                    false)
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              )
                            : Icon(
                                controller.isSongFavorited(song)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 20,
                                color: controller.isSongFavorited(song)
                                    ? Colors.red
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                              ),
                      ),
                      // 移除按钮
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          controller.removeFromPlaylist(index);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    controller.playSongAtIndex(index);
                  },
                ),
              );
            },
          ),
        ));
  }
}
