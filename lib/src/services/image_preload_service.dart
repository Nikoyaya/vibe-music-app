import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// 图片预加载服务
/// 用于预加载图片，提高图片加载速度
class ImagePreloadService {
  /// 单例实例
  static final ImagePreloadService _instance = ImagePreloadService._internal();

  /// 获取单例实例
  factory ImagePreloadService() => _instance;

  /// 私有构造函数
  ImagePreloadService._internal();

  /// 预加载图片列表
  /// [imageUrls]: 图片URL列表
  /// [context]: BuildContext
  Future<void> preloadImages(
      List<String> imageUrls, BuildContext context) async {
    for (final url in imageUrls) {
      try {
        await preloadImage(url, context);
      } catch (e) {
        // 忽略预加载错误，不影响应用运行
        debugPrint('预加载图片失败: $url, 错误: $e');
      }
    }
  }

  /// 预加载单个图片
  /// [imageUrl]: 图片URL
  /// [context]: BuildContext
  Future<void> preloadImage(String imageUrl, BuildContext context) async {
    try {
      // 检查网络状态
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        debugPrint('网络不可用，跳过图片预加载: $imageUrl');
        return;
      }

      await precacheImage(
        CachedNetworkImageProvider(
          imageUrl,
          maxWidth: 300,
          maxHeight: 300,
        ),
        context,
      );
    } catch (e) {
      // 忽略预加载错误，不影响应用运行
      debugPrint('预加载图片失败: $imageUrl, 错误: $e');
    }
  }

  /// 预加载轮播图图片
  /// [carouselItems]: 轮播图数据列表
  /// [context]: BuildContext
  Future<void> preloadCarouselImages(
      List<dynamic> carouselItems, BuildContext context) async {
    final imageUrls =
        carouselItems.map((item) => item.imageUrl as String).toList();
    await preloadImages(imageUrls, context);
  }

  /// 预加载推荐歌单图片
  /// [playlists]: 歌单数据列表
  /// [context]: BuildContext
  Future<void> preloadPlaylistImages(
      List<dynamic> playlists, BuildContext context) async {
    final imageUrls =
        playlists.map((playlist) => playlist.imageUrl as String).toList();
    await preloadImages(imageUrls, context);
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
    await preloadImages(imageUrls, context);
  }
}
