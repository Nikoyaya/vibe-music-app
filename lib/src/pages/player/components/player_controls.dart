import 'package:flutter/material.dart';

/// 播放控制按钮组件
/// 用于控制歌曲的播放、暂停、上一首、下一首等操作
class PlayerControls extends StatelessWidget {
  /// 当前播放状态
  final bool isPlaying;
  /// 是否启用随机播放
  final bool isShuffle;
  /// 重复模式
  final String repeatMode;
  /// 当前音量
  final double volume;
  /// 播放回调
  final Function() onPlay;
  /// 暂停回调
  final Function() onPause;
  /// 上一首回调
  final Function() onPrevious;
  /// 下一首回调
  final Function() onNext;
  /// 随机播放切换回调
  final Function() onToggleShuffle;
  /// 重复模式切换回调
  final Function() onToggleRepeat;
  /// 音量控制显示回调
  final Function() onToggleVolumeControls;

  const PlayerControls({
    Key? key,
    required this.isPlaying,
    required this.isShuffle,
    required this.repeatMode,
    required this.volume,
    required this.onPlay,
    required this.onPause,
    required this.onPrevious,
    required this.onNext,
    required this.onToggleShuffle,
    required this.onToggleRepeat,
    required this.onToggleVolumeControls,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 随机播放
          Flexible(
            flex: 1,
            child: IconButton(
              icon: Icon(
                Icons.shuffle,
                size: isSmallScreen ? 20 : 24,
                color: isShuffle
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
              ),
              onPressed: onToggleShuffle,
              padding: const EdgeInsets.all(4),
            ),
          ),
          SizedBox(width: isSmallScreen ? 2 : 4),
          // 上一首
          Flexible(
            flex: 1,
            child: IconButton(
              icon: Icon(Icons.skip_previous, size: isSmallScreen ? 24 : 32),
              onPressed: onPrevious,
              padding: const EdgeInsets.all(4),
            ),
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
          // 播放/暂停
          FloatingActionButton(
            onPressed: isPlaying ? onPause : onPlay,
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              size: isSmallScreen ? 28 : 36,
            ),
            mini: isSmallScreen,
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
          // 下一首
          Flexible(
            flex: 1,
            child: IconButton(
              icon: Icon(Icons.skip_next, size: isSmallScreen ? 24 : 32),
              onPressed: onNext,
              padding: const EdgeInsets.all(4),
            ),
          ),
          SizedBox(width: isSmallScreen ? 2 : 4),
          // 音量控制
          Flexible(
            flex: 1,
            child: IconButton(
              icon: Icon(
                volume > 0.5
                    ? Icons.volume_up
                    : volume > 0
                        ? Icons.volume_down
                        : Icons.volume_off,
                size: isSmallScreen ? 20 : 24,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
              onPressed: onToggleVolumeControls,
              padding: const EdgeInsets.all(4),
            ),
          ),
          SizedBox(width: isSmallScreen ? 2 : 4),
          // 重复模式
          Flexible(
            flex: 1,
            child: IconButton(
              icon: Icon(
                repeatMode == 'one'
                    ? Icons.repeat_one
                    : Icons.repeat,
                size: isSmallScreen ? 20 : 24,
                color: repeatMode != 'none'
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
              ),
              onPressed: onToggleRepeat,
              padding: const EdgeInsets.all(4),
            ),
          ),
        ],
      ),
    );
  }
}