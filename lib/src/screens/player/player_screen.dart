import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_music_app/src/providers/music_provider.dart';
import 'package:vibe_music_app/src/providers/auth_provider.dart';
import 'package:vibe_music_app/src/screens/auth/login_screen.dart';

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

  /// 当前音量值
  double _currentVolume = 0.5; // 初始音量

  @override
  void initState() {
    super.initState();
    // 从musicProvider获取初始音量
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    _currentVolume = musicProvider.volume;
  }

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('正在播放'),
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
                  const SnackBar(content: Text('请先登录')),
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
          IconButton(
            icon: const Icon(Icons.queue_music),
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
                        double newVolume =
                            _currentVolume - details.delta.dy * sensitivity;

                        // 确保音量在0.0到1.0之间
                        newVolume = newVolume.clamp(0.0, 1.0);

                        // 更新音量
                        musicProvider.setVolume(newVolume);
                        setState(() {
                          _currentVolume = newVolume;
                        });

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
                          // Album Art
                          Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: musicProvider.currentSong?.coverUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      musicProvider.currentSong!.coverUrl!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child:
                                        const Icon(Icons.music_note, size: 100),
                                  ),
                          ),
                          const SizedBox(height: 32),
                          // Song Info
                          Text(
                            musicProvider.currentSong?.songName ??
                                'Unknown Song',
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            musicProvider.currentSong?.artistName ??
                                'Unknown Artist',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                          const SizedBox(height: 32),
                          // Progress Bar
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                Slider(
                                  value: musicProvider.position.inSeconds
                                      .toDouble(),
                                  max: musicProvider.duration.inSeconds
                                      .toDouble()
                                      .clamp(1.0, double.infinity),
                                  onChanged: (value) {
                                    musicProvider.seekTo(
                                        Duration(seconds: value.toInt()));
                                  },
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_formatDuration(
                                        musicProvider.position)),
                                    Text(_formatDuration(
                                        musicProvider.duration)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Controls
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Shuffle
                                IconButton(
                                  icon: Icon(
                                    Icons.shuffle,
                                    color: musicProvider.isShuffle
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                  ),
                                  onPressed: () =>
                                      musicProvider.toggleShuffle(),
                                ),
                                const SizedBox(width: 4),
                                // Previous
                                IconButton(
                                  icon:
                                      const Icon(Icons.skip_previous, size: 32),
                                  onPressed: () => musicProvider.previous(),
                                ),
                                const SizedBox(width: 12),
                                // Play/Pause
                                FloatingActionButton(
                                  onPressed: () {
                                    if (musicProvider.playerState ==
                                        AppPlayerState.playing) {
                                      musicProvider.pause();
                                    } else {
                                      musicProvider.play();
                                    }
                                  },
                                  child: Icon(
                                    musicProvider.playerState ==
                                            AppPlayerState.playing
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    size: 36,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Next
                                IconButton(
                                  icon: const Icon(Icons.skip_next, size: 32),
                                  onPressed: () => musicProvider.next(),
                                ),
                                const SizedBox(width: 4),
                                // Volume Control - 只显示按钮，点击弹出音量控制
                                IconButton(
                                  icon: Icon(
                                    _currentVolume > 0.5
                                        ? Icons.volume_up
                                        : _currentVolume > 0
                                            ? Icons.volume_down
                                            : Icons.volume_off,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showVolumeIndicator =
                                          !_showVolumeIndicator;
                                    });
                                  },
                                ),
                                const SizedBox(width: 4),
                                // Repeat
                                IconButton(
                                  icon: Icon(
                                    musicProvider.repeatMode == RepeatMode.one
                                        ? Icons.repeat_one
                                        : Icons.repeat,
                                    color: musicProvider.repeatMode !=
                                            RepeatMode.none
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                  ),
                                  onPressed: () => musicProvider.toggleRepeat(),
                                ),
                              ],
                            ),
                          ),
                          // Volume Control - 显示在单独的行，避免水平溢出
                          if (_showVolumeIndicator)
                            Container(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: SizedBox(
                                width: 150,
                                height: 40,
                                child: Slider(
                                  value: _currentVolume,
                                  min: 0.0,
                                  max: 1.0,
                                  activeColor:
                                      Theme.of(context).colorScheme.primary,
                                  onChanged: (value) {
                                    setState(() {
                                      _currentVolume = value;
                                      musicProvider.setVolume(value);
                                    });
                                  },
                                ),
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
          // Playlist (expandable)
          if (_isExpanded && musicProvider.playlist.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight:
                      MediaQuery.of(context).size.height * 0.3, // 最大高度为屏幕高度的30%
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: ListView.separated(
                  itemCount: musicProvider.playlist.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    thickness: 1,
                    color: Theme.of(context).colorScheme.outlineVariant,
                    indent: 72,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, index) {
                    final song = musicProvider.playlist[index];
                    final isCurrent = index == musicProvider.currentIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      color: isCurrent
                          ? Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.5)
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
                                child: const Icon(Icons.play_arrow,
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
                          song.songName ?? 'Unknown',
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                musicProvider.isSongFavorited(song)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: musicProvider.isSongFavorited(song)
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                                size: 18,
                              ),
                              onPressed: () async {
                                final authProvider = Provider.of<AuthProvider>(
                                    context,
                                    listen: false);
                                if (!authProvider.isAuthenticated) {
                                  // 提示用户登录
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('请先登录')),
                                  );
                                  // 导航到登录页面
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen()),
                                  );
                                  return;
                                }

                                bool success;
                                if (musicProvider.isSongFavorited(song)) {
                                  success = await musicProvider
                                      .removeFromFavorites(song);
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('已取消收藏')),
                                    );
                                  }
                                } else {
                                  success =
                                      await musicProvider.addToFavorites(song);
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('已添加到收藏')),
                                    );
                                  }
                                }
                              },
                              padding: EdgeInsets.zero,
                            ),
                            Text(
                              song.formattedDuration,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          musicProvider.playSong(song);
                        },
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                      ),
                    );
                  },
                ),
              ),
            ),
          // 音量指示器
          if (_showVolumeIndicator)
            Positioned(
              top: 80,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      _currentVolume > 0.5
                          ? Icons.volume_up
                          : _currentVolume > 0
                              ? Icons.volume_down
                              : Icons.volume_off,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_currentVolume * 100).round()}%',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
