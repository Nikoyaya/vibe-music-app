import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';
import 'package:vibe_music_app/src/utils/sp_util.dart';

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
  ImagePreloadService._internal() {
    _initCacheManager();
    _startCacheCleanupTimer();
  }

  /// 已预加载的图片URL集合，用于避免重复预加载
  final Set<String> _preloadedImages = {};

  /// 图片缓存统计
  final Map<String, int> _imageCacheStats = {};

  /// 图片加载重试次数
  static const int _maxRetryCount = 3;

  /// 图片加载重试延迟（毫秒）
  static const int _retryDelay = 1000;

  /// 最大缓存图片数量
  static const int _maxCacheSize = 200;

  /// 缓存清理阈值（当达到此阈值时开始清理）
  static const int _cacheCleanupThreshold = 150;

  /// 缓存清理定时器
  Timer? _cacheCleanupTimer;

  /// 初始化缓存管理器
  void _initCacheManager() {
    // 从本地存储加载缓存统计信息
    try {
      final cachedStats = SpUtil.get<Map<String, dynamic>>('image_cache_stats');
      if (cachedStats != null) {
        _imageCacheStats.addAll(Map<String, int>.from(cachedStats));
      }
    } catch (e) {
      AppLogger().e('初始化图片缓存管理器失败: $e');
    }

    // 从本地存储加载预加载图片列表
    try {
      final preloadedList = SpUtil.get<List<String>>('preloaded_images');
      if (preloadedList != null) {
        _preloadedImages.addAll(preloadedList);
        AppLogger().d('从本地存储加载预加载图片列表，数量: ${preloadedList.length}');
      }
    } catch (e) {
      AppLogger().e('加载预加载图片列表失败: $e');
    }
  }

  /// 启动缓存清理定时器
  void _startCacheCleanupTimer() {
    // 每5分钟检查一次缓存
    _cacheCleanupTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _cleanupCacheIfNeeded();
    });
  }

  /// 清理缓存（如果需要）
  void _cleanupCacheIfNeeded() {
    if (_preloadedImages.length >= _cacheCleanupThreshold) {
      clearExpiredCache();
    }
  }

  /// 记录图片缓存大小
  void _recordImageCache(String imageUrl, int estimatedSize) {
    _imageCacheStats[imageUrl] = estimatedSize;
    _saveCacheStats();
  }

  /// 保存缓存统计信息到本地存储
  void _saveCacheStats() {
    try {
      SpUtil.put('image_cache_stats', _imageCacheStats);
    } catch (e) {
      AppLogger().e('保存图片缓存统计失败: $e');
    }
  }

  /// 保存预加载图片列表到本地存储
  void _savePreloadedImages() {
    try {
      final preloadedList = _preloadedImages.toList();
      SpUtil.put('preloaded_images', preloadedList);
    } catch (e) {
      AppLogger().e('保存预加载图片列表失败: $e');
    }
  }

  /// 估算图片大小（字节）
  int _estimateImageSize(
      String imageUrl, int width, int height, ImageQualityLevel qualityLevel) {
    // 基于尺寸和质量估算图片大小
    final pixels = width * height;
    final qualityFactor = _getQualityFactor(qualityLevel);
    return (pixels * qualityFactor * 0.003).toInt(); // 估算每个像素的字节数
  }

  /// 获取质量因子
  double _getQualityFactor(ImageQualityLevel qualityLevel) {
    switch (qualityLevel) {
      case ImageQualityLevel.low:
        return 0.3;
      case ImageQualityLevel.medium:
        return 0.6;
      case ImageQualityLevel.high:
        return 1.0;
      default:
        return 0.6;
    }
  }

  /// 检查图片是否已经预加载
  bool _isPreloaded(String imageUrl) {
    return _preloadedImages.contains(imageUrl);
  }

  /// 检查图片是否已经预加载
  /// 公开方法，供外部组件调用
  bool isImagePreloaded(String imageUrl) {
    return _preloadedImages.contains(imageUrl);
  }

  /// 标记图片为已预加载
  void _markAsPreloaded(String imageUrl) {
    _preloadedImages.add(imageUrl);
    _savePreloadedImages();
  }

  /// 清除预加载缓存
  void clearCache() {
    _preloadedImages.clear();
    _savePreloadedImages();
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

      // 估算图片大小并记录
      final estimatedSize = _estimateImageSize(
          imageUrl, finalCacheWidth, finalCacheHeight, qualityLevel);
      _recordImageCache(imageUrl, estimatedSize);

      // 使用 DefaultCacheManager 直接下载图片并缓存到磁盘
      // 这样 CachedNetworkImage 组件就可以在自己的缓存中找到图片
      final file = await DefaultCacheManager().getSingleFile(
        imageUrl,
        headers: {},
      );
      AppLogger().d('图片预加载成功: $imageUrl, 缓存路径: ${file.path}');
      // 只有当图片真正下载成功后，才标记为已预加载
      _markAsPreloaded(imageUrl);
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

      // 使用 DefaultCacheManager 直接下载图片并缓存到磁盘
      final file = await DefaultCacheManager().getSingleFile(
        imageUrl,
        headers: {},
      );
      AppLogger().d('✅ 图片预加载重试成功: $imageUrl, 缓存路径: ${file.path}');
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
    final effectiveMaxSize =
        maxCacheSize > _maxCacheSize ? _maxCacheSize : maxCacheSize;

    if (_preloadedImages.length <= effectiveMaxSize) {
      return;
    }

    // 按缓存大小排序，优先清除大图片
    final entriesList = _imageCacheStats.entries.toList();
    entriesList.sort((a, b) => b.value.compareTo(a.value));
    final sortedImages = entriesList.map((entry) => entry.key).toList();

    // 计算需要清除的图片数量
    final imagesToRemoveCount = _preloadedImages.length - effectiveMaxSize;
    final imagesToRemove = sortedImages.take(imagesToRemoveCount).toList();

    // 执行清理
    for (final imageUrl in imagesToRemove) {
      _preloadedImages.remove(imageUrl);
      _imageCacheStats.remove(imageUrl);
    }

    // 保存更新后的缓存统计
    _saveCacheStats();
    _savePreloadedImages();

    AppLogger().d('✅ 清除过期图片缓存，当前缓存数量: ${_preloadedImages.length}');
  }

  /// 获取缓存状态
  Map<String, dynamic> getCacheStatus() {
    // 计算总缓存大小（估算）
    final totalCacheSize =
        _imageCacheStats.values.fold(0, (sum, size) => sum + size);

    return {
      'cachedImagesCount': _preloadedImages.length,
      'totalCacheSizeBytes': totalCacheSize,
      'totalCacheSizeMB': (totalCacheSize / (1024 * 1024)).toStringAsFixed(2),
      'maxCacheSize': _maxCacheSize,
      'cacheCleanupThreshold': _cacheCleanupThreshold,
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
    double? width,
    double? height,
    Map<String, String>? httpHeaders,
  }) {
    final service = ImagePreloadService();
    final cacheSize = service._getCacheSizeByQuality(qualityLevel);

    // 检查图片是否已经预加载
    final isPreloaded = service.isImagePreloaded(url);

    return CachedNetworkImage(
      key: key,
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      // 如果图片已经预加载，显示一个透明容器
      // 如果图片没有预加载，显示一个默认的占位符
      placeholder: isPreloaded
          ? (context, url) => Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              )
          : placeholder ??
              (context, url) => Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
      errorWidget: errorWidget ??
          (context, url, error) => Container(
                width: width,
                height: height,
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
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
    );
  }
}
