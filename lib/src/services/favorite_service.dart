import 'dart:async';
import 'package:get/get.dart';
import 'package:vibe_music_app/src/models/song_model.dart';
import 'package:vibe_music_app/src/services/api_service.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';

/// 收藏服务
/// 负责处理歌曲收藏的所有操作，包括添加、移除、加载和缓存
class FavoriteService {
  /// 收藏歌曲ID集合
  RxSet<int> _favoriteSongIds = <int>{}.obs; // 本地状态，用于跟踪收藏的歌曲ID

  /// 收藏歌曲列表缓存
  RxList<Song> _favoriteSongsCache = <Song>[].obs;

  /// 缓存时间戳
  DateTime? _favoriteSongsCacheTimestamp;

  /// 收藏操作节流控制
  final _favoriteOperation = false.obs;
  
  /// 收藏操作节流延迟时间
  static const int throttleDelay = 500; // 收藏操作节流延迟时间

  /// 缓存过期时间（分钟）
  static const int CACHE_EXPIRY_MINUTES = 5;
  
  /// 单例实例
  static final FavoriteService _instance = FavoriteService._internal();

  /// 获取单例实例
  factory FavoriteService() => _instance;

  /// 私有构造函数
  FavoriteService._internal();

  /// 获取器
  RxSet<int> get favoriteSongIds => _favoriteSongIds;
  RxList<Song> get favoriteSongsCache => _favoriteSongsCache;

  /// 检查收藏歌曲缓存是否有效
  bool _isFavoriteSongsCacheValid() {
    if (_favoriteSongsCache.isEmpty) return false;
    if (_favoriteSongsCacheTimestamp == null) return false;

    final now = DateTime.now();
    final cacheAge = now.difference(_favoriteSongsCacheTimestamp!);
    return cacheAge.inMinutes < CACHE_EXPIRY_MINUTES;
  }

  /// 更新收藏歌曲缓存
  void _updateFavoriteSongsCache(List<Song> songs) {
    _favoriteSongsCache.assignAll(songs);
    _favoriteSongsCacheTimestamp = DateTime.now();

    // 更新收藏歌曲ID集合
    _favoriteSongIds.clear();
    for (final song in songs) {
      if (song.id != null) {
        _favoriteSongIds.add(song.id!);
      }
    }
  }

  /// 从缓存中移除收藏歌曲
  void _removeSongFromCache(int songId) {
    _favoriteSongsCache.removeWhere((song) => song.id == songId);
    _favoriteSongIds.remove(songId);
  }

  /// 向缓存中添加收藏歌曲
  void _addSongToCache(Song song) {
    if (!_favoriteSongsCache.any((s) => s.id == song.id)) {
      _favoriteSongsCache.insert(0, song);
      if (song.id != null) {
        _favoriteSongIds.add(song.id!);
      }
    }
  }

  /// 检查歌曲是否已收藏
  /// [song] 要检查的歌曲
  bool isSongFavorited(Song song) {
    if (song.id == null) return false;
    return _favoriteSongIds.contains(song.id);
  }

  /// 添加歌曲到收藏
  /// [song] 要添加的歌曲
  Future<bool> addToFavorites(Song song) async {
    if (song.id == null) return false;

    // 节流控制
    if (_favoriteOperation.value) {
      AppLogger().d('收藏操作过于频繁，请稍后再试');
      return false;
    }

    try {
      // 设置操作状态为进行中
      _favoriteOperation.value = true;

      // 调用API添加收藏歌曲
      final response = await ApiService().collectSong(song.id!);
      if (response.statusCode == 200) {
        final data = response.data is Map ? response.data : {};
        if (data['code'] == 200) {
          // 更新本地状态
          _favoriteSongIds.add(song.id!);
          // 更新缓存
          _addSongToCache(song);
          AppLogger().d('✅ 添加歌曲到收藏成功: ${song.songName}');
          return true;
        }
      }
    } catch (e) {
      AppLogger().e('添加歌曲到收藏失败: $e');
    } finally {
      // 延迟重置操作状态
      Future.delayed(Duration(milliseconds: throttleDelay), () {
        _favoriteOperation.value = false;
      });
    }
    return false;
  }

  /// 从收藏中移除歌曲
  /// [song] 要移除的歌曲
  Future<bool> removeFromFavorites(Song song) async {
    if (song.id == null) return false;

    // 节流控制
    if (_favoriteOperation.value) {
      AppLogger().d('取消收藏操作过于频繁，请稍后再试');
      return false;
    }

    try {
      // 设置操作状态为进行中
      _favoriteOperation.value = true;

      // 调用API移除收藏歌曲
      final response = await ApiService().cancelCollectSong(song.id!);
      if (response.statusCode == 200) {
        final data = response.data is Map ? response.data : {};
        if (data['code'] == 200) {
          // 更新本地状态
          _favoriteSongIds.remove(song.id!);
          // 更新缓存
          _removeSongFromCache(song.id!);
          AppLogger().d('✅ 从收藏中移除歌曲成功: ${song.songName}');
          return true;
        }
      }
    } catch (e) {
      AppLogger().e('从收藏中移除歌曲失败: $e');
    } finally {
      // 延迟重置操作状态
      Future.delayed(Duration(milliseconds: throttleDelay), () {
        _favoriteOperation.value = false;
      });
    }
    return false;
  }

  /// 加载用户收藏歌曲
  /// [page] 页码
  /// [size] 每页数量
  /// [forceRefresh] 是否强制刷新（忽略缓存）
  Future<List<Song>> loadUserFavoriteSongs(
      {int page = 1, int size = 20, bool forceRefresh = false}) async {
    // 检查缓存是否有效（仅当page=1时使用缓存）
    if (page == 1 && !forceRefresh && _isFavoriteSongsCacheValid()) {
      AppLogger().d('使用缓存的收藏歌曲列表');
      return _favoriteSongsCache.toList();
    }

    try {
      final response = await ApiService().getUserFavoriteSongs(page, size);
      if (response.statusCode == 200) {
        final data = response.data is Map ? response.data : {};
        if (data['code'] == 200 && data['data'] != null) {
          final List<dynamic> items = data['data']['items'] ?? [];
          final songs = items.map((item) => Song.fromJson(item)).toList();

          // 如果是第一页，更新缓存
          if (page == 1) {
            _updateFavoriteSongsCache(songs);
          }

          AppLogger().d('✅ 加载用户收藏歌曲成功，共 ${songs.length} 首');
          return songs;
        }
      }
    } catch (e) {
      AppLogger().e('加载用户收藏歌曲失败: $e');
    }
    return [];
  }

  /// 清除收藏缓存
  void clearCache() {
    _favoriteSongsCache.clear();
    _favoriteSongsCacheTimestamp = null;
    AppLogger().d('✅ 清除收藏缓存成功');
  }

  /// 刷新收藏列表
  /// 强制重新加载收藏歌曲列表
  Future<List<Song>> refreshFavorites() async {
    return await loadUserFavoriteSongs(page: 1, forceRefresh: true);
  }

  /// 获取收藏歌曲数量
  int get favoriteCount => _favoriteSongIds.length;

  /// 检查是否有收藏歌曲
  bool get hasFavorites => _favoriteSongIds.isNotEmpty;
}
