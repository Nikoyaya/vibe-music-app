import 'package:flutter/material.dart';

/// 音量控制组件
/// 用于显示和调整音量大小
class PlayerVolumeControls extends StatelessWidget {
  /// 当前音量
  final double volume;

  /// 音量变化回调
  final Function(double) onVolumeChanged;

  const PlayerVolumeControls({
    Key? key,
    required this.volume,
    required this.onVolumeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8.0),
      child: SizedBox(
        width: 150,
        height: 40,
        child: Slider(
          value: volume,
          min: 0.0,
          max: 1.0,
          activeColor: Theme.of(context).colorScheme.primary,
          onChanged: onVolumeChanged,
        ),
      ),
    );
  }
}
