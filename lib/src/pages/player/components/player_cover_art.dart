import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 专辑封面组件
/// 用于显示歌曲的专辑封面图片
class PlayerCoverArt extends StatelessWidget {
  /// 封面图片URL
  final String? coverUrl;

  const PlayerCoverArt({
    Key? key,
    required this.coverUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(76), // 使用withAlpha替代withValues
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: coverUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: coverUrl!,
                fit: BoxFit.cover,
                memCacheWidth: 500,
                memCacheHeight: 500,
                maxWidthDiskCache: 500,
                maxHeightDiskCache: 500,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.music_note, size: 100),
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.music_note, size: 100),
            ),
    );
  }
}
