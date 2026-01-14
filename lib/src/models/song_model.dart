import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';

part 'song_model.freezed.dart';

@freezed
class Song with _$Song {
  const factory Song({
    @JsonKey(name: 'songId') int? id,
    String? songName,
    String? artistName,
    @JsonKey(name: 'album') String? albumName,
    String? coverUrl,
    @JsonKey(name: 'audioUrl') String? songUrl,
    String? duration,
    int? playCount,
    int? likeCount,
    @JsonKey(name: 'releaseTime') DateTime? createTime,
    int? likeStatus,
  }) = _Song;

  factory Song.fromJson(Map<String, dynamic> json) {
    // 处理歌曲基本信息，保留原始空格
    final songName = json['songName']?.toString().trim();
    final artistName = json['artistName']?.toString().trim();

    // 清理封面URL，去除末尾逗号和换行符，但保留URL中的必要编码
    String? cleanCoverUrl = json['coverUrl']
        ?.toString()
        .replaceAll(RegExp(r'[\n\r]+'), '')
        .replaceAll(RegExp(r'[,]+$'), '')
        .trim();

    // 清理音频URL，去除末尾逗号和换行符，但保留URL中的必要编码
    String? audioUrl = json['audioUrl']
        ?.toString()
        .replaceAll(RegExp(r'[\n\r]+'), '')
        .replaceAll(RegExp(r'[,]+$'), '')
        .trim();

    // 对音频URL进行严格处理，确保URL格式正确
    String? processedAudioUrl;
    if (audioUrl != null && audioUrl.isNotEmpty) {
      // 确保URL以http://或https://开头
      if (!audioUrl.startsWith('http://') && !audioUrl.startsWith('https://')) {
        audioUrl = 'http://$audioUrl';
      }

      try {
        // 直接解析URL，不重新编码路径段，保持原始编码
        final uri = Uri.parse(audioUrl);
        processedAudioUrl = uri.toString();

        // 移除URL末尾可能存在的问号
        if (processedAudioUrl.endsWith('?')) {
          processedAudioUrl =
              processedAudioUrl.substring(0, processedAudioUrl.length - 1);
        }

        AppLogger().i('Processed audio URL: $processedAudioUrl');
      } catch (e) {
        AppLogger().e('Error processing audio URL: $e');
        // 如果解析失败，尝试手动修复明显问题
        processedAudioUrl = audioUrl
            .replaceAll(RegExp(r'\s+'), '%20') // 将空格替换为%20
            .replaceAll(RegExp(r'[?]+$'), ''); // 移除末尾问号
      }
    }

    return Song(
      id: json['songId'],
      songName: songName,
      artistName: artistName,
      albumName: json['album']?.toString().trim(),
      coverUrl: cleanCoverUrl,
      songUrl: processedAudioUrl,
      duration: json['duration']?.toString().trim(),
      playCount: json['playCount'],
      likeCount: json['likeCount'],
      createTime: json['releaseTime'] != null
          ? DateTime.parse(json['releaseTime'])
          : null,
      likeStatus: json['likeStatus'],
    );
  }
}

@freezed
class PageResult<T> with _$PageResult<T> {
  const factory PageResult({
    required List<T> records,
    required int total,
    required int size,
    required int current,
    required int pages,
  }) = _PageResult<T>;

  factory PageResult.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return PageResult(
      records:
          (json['records'] as List).map((item) => fromJsonT(item)).toList(),
      total: json['total'],
      size: json['size'],
      current: json['current'],
      pages: json['pages'],
    );
  }
}

@freezed
class SongListResponse with _$SongListResponse {
  const factory SongListResponse({
    required List<Song> songs,
    required int total,
    required int page,
    required int size,
    required int pages,
  }) = _SongListResponse;

  factory SongListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return SongListResponse(
      songs:
          (data['records'] ?? []).map((item) => Song.fromJson(item)).toList(),
      total: data['total'] ?? 0,
      page: data['current'] ?? 1,
      size: data['size'] ?? 10,
      pages: data['pages'] ?? 0,
    );
  }
}
