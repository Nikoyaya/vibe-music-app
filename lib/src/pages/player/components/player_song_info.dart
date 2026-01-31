import 'package:flutter/material.dart';
import 'package:vibe_music_app/generated/app_localizations.dart';

/// 歌曲信息组件
/// 用于显示歌曲的名称和艺术家信息
class PlayerSongInfo extends StatelessWidget {
  /// 歌曲名称
  final String? songName;

  /// 艺术家名称
  final String? artistName;

  const PlayerSongInfo({
    Key? key,
    required this.songName,
    required this.artistName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          songName ?? (AppLocalizations.of(context)?.unknownSong ?? '未知歌曲'),
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          artistName ??
              (AppLocalizations.of(context)?.unknownArtist ?? '未知艺术家'),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
