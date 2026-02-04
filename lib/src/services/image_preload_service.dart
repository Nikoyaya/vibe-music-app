import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';

/// 图片加载质量级别
enum ImageQualityLevel {
  low, // 低质量，用于列表和缩略图
  medium, // 中等质量，用于卡片和小部件
  high, // 高质量，用于详情页和全屏展示
}

/// 图片预加载服务
/// 用于预加载图片，提高图片加载速度和用户体验
class ImagePreloadService {
  /// 单例实例
  static final ImagePreloadService _instance = ImagePreloadService._internal();

  /// 获取单例实例
  factory ImagePreloadService() => _instance;

  /// 私有构造函数
  ImagePreloadService._internal();

  /// 已预加载的图片URL集合，用于避免重复预加载
  final Set<String> _preloadedImages = {};

  /// 图片加载重试次数
  static const int _maxRetryCount = 3;

  /// 图片加载重试延迟（毫秒）
  static const int _retryDelay = 1000;

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
    AppLogger().d('✅ 清除图片预加载缓存');
  }

  /// 根据质量级别获取缓存尺寸
  /// [qualityLevel]: 图片质量级别
  Map<String, int> _getCacheSizeByQuality(ImageQualityLevel qualityLevel) {
    switch (qualityLevel) {
      case ImageQualityLevel.low:
        return {'width': 120, 'height': 120};
      case ImageQualityLevel.medium:
        return {'width': 300, 'height': 300};
      case ImageQualityLevel.high:
        return {'width': 800, 'height': 800};
      default:
        return {'width': 300, 'height': 300};
    }
  }

  /// 预加载单个图片
  /// [imageUrl]: 图片URL
  /// [context]: BuildContext
  /// [cacheWidth]: 缓存宽度
  /// [cacheHeight]: 缓存高度
  /// [qualityLevel]: 图片质量级别
  Future<void> preloadImage(String imageUrl, BuildContext context,
      {int? cacheWidth,
      int? cacheHeight,
      ImageQualityLevel qualityLevel = ImageQualityLevel.medium}) async {
    try {
      // 检查网络状态
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        AppLogger().d('网络不可用，跳过图片预加载: $imageUrl');
        return;
      }

      // 根据质量级别设置缓存尺寸
      final cacheSize = _getCacheSizeByQuality(qualityLevel);
      final finalCacheWidth = cacheWidth ?? cacheSize['width']!;
      final finalCacheHeight = cacheHeight ?? cacheSize['height']!;

      // 使用 WidgetsBinding 确保在正确的时机使用 context
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          precacheImage(
            CachedNetworkImageProvider(
              imageUrl,
              maxWidth: finalCacheWidth,
              maxHeight: finalCacheHeight,
            ),
            context,
            onError: (exception, stackTrace) {
              AppLogger().e('图片预加载失败: $imageUrl, 错误: $exception');
              // 尝试重试加载
              _retryPreloadImage(
                  imageUrl, context, finalCacheWidth, finalCacheHeight);
            },
          );
        }
      });
    } catch (e) {
      // 忽略预加载错误，不影响应用运行
      AppLogger().e('预加载图片失败: $imageUrl, 错误: $e');
    }
  }

  /// 重试预加载图片
  Future<void> _retryPreloadImage(
      String imageUrl, BuildContext context, int cacheWidth, int cacheHeight,
      [int retryCount = 0]) async {
    if (retryCount >= _maxRetryCount) {
      AppLogger().e('图片预加载重试失败，已达到最大重试次数: $imageUrl');
      return;
    }

    try {
      // 延迟后重试
      await Future.delayed(Duration(milliseconds: _retryDelay));

      if (context.mounted) {
        await precacheImage(
          CachedNetworkImageProvider(
            imageUrl,
            maxWidth: cacheWidth,
            maxHeight: cacheHeight,
          ),
          context,
        );
        AppLogger().d('✅ 图片预加载重试成功: $imageUrl');
      }
    } catch (e) {
      AppLogger().e('图片预加载重试失败 ($retryCount): $imageUrl, 错误: $e');
      // 递归重试
      _retryPreloadImage(
          imageUrl, context, cacheWidth, cacheHeight, retryCount + 1);
    }
  }

  /// 根据质量级别获取图片质量
  int _getImageQuality(ImageQualityLevel qualityLevel) {
    switch (qualityLevel) {
      case ImageQualityLevel.low:
        return 70;
      case ImageQualityLevel.medium:
        return 85;
      case ImageQualityLevel.high:
        return 100;
      default:
        return 85;
    }
  }

  /// 批量预加载图片
  /// [imageUrls]: 图片URL列表
  /// [context]: BuildContext
  /// [cacheWidth]: 缓存宽度
  /// [cacheHeight]: 缓存高度
  /// [qualityLevel]: 图片质量级别
  /// [concurrencyLimit]: 并发加载限制
  Future<void> preloadImages(List<String> imageUrls, BuildContext context,
      {int? cacheWidth,
      int? cacheHeight,
      ImageQualityLevel qualityLevel = ImageQualityLevel.medium,
      int concurrencyLimit = 3}) async {
    // 过滤掉已经预加载过的图片
    final newImageUrls = imageUrls.where((url) => !_isPreloaded(url)).toList();

    if (newImageUrls.isEmpty) {
      AppLogger().d('所有图片已预加载，跳过');
      return;
    }

    AppLogger().d('开始预加载 ${newImageUrls.length} 张图片');

    // 分批并发预加载
    final batches = <List<String>>[];
    for (var i = 0; i < newImageUrls.length; i += concurrencyLimit) {
      final end = i + concurrencyLimit;
      batches.add(newImageUrls.sublist(
          i, end > newImageUrls.length ? newImageUrls.length : end));
    }

    for (final batch in batches) {
      final futures = batch.map((url) async {
        try {
          await preloadImage(url, context,
              cacheWidth: cacheWidth,
              cacheHeight: cacheHeight,
              qualityLevel: qualityLevel);
          _markAsPreloaded(url);
        } catch (e) {
          // 忽略预加载错误，不影响应用运行
          AppLogger().e('预加载图片失败: $url, 错误: $e');
        }
      }).toList();

      await Future.wait(futures);
    }

    AppLogger().d('✅ 完成预加载 ${newImageUrls.length} 张图片');
  }

  /// 预加载轮播图图片
  /// [carouselItems]: 轮播图数据列表
  /// [context]: BuildContext
  Future<void> preloadCarouselImages(
      List<dynamic> carouselItems, BuildContext context) async {
    final imageUrls =
        carouselItems.map((item) => item.imageUrl as String).toList();
    // 轮播图图片尺寸较大，设置更高的质量
    await preloadImages(imageUrls, context,
        cacheWidth: 800,
        cacheHeight: 400,
        qualityLevel: ImageQualityLevel.high,
        concurrencyLimit: 2);
  }

  /// 预加载推荐歌单图片
  /// [playlists]: 歌单数据列表
  /// [context]: BuildContext
  Future<void> preloadPlaylistImages(
      List<dynamic> playlists, BuildContext context) async {
    final imageUrls =
        playlists.map((playlist) => playlist.imageUrl as String).toList();
    // 推荐歌单图片尺寸适中，使用中等质量
    await preloadImages(imageUrls, context,
        cacheWidth: 300,
        cacheHeight: 300,
        qualityLevel: ImageQualityLevel.medium);
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
    // 歌曲封面图片尺寸较小，使用低质量以提高加载速度
    await preloadImages(imageUrls, context,
        cacheWidth: 120,
        cacheHeight: 120,
        qualityLevel: ImageQualityLevel.low,
        concurrencyLimit: 5);
  }

  /// 清除过期的预加载缓存
  /// [maxCacheSize]: 最大缓存数量
  void clearExpiredCache({int maxCacheSize = 100}) {
    if (_preloadedImages.length <= maxCacheSize) {
      return;
    }

    // 清除一半的缓存，保留最新的
    final imagesToRemove =
        _preloadedImages.take(_preloadedImages.length ~/ 2).toList();
    for (final imageUrl in imagesToRemove) {
      _preloadedImages.remove(imageUrl);
    }

    AppLogger().d('✅ 清除过期图片缓存，当前缓存数量: ${_preloadedImages.length}');
  }

  /// 获取缓存状态
  Map<String, dynamic> getCacheStatus() {
    return {
      'cachedImagesCount': _preloadedImages.length,
      'maxCacheSize': 100,
    };
  }
}

