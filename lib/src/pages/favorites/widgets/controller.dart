import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vibe_music_app/src/providers/auth_provider.dart';
import 'package:vibe_music_app/src/providers/music_provider.dart';
import 'package:vibe_music_app/src/models/song_model.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';
import 'package:vibe_music_app/src/utils/snackbar_manager.dart';

class FavoritesController extends GetxController {
  // 状态
  var allSongs = <Song>[].obs;
  var currentPage = 1.obs;
  var isLoadingMore = false.obs;
  var hasMoreSongs = true.obs;
  var isAuthenticated = false.obs; // 可观察的认证状态

  // 常量
  static const int pageSize = 20;

  // 控制器
  final scrollController = ScrollController();

  // 提供者
  late AuthProvider _authProvider;
  late MusicProvider _musicProvider;

  @override
  void onInit() {
    super.onInit();
    _authProvider = Get.find<AuthProvider>();
    _musicProvider = Get.find<MusicProvider>();

    // 初始设置认证状态
    isAuthenticated.value = _authProvider.isAuthenticated;

    // 添加滚动监听器
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        loadMoreSongs();
      }
    });

    // 监听认证状态变化
    _authProvider.addListener(() {
      isAuthenticated.value = _authProvider.isAuthenticated;
      if (_authProvider.isAuthenticated) {
        loadFavoriteSongs();
      } else {
        // 未认证时清空数据
        allSongs.clear();
      }
    });

    // 监听收藏状态变化
    _musicProvider.addListener(() {
      // 当收藏状态变化时，更新收藏页数据
      if (_authProvider.isAuthenticated) {
        // 从MusicProvider获取最新的收藏歌曲缓存
        _musicProvider.loadUserFavoriteSongs(forceRefresh: false).then((songs) {
          if (songs.isNotEmpty) {
            // 去重处理
            final uniqueSongs = removeDuplicateSongs(songs);
            allSongs.value = uniqueSongs;
          }
        }).catchError((error) {
          AppLogger().e('更新收藏歌曲列表失败: $error');
        });
      }
    });

    // 初始加载收藏歌曲
    loadFavoriteSongs();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  /// 加载收藏歌曲
  void loadFavoriteSongs() {
    if (_authProvider.isAuthenticated) {
      currentPage.value = 1;
      allSongs.clear();
      hasMoreSongs.value = true;
      fetchFavoriteSongs();
    }
  }

  /// 加载更多歌曲
  void loadMoreSongs() {
    if (!isLoadingMore.value && hasMoreSongs.value) {
      fetchFavoriteSongs();
    }
  }

  /// 获取收藏歌曲数据
  void fetchFavoriteSongs() {
    if (!_authProvider.isAuthenticated) return;

    isLoadingMore.value = true;

    _musicProvider
        .loadUserFavoriteSongs(
      page: currentPage.value,
      size: pageSize,
      forceRefresh: currentPage.value == 1 && allSongs.isEmpty, // 仅当第一次加载时强制刷新
    )
        .then((newSongs) {
      // 去重处理
      final uniqueNewSongs = removeDuplicateSongs(newSongs);

      if (currentPage.value == 1) {
        allSongs.value = uniqueNewSongs;
      } else {
        // 过滤掉已存在的歌曲
        final songsToAdd = uniqueNewSongs
            .where((song) =>
                !allSongs.any((existingSong) => existingSong.id == song.id))
            .toList();
        allSongs.addAll(songsToAdd);
      }

      // 检查是否还有更多歌曲
      if (newSongs.length < pageSize) {
        hasMoreSongs.value = false;
      } else {
        currentPage.value++;
      }

      isLoadingMore.value = false;
    }).catchError((error, stackTrace) {
      AppLogger().e('加载收藏歌曲错误: $error', stackTrace: stackTrace);
      isLoadingMore.value = false;
    });
  }

  /// 移除重复歌曲
  List<Song> removeDuplicateSongs(List<Song> songs) {
    final seenIds = <int>{};
    return songs.where((song) {
      if (song.id == null) return true;
      final contains = seenIds.contains(song.id);
      seenIds.add(song.id!);
      return !contains;
    }).toList();
  }

  /// 处理取消收藏
  Future<void> handleRemoveFromFavorites(int index) async {
    final song = allSongs[index];
    final success = await _musicProvider.removeFromFavorites(song);

    if (success) {
      SnackbarManager().showSnackbar(
        title: '成功',
        message: '已取消收藏',
      );
      // 从列表中移除歌曲
      allSongs.removeAt(index);
      // 确保列表中没有重复歌曲
      allSongs.value = removeDuplicateSongs(allSongs);
    }
  }

  /// 处理歌曲点击
  Future<void> handleSongTap(int index) async {
    final song = allSongs[index];
    await _musicProvider.playSong(song, playlist: allSongs);
    Get.toNamed('/player');
  }

  /// 导航到登录页面
  void navigateToLogin() {
    Get.toNamed('/login');
  }

  /// 检查是否已登录（兼容旧代码）
  bool get isAuthenticatedValue {
    return isAuthenticated.value;
  }

  /// 更新收藏歌曲列表
  void _updateFavoritesList() {
    // 从MusicProvider获取最新的收藏歌曲缓存
    // 注意：这里我们需要确保MusicProvider暴露了收藏歌曲缓存
    // 由于我们没有直接访问权限，我们重新加载数据但使用缓存
    _musicProvider.loadUserFavoriteSongs(forceRefresh: false).then((songs) {
      if (songs.isNotEmpty) {
        // 去重处理
        final uniqueSongs = removeDuplicateSongs(songs);
        allSongs.value = uniqueSongs;
      }
    }).catchError((error) {
      AppLogger().e('更新收藏歌曲列表失败: $error');
    });
  }
}
