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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 随机播放
          IconButton(
            icon: Icon(
              Icons.shuffle,
              color: isShuffle
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
            ),
            onPressed: onToggleShuffle,
          ),
          const SizedBox(width: 4),
          // 上一首
          IconButton(
            icon: Icon(Icons.skip_previous, size: 32),
            onPressed: onPrevious,
          ),
          const SizedBox(width: 12),
          // 播放/暂停
          FloatingActionButton(
            onPressed: isPlaying ? onPause : onPlay,
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              size: 36,
            ),
          ),
          const SizedBox(width: 12),
          // 下一首
          IconButton(
            icon: Icon(Icons.skip_next, size: 32),
            onPressed: onNext,
          ),
          const SizedBox(width: 4),
          // 音量控制
          IconButton(
            icon: Icon(
              volume > 0.5
                  ? Icons.volume_up
                  : volume > 0
                      ? Icons.volume_down
                      : Icons.volume_off,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
            onPressed: onToggleVolumeControls,
          ),
          const SizedBox(width: 4),
          // 重复模式
          IconButton(
            icon: Icon(
              repeatMode == 'one'
                  ? Icons.repeat_one
                  : Icons.repeat,
              color: repeatMode != 'none'
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
            ),
            onPressed: onToggleRepeat,
          ),
        ],
      ),
    );
  }
}