/// 图片加载工具类
/// 提供统一的图片加载配置和工具方法
class ImageLoader {
  /// 获取CachedNetworkImage的默认配置
  static CachedNetworkImageProvider getImageProvider(
    String url, {
    ImageQualityLevel qualityLevel = ImageQualityLevel.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    final service = ImagePreloadService();
    final cacheSize = service._getCacheSizeByQuality(qualityLevel);

    return CachedNetworkImageProvider(
      url,
      maxWidth: cacheWidth ?? cacheSize['width']!,
      maxHeight: cacheHeight ?? cacheSize['height']!,
      errorListener: (exception) {
        AppLogger().e('图片加载失败: $url, 错误: $exception');
      },
    );
  }

  /// 构建CachedNetworkImage组件
  static Widget buildCachedNetworkImage(
    String url, {
    Key? key,
    BoxFit fit = BoxFit.cover,
    ImageQualityLevel qualityLevel = ImageQualityLevel.medium,
    Widget Function(BuildContext, String)? placeholder,
    Widget Function(BuildContext, String, dynamic)? errorWidget,
    int? cacheWidth,
    int? cacheHeight,
    Map<String, String>? httpHeaders,
  }) {
    final service = ImagePreloadService();
    final cacheSize = service._getCacheSizeByQuality(qualityLevel);

    return CachedNetworkImage(
      key: key,
      imageUrl: url,
      fit: fit,
      placeholder: placeholder ??
          (context, url) => Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
      errorWidget: errorWidget ??
          (context, url, error) => Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: const Center(
                  child: Icon(Icons.image_not_supported, size: 48),
                ),
              ),
      httpHeaders: httpHeaders,
      memCacheWidth: cacheWidth ?? cacheSize['width']!,
      memCacheHeight: cacheHeight ?? cacheSize['height']!,
      maxWidthDiskCache: cacheWidth ?? cacheSize['width']!,
      maxHeightDiskCache: cacheHeight ?? cacheSize['height']!,
    );
  }
}
