import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/src/providers/music_provider.dart';
import 'package:vibe_music_app/src/models/song_model.dart';
import 'package:vibe_music_app/src/utils/glass_morphism/glass_morphism.dart';

/// 当前播放音乐的底部控件
class CurrentlyPlayingBar extends StatelessWidget {
  const CurrentlyPlayingBar({super.key});

  @override
  Widget build(BuildContext context) {
    final musicProvider = Get.find<MusicProvider>();

    return AnimatedBuilder(
      animation: musicProvider,
      builder: (context, child) {
        if (musicProvider.currentSong == null ||
            musicProvider.playerState == AppPlayerState.stopped) {
          return const SizedBox.shrink();
        }

        final song = musicProvider.currentSong!;

        return _CurrentlyPlayingBarContent(
          musicProvider: musicProvider,
          song: song,
        );
      },
    );
  }
}

/// 当前播放音乐的底部控件内容
class _CurrentlyPlayingBarContent extends StatefulWidget {
  final MusicProvider musicProvider;
  final Song song;

  const _CurrentlyPlayingBarContent({
    required this.musicProvider,
    required this.song,
  });

  @override
  State<_CurrentlyPlayingBarContent> createState() =>
      _CurrentlyPlayingBarContentState();
}

class _CurrentlyPlayingBarContentState
    extends State<_CurrentlyPlayingBarContent> {
  /// 滑动偏移量
  double _offset = 0.0;

  /// 是否正在进行滑动操作
  bool _isSwiping = false;

  /// 是否正在显示关闭确认对话框
  bool _isShowingCloseDialog = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        setState(() {
          _isSwiping = true;
        });
      },
      onHorizontalDragUpdate: (details) {
        setState(() {
          _offset += details.delta.dx;
          // 限制滑动范围，只允许向左滑动
          if (_offset > 0) {
            _offset = 0;
          }
        });
      },
      onHorizontalDragEnd: (details) {
        if (_offset < -50) {
          // 向左滑动超过阈值，显示关闭提示
          showCloseConfirmation(context, widget.musicProvider);
        }
        setState(() {
          _offset = 0;
          _isSwiping = false;
        });
      },
      onTap: () {
        // 防止滑动后点击触发导航
        if (_isSwiping) {
          return;
        }
      },
      child: Stack(
        children: [
          // 关闭提示
          if (_offset < -30)
            Positioned(
              right: 20,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                // 防止点击关闭提示时触发下方的导航事件
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  showCloseConfirmation(context, widget.musicProvider);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '是否关闭',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // 主要内容
          Transform.translate(
            offset: Offset(_offset, 0),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow,
                    blurRadius: 16,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: GlassMorphism.glassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 歌曲信息和控制按钮
                    GestureDetector(
                      onTap: () {
                        // 只有当没有滑动偏移、不在滑动状态且没有显示关闭对话框时才导航到播放页面
                        if (_offset == 0 &&
                            !_isSwiping &&
                            !_isShowingCloseDialog) {
                          Get.toNamed('/player');
                        }
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
                                borderRadius: BorderRadius.circular(12),
                                child: widget.song.coverUrl != null
                                    ? Image.network(
                                        widget.song.coverUrl!,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            width: 56,
                                            height: 56,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primaryContainer,
                                            child: Icon(Icons.music_note,
                                                size: 28,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                          );
                                        },
                                      )
                                    : Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(Icons.music_note,
                                            size: 28,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer),
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
                                    widget.song.songName ?? 'Unknown Song',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    widget.song.artistName ?? 'Unknown Artist',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.white.withOpacity(0.8),
                                          fontWeight: FontWeight.w400,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // 控制按钮
                            GlassMorphism.glassCard(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.skip_previous,
                                      size: 22,
                                      color: Colors.white,
                                    ),
                                    onPressed: () =>
                                        widget.musicProvider.previous(),
                                    padding: const EdgeInsets.all(6),
                                    constraints:
                                        const BoxConstraints(minWidth: 36),
                                    splashRadius: 20,
                                  ),
                                  // 使用StreamBuilder监听播放状态变化
                                  StreamBuilder<AppPlayerState>(
                                    stream:
                                        widget.musicProvider.playerStateStream,
                                    initialData:
                                        widget.musicProvider.playerState,
                                    builder: (context, snapshot) {
                                      final playerState = snapshot.data ??
                                          AppPlayerState.stopped;
                                      return IconButton(
                                        icon: Icon(
                                          playerState == AppPlayerState.playing
                                              ? Icons.pause_circle_filled
                                              : Icons.play_circle_filled,
                                          size: 36,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        onPressed: () {
                                          if (playerState ==
                                              AppPlayerState.playing) {
                                            widget.musicProvider.pause();
                                          } else {
                                            widget.musicProvider.play();
                                          }
                                        },
                                        padding: const EdgeInsets.all(4),
                                        constraints:
                                            const BoxConstraints(minWidth: 44),
                                        splashRadius: 24,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.skip_next,
                                      size: 22,
                                      color: Colors.white,
                                    ),
                                    onPressed: () =>
                                        widget.musicProvider.next(),
                                    padding: const EdgeInsets.all(6),
                                    constraints:
                                        const BoxConstraints(minWidth: 36),
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
        ],
      ),
    );
  }

  /// 显示关闭确认对话框
  void showCloseConfirmation(
      BuildContext context, MusicProvider musicProvider) {
    setState(() {
      _isShowingCloseDialog = true;
    });

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('关闭播放'),
          content: const Text('确定要关闭当前播放吗？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                setState(() {
                  _isShowingCloseDialog = false;
                });
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                // 停止音乐
                musicProvider.stop();
                // 直接关闭对话框
                Navigator.pop(dialogContext);
                setState(() {
                  _isShowingCloseDialog = false;
                });
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
}
