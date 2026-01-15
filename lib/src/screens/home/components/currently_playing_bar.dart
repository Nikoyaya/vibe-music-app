import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:vibe_music_app/src/providers/music_provider.dart';
import 'package:vibe_music_app/src/screens/player/player_screen.dart';

/// 当前播放音乐的底部控件
class CurrentlyPlayingBar extends StatelessWidget {
  const CurrentlyPlayingBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        if (musicProvider.currentSong == null ||
            musicProvider.playerState == AppPlayerState.stopped) {
          return const SizedBox.shrink();
        }

        final song = musicProvider.currentSong!;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.2),
                blurRadius: 16,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
              child: Container(
                color: Theme.of(context)
                    .colorScheme
                    .surface
                    .withValues(alpha: 0.85),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 进度条 - 使用StreamBuilder监听进度变化
                    StreamBuilder<Duration>(
                      stream: musicProvider.positionStream,
                      builder: (context, positionSnapshot) {
                        return StreamBuilder<Duration>(
                          stream: musicProvider.durationStream,
                          builder: (context, durationSnapshot) {
                            final position = positionSnapshot.data ?? Duration.zero;
                            final duration = durationSnapshot.data ?? Duration.zero;
                            final progress = duration.inSeconds > 0
                                ? position.inSeconds / duration.inSeconds
                                : 0.0;

                            return GestureDetector(
                              onTapDown: (TapDownDetails details) {
                                final RenderBox box = context.findRenderObject() as RenderBox;
                                final tapPosition = box.globalToLocal(details.globalPosition);
                                final progressWidth = box.size.width - 32;
                                final tapProgress = tapPosition.dx / progressWidth;
                                final newPosition = Duration(
                                  seconds: (tapProgress * duration.inSeconds).toInt(),
                                );
                                musicProvider.seekTo(newPosition);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                height: 6,
                                child: Container(
                                  width: double.infinity,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(3),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          backgroundColor: Colors.transparent,
                                          color: Theme.of(context).colorScheme.primary,
                                          minHeight: 6,
                                        ),
                                      ),
                                      // 进度指示器
                                      Positioned(
                                        left: progress *
                                                (MediaQuery.of(context).size.width - 32) -
                                            6,
                                        top: -3,
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primary,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Theme.of(context).colorScheme.surface,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color.fromRGBO(0, 0, 0, 0.2),
                                                blurRadius: 4,
                                                offset: Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),

                    // 歌曲信息和控制按钮
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PlayerScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            // 歌曲封面
                            Hero(
                              tag: 'currentSong',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: song.coverUrl != null
                                    ? Image.network(
                                        song.coverUrl!,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            width: 56,
                                            height: 56,
                                            color: Theme.of(context).colorScheme.primaryContainer,
                                            child: Icon(Icons.music_note, size: 28),
                                          );
                                        },
                                      )
                                    : Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.music_note, size: 28, color: Colors.white),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // 歌曲信息
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    song.songName ?? 'Unknown Song',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    song.artistName ?? 'Unknown Artist',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w400,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // 控制按钮
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.skip_previous,
                                      size: 22,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    onPressed: () => musicProvider.previous(),
                                    padding: const EdgeInsets.all(6),
                                    constraints: const BoxConstraints(minWidth: 36),
                                    splashRadius: 20,
                                  ),
                                  // 使用StreamBuilder监听播放状态变化
                                  StreamBuilder<AppPlayerState>(
                                    stream: musicProvider.playerStateStream,
                                    initialData: musicProvider.playerState,
                                    builder: (context, snapshot) {
                                      final playerState = snapshot.data ?? AppPlayerState.stopped;
                                      return IconButton(
                                        icon: Icon(
                                          playerState == AppPlayerState.playing
                                              ? Icons.pause_circle_filled
                                              : Icons.play_circle_filled,
                                          size: 36,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                        onPressed: () {
                                          if (playerState == AppPlayerState.playing) {
                                            musicProvider.pause();
                                          } else {
                                            musicProvider.play();
                                          }
                                        },
                                        padding: const EdgeInsets.all(4),
                                        constraints: const BoxConstraints(minWidth: 44),
                                        splashRadius: 24,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.skip_next,
                                      size: 22,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    onPressed: () => musicProvider.next(),
                                    padding: const EdgeInsets.all(6),
                                    constraints: const BoxConstraints(minWidth: 36),
                                    splashRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
