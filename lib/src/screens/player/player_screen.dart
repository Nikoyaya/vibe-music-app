import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_music_app/src/providers/music_provider.dart';
import 'package:vibe_music_app/src/providers/auth_provider.dart';
import 'package:vibe_music_app/src/screens/auth/login_screen.dart';
import 'package:vibe_music_app/src/screens/player/components/player_cover_art.dart';
import 'package:vibe_music_app/src/screens/player/components/player_song_info.dart';
import 'package:vibe_music_app/src/screens/player/components/player_progress_bar.dart';
import 'package:vibe_music_app/src/screens/player/components/player_controls.dart';
import 'package:vibe_music_app/src/screens/player/components/player_volume_controls.dart';
import 'package:vibe_music_app/src/screens/player/components/player_playlist.dart';

/// 播放器屏幕
/// 用于播放音乐和控制播放状态
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  /// 是否展开歌曲详情
  bool _isExpanded = false;

  /// 是否显示音量指示器
  bool _showVolumeIndicator = false;

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('正在播放'),
        actions: [
          IconButton(
            icon: Icon(
              musicProvider.currentSong != null &&
                      musicProvider.isSongFavorited(musicProvider.currentSong!)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: musicProvider.currentSong != null &&
                      musicProvider.isSongFavorited(musicProvider.currentSong!)
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            onPressed: () async {
              if (musicProvider.currentSong == null) return;

              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              if (!authProvider.isAuthenticated) {
                // 提示用户登录
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('请先登录')),
                );
                // 导航到登录页面
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
                return;
              }

              bool success;
              final song = musicProvider.currentSong!;
              if (musicProvider.isSongFavorited(song)) {
                success = await musicProvider.removeFromFavorites(song);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('已取消收藏')),
                  );
                }
              } else {
                success = await musicProvider.addToFavorites(song);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('已添加到收藏')),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.queue_music),
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
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
                        const sensitivity = 0.005; // 灵敏度
                        double newVolume = musicProvider.volume -
                            details.delta.dy * sensitivity;

                        // 确保音量在0.0到1.0之间
                        newVolume = newVolume.clamp(0.0, 1.0);

                        // 更新音量 - 直接调用provider方法，会通过stream通知更新
                        musicProvider.setVolume(newVolume);

                        // 显示音量指示器
                        if (!_showVolumeIndicator) {
                          setState(() {
                            _showVolumeIndicator = true;
                          });

                          // 3秒后隐藏指示器
                          Future.delayed(const Duration(seconds: 3), () {
                            if (mounted) {
                              setState(() {
                                _showVolumeIndicator = false;
                              });
                            }
                          });
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 专辑封面
                          PlayerCoverArt(
                            coverUrl: musicProvider.currentSong?.coverUrl,
                          ),
                          const SizedBox(height: 32),
                          // 歌曲信息
                          PlayerSongInfo(
                            songName: musicProvider.currentSong?.songName,
                            artistName: musicProvider.currentSong?.artistName,
                          ),
                          const SizedBox(height: 32),
                          // 进度条 - 使用StreamBuilder只监听进度变化
                          StreamBuilder<Duration>(
                            stream: musicProvider.positionStream,
                            builder: (context, positionSnapshot) {
                              final position =
                                  positionSnapshot.data ?? Duration.zero;
                              final duration = musicProvider.duration;

                              return PlayerProgressBar(
                                position: position,
                                duration: duration,
                                onSeek: (duration) {
                                  musicProvider.seekTo(duration);
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          // 控制按钮
                          PlayerControls(
                            isPlaying: musicProvider.playerState ==
                                AppPlayerState.playing,
                            isShuffle: musicProvider.isShuffle,
                            repeatMode:
                                musicProvider.repeatMode == RepeatMode.one
                                    ? 'one'
                                    : musicProvider.repeatMode == RepeatMode.all
                                        ? 'all'
                                        : 'none',
                            volume: musicProvider.volume,
                            onPlay: musicProvider.play,
                            onPause: musicProvider.pause,
                            onPrevious: musicProvider.previous,
                            onNext: musicProvider.next,
                            onToggleShuffle: musicProvider.toggleShuffle,
                            onToggleRepeat: musicProvider.toggleRepeat,
                            onToggleVolumeControls: () {
                              setState(() {
                                _showVolumeIndicator = !_showVolumeIndicator;
                              });
                            },
                          ),
                          // 音量控制 - 显示在单独的行，避免水平溢出
                          if (_showVolumeIndicator)
                            StreamBuilder<double>(
                              stream: musicProvider.volumeStream,
                              initialData: musicProvider.volume,
                              builder: (context, volumeSnapshot) {
                                return PlayerVolumeControls(
                                  volume: volumeSnapshot.data ?? 0.5,
                                  onVolumeChanged: (value) {
                                    musicProvider.setVolume(value);
                                  },
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 点击外部区域收起播放列表的遮罩层
          if (_isExpanded && musicProvider.playlist.isNotEmpty)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = false;
                  });
                },
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          // 播放列表（可展开）
          if (_isExpanded && musicProvider.playlist.isNotEmpty)
            PlayerPlaylist(
              playlist: musicProvider.playlist,
              currentIndex: musicProvider.currentIndex,
              onSongTap: (index) {
                musicProvider.playSong(musicProvider.playlist[index]);
              },
              onToggleFavorite: (song) async {
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                if (!authProvider.isAuthenticated) {
                  // 提示用户登录
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('请先登录')),
                  );
                  // 导航到登录页面
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                  return;
                }

                bool success;
                if (musicProvider.isSongFavorited(song)) {
                  success = await musicProvider.removeFromFavorites(song);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('已取消收藏')),
                    );
                  }
                } else {
                  success = await musicProvider.addToFavorites(song);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('已添加到收藏')),
                    );
                  }
                }
              },
              isSongFavorited: (song) => musicProvider.isSongFavorited(song),
            ),
          // 音量指示器 - 使用StreamBuilder监听音量变化
          if (_showVolumeIndicator)
            StreamBuilder<double>(
              stream: musicProvider.volumeStream,
              initialData: musicProvider.volume,
              builder: (context, volumeSnapshot) {
                final currentVolume = volumeSnapshot.data ?? 0.5;
                return Positioned(
                  top: 80,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withAlpha(76), // 使用withAlpha替代withValues
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
            ),
        ],
      ),
    );
  }
}
