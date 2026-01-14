import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';

part 'song_model.freezed.dart';

/// 歌曲模型类
/// 用于表示音乐信息，包括基本属性和URL处理
@freezed
class Song with _$Song {
  /// 歌曲构造函数
  /// [参数说明]:
  /// - [id]: 歌曲ID
  /// - [songName]: 歌曲名称
  /// - [artistName]: 歌手名称
  /// - [albumName]: 专辑名称
  /// - [coverUrl]: 封面图片URL
  /// - [songUrl]: 音频文件URL
  /// - [duration]: 歌曲时长
  /// - [playCount]: 播放次数
  /// - [likeCount]: 点赞次数
  /// - [createTime]: 创建/发布时间
  /// - [likeStatus]: 点赞状态(0:未点赞, 1:已点赞)
  const factory Song({
    int? id,
    String? songName,
    String? artistName,
    String? albumName,
    String? coverUrl,
    String? songUrl,
    String? duration,
    int? playCount,
    int? likeCount,
    DateTime? createTime,
    int? likeStatus,
  }) = _Song;

  /// 从JSON字符串解析为Song对象
  /// [json]: JSON格式的歌曲数据
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

        AppLogger().i('处理后的音频URL: $processedAudioUrl');
      } catch (e) {
        AppLogger().e('处理音频URL失败: $e');
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

/// 分页结果模型类
/// 用于封装API返回的分页数据
@freezed
class PageResult<T> with _$PageResult<T> {
  /// 分页结果构造函数
  /// [参数说明]:
  /// - [records]: 数据列表
  /// - [total]: 总记录数
  /// - [size]: 每页大小
  /// - [current]: 当前页码
  /// - [pages]: 总页数
  const factory PageResult({
    required List<T> records,
    required int total,
    required int size,
    required int current,
    required int pages,
  }) = _PageResult<T>;

  /// 从JSON字符串解析为PageResult对象
  /// [json]: JSON格式的分页数据
  /// [fromJsonT]: 转换内部数据类型的函数
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

/// 歌曲列表响应模型类
/// 用于封装歌曲列表的API响应数据
@freezed
class SongListResponse with _$SongListResponse {
  /// 歌曲列表响应构造函数
  /// [参数说明]:
  /// - [songs]: 歌曲列表
  /// - [total]: 总歌曲数
  /// - [page]: 当前页码
  /// - [size]: 每页大小
  /// - [pages]: 总页数
  const factory SongListResponse({
    required List<Song> songs,
    required int total,
    required int page,
    required int size,
    required int pages,
  }) = _SongListResponse;

  /// 从JSON字符串解析为SongListResponse对象
  /// [json]: JSON格式的歌曲列表响应数据
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
