import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vibe_music_app/src/controllers/auth_controller.dart';
import 'package:vibe_music_app/src/controllers/music_controller.dart';
import 'package:vibe_music_app/src/models/song_model.dart';
import 'package:vibe_music_app/src/routes/app_routes.dart';
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
  late AuthController _authController;
  late MusicController _musicController;

  @override
  void onInit() {
    super.onInit();
    _authController = Get.find<AuthController>();
    _musicController = Get.find<MusicController>();

    // 初始设置认证状态
    isAuthenticated.value = _authController.isAuthenticated;

    // 添加滚动监听器
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        loadMoreSongs();
      }
    });

    // 监听认证状态变化
    _authController.addListener(() {
      isAuthenticated.value = _authController.isAuthenticated;
      if (_authController.isAuthenticated) {
        loadFavoriteSongs();
      } else {
        allSongs.clear();
      }
    });

    // 监听收藏状态变化
    _musicController.addListener(() async {
      // 当收藏状态变化时，更新当前页面的收藏歌曲
      if (_authController.isAuthenticated) {
        loadFavoriteSongs();
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
  Future<void> loadFavoriteSongs() async {
    if (_authController.isAuthenticated) {
      currentPage.value = 1;
      allSongs.clear();
      hasMoreSongs.value = true;
      await fetchFavoriteSongs();
    }
  }

  /// 加载更多歌曲
  Future<void> loadMoreSongs() async {
    if (!isLoadingMore.value && hasMoreSongs.value) {
      await fetchFavoriteSongs();
    }
  }

  /// 获取收藏歌曲数据
  Future<void> fetchFavoriteSongs() async {
    if (!_authController.isAuthenticated) return;

    isLoadingMore.value = true;

    try {
      final newSongs = await _musicController.loadUserFavoriteSongs(
        page: currentPage.value,
        size: pageSize,
        forceRefresh:
            currentPage.value == 1 && allSongs.isEmpty, // 仅当第一次加载时强制刷新
      );
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
    } catch (error, stackTrace) {
      AppLogger().e('加载收藏歌曲错误: $error', stackTrace: stackTrace);
      isLoadingMore.value = false;
    }
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
    final success = await _musicController.removeFromFavorites(song);

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
    // 将收藏歌曲添加到播放列表
    for (final s in allSongs) {
      if (!_musicController.playlist.any((item) => item.songUrl == s.songUrl)) {
        await _musicController.addToPlaylist(s);
      }
    }
    // 播放选中的歌曲
    await _musicController.playSong(song);
    Get.toNamed(AppRoutes.player);
  }

  /// 导航到登录页面
  void navigateToLogin() {
    Get.toNamed(AppRoutes.login);
  }

  /// 检查是否已登录（兼容旧代码）
  bool get isAuthenticatedValue {
    return isAuthenticated.value;
  }
}
