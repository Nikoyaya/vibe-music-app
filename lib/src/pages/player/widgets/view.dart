import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/src/pages/player/widgets/controller.dart';
import 'package:vibe_music_app/src/pages/player/components/player_cover_art.dart';
import 'package:vibe_music_app/src/pages/player/components/player_song_info.dart';
import 'package:vibe_music_app/src/pages/player/components/player_progress_bar.dart';
import 'package:vibe_music_app/src/pages/player/components/player_controls.dart';
import 'package:vibe_music_app/src/pages/player/components/player_volume_controls.dart';
import 'package:vibe_music_app/src/pages/player/components/player_playlist.dart';

class PlayerView extends GetView<PlayerController> {
  const PlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('正在播放'),
        actions: [
          Obx(() => IconButton(
                icon: Icon(
                  controller.currentSong != null &&
                          controller.isSongFavorited(controller.currentSong!)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: controller.currentSong != null &&
                          controller.isSongFavorited(controller.currentSong!)
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onPressed: controller.toggleFavorite,
              )),
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
          // 点击外部区域收起播放列表的遮罩层
          Obx(() =>
              controller.isExpanded.value && controller.playlist.isNotEmpty
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
          Obx(() =>
              controller.isExpanded.value && controller.playlist.isNotEmpty
                  ? PlayerPlaylist(
                      playlist: controller.playlist,
                      currentIndex: controller.currentIndex,
                      onSongTap: controller.playSongAtIndex,
                      onToggleFavorite: controller.handlePlaylistFavoriteToggle,
                      isSongFavorited: controller.isSongFavorited,
                    )
                  : const SizedBox()),
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
  }
}
