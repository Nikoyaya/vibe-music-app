import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vibe_music_app/src/providers/music_provider.dart';
import 'package:vibe_music_app/src/providers/auth_provider.dart';
import 'package:vibe_music_app/src/models/song_model.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';

class SearchPageController extends GetxController {
  // 控制器
  final searchController = TextEditingController();
  final scrollController = ScrollController();

  // 状态
  var searchKeyword = ''.obs;
  var isSearching = false.obs;
  var searchResults = <Song>[].obs;
  var currentPage = 1.obs;

  // 常量
  static const int pageSize = 20;

  // 提供者
  late MusicProvider _musicProvider;
  late AuthProvider _authProvider;

  @override
  void onInit() {
    super.onInit();
    _musicProvider = Get.find<MusicProvider>();
    _authProvider = Get.find<AuthProvider>();

    // 监听滚动事件，实现下拉加载更多
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        loadMore();
      }
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  /// 搜索歌曲
  Future<void> searchSongs({bool loadMore = false}) async {
    if (searchKeyword.value.isEmpty) return;

    if (!loadMore) {
      isSearching.value = true;
      searchResults.clear();
      currentPage.value = 1;
    }

    try {
      final songs = await _musicProvider.loadSongs(
        page: currentPage.value,
        size: pageSize,
        songName: searchKeyword.value,
      );

      if (loadMore) {
        searchResults.addAll(songs);
      } else {
        searchResults.value = songs;
      }
    } catch (e, stackTrace) {
      AppLogger().e('搜索歌曲错误: $e', stackTrace: stackTrace);
      Get.snackbar('Error', '搜索失败，请重试');
    } finally {
      isSearching.value = false;
    }
  }

  /// 加载更多
  void loadMore() {
    if (isSearching.value) return;
    currentPage.value++;
    searchSongs(loadMore: true);
  }

  /// 清除搜索
  void clearSearch() {
    searchController.clear();
    searchKeyword.value = '';
    searchResults.clear();
  }

  /// 处理搜索结果点击
  void handleResultTap(Song song) {
    _musicProvider.playSong(song, playlist: searchResults);
    Get.toNamed('/player');
  }

  /// 处理收藏按钮点击
  Future<void> handleFavoriteTap(Song song) async {
    if (!_authProvider.isAuthenticated) {
      Get.snackbar('提示', '请先登录');
      return;
    }

    bool success;
    final isFavorited = _musicProvider.isSongFavorited(song);

    if (isFavorited) {
      success = await _musicProvider.removeFromFavorites(song);
      if (success) {
        Get.snackbar('成功', '已取消收藏');
      }
    } else {
      success = await _musicProvider.addToFavorites(song);
      if (success) {
        Get.snackbar('成功', '已添加到收藏');
      }
    }
  }

  /// 检查歌曲是否已收藏
  bool isSongFavorited(Song song) {
    return _musicProvider.isSongFavorited(song);
  }
}
