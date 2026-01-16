import 'package:flutter/material.dart';

/// 进度条组件
/// 用于显示和控制歌曲的播放进度
class PlayerProgressBar extends StatelessWidget {
  /// 当前播放位置
  final Duration position;
  /// 歌曲总时长
  final Duration duration;
  /// 拖动进度回调
  final Function(Duration) onSeek;

  const PlayerProgressBar({
    Key? key,
    required this.position,
    required this.duration,
    required this.onSeek,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Slider(
            value: position.inSeconds
                .toDouble()
                .clamp(
                    0.0,
                    duration.inSeconds
                        .toDouble()
                        .clamp(1.0,
                            double.infinity)),
            max: duration.inSeconds
                .toDouble()
                .clamp(1.0, double.infinity),
            onChanged: (value) {
              onSeek(Duration(seconds: value.toInt()));
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(position)),
              Text(_formatDuration(duration)),
            ],
          ),
        ],
      ),
    );
  }

  /// 格式化时长
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}