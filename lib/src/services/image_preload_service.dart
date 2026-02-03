import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';

/// 图片预加载服务
/// 用于预加载图片，提高图片加载速度
class ImagePreloadService {
  /// 单例实例
  static final ImagePreloadService _instance = ImagePreloadService._internal();

  /// 获取单例实例
  factory ImagePreloadService() => _instance;

  /// 私有构造函数
  ImagePreloadService._internal();

  /// 已预加载的图片URL集合，用于避免重复预加载
  final Set<String> _preloadedImages = {};

  /// 检查图片是否已经预加载
  bool _isPreloaded(String imageUrl) {
    return _preloadedImages.contains(imageUrl);
  }

  /// 标记图片为已预加载
  void _markAsPreloaded(String imageUrl) {
    _preloadedImages.add(imageUrl);
  }

  /// 清除预加载缓存
  void clearCache() {
    _preloadedImages.clear();
  }

  /// 预加载单个图片
  /// [imageUrl]: 图片URL
  /// [context]: BuildContext
  /// [cacheWidth]: 缓存宽度
  /// [cacheHeight]: 缓存高度
  Future<void> preloadImage(String imageUrl, BuildContext context,
      {int cacheWidth = 300, int cacheHeight = 300}) async {
    try {
      // 检查网络状态
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        AppLogger().d('网络不可用，跳过图片预加载: $imageUrl');
        return;
      }

      await precacheImage(
        CachedNetworkImageProvider(
          imageUrl,
          maxWidth: cacheWidth,
          maxHeight: cacheHeight,
        ),
        context,
      );
    } catch (e) {
      // 忽略预加载错误，不影响应用运行
      AppLogger().e('预加载图片失败: $imageUrl, 错误: $e');
    }
  }

  /// 预加载图片列表
  /// [imageUrls]: 图片URL列表
  /// [context]: BuildContext
  /// [cacheWidth]: 缓存宽度
  /// [cacheHeight]: 缓存高度
  Future<void> preloadImages(List<String> imageUrls, BuildContext context,
      {int cacheWidth = 300, int cacheHeight = 300}) async {
    // 过滤掉已经预加载过的图片
    final newImageUrls = imageUrls.where((url) => !_isPreloaded(url)).toList();

    if (newImageUrls.isEmpty) {
      AppLogger().d('所有图片已预加载，跳过');
      return;
    }

    AppLogger().d('开始预加载 ${newImageUrls.length} 张图片');

    for (final url in newImageUrls) {
      try {
        await preloadImage(url, context,
            cacheWidth: cacheWidth, cacheHeight: cacheHeight);
        _markAsPreloaded(url);
      } catch (e) {
        // 忽略预加载错误，不影响应用运行
        AppLogger().e('预加载图片失败: $url, 错误: $e');
      }
    }
  }

  /// 预加载轮播图图片
  /// [carouselItems]: 轮播图数据列表
  /// [context]: BuildContext
  Future<void> preloadCarouselImages(
      List<dynamic> carouselItems, BuildContext context) async {
    final imageUrls =
        carouselItems.map((item) => item.imageUrl as String).toList();
    // 轮播图图片尺寸较大，设置更大的缓存尺寸
    await preloadImages(imageUrls, context, cacheWidth: 800, cacheHeight: 400);
  }

  /// 预加载推荐歌单图片
  /// [playlists]: 歌单数据列表
  /// [context]: BuildContext
  Future<void> preloadPlaylistImages(
      List<dynamic> playlists, BuildContext context) async {
    final imageUrls =
        playlists.map((playlist) => playlist.imageUrl as String).toList();
    // 推荐歌单图片尺寸适中，使用适中的缓存尺寸
    await preloadImages(imageUrls, context, cacheWidth: 300, cacheHeight: 300);
  }

  /// 预加载歌曲封面图片
  /// [songs]: 歌曲数据列表
  /// [context]: BuildContext
  Future<void> preloadSongCovers(
      List<dynamic> songs, BuildContext context) async {
    final imageUrls = songs
        .where((song) => song.coverUrl != null && song.coverUrl is String)
        .map((song) => song.coverUrl as String)
        .toList();
    // 歌曲封面图片尺寸较小，使用较小的缓存尺寸
    await preloadImages(imageUrls, context, cacheWidth: 120, cacheHeight: 120);
  }
}
