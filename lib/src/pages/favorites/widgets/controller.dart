import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vibe_music_app/src/providers/auth_provider.dart';
import 'package:vibe_music_app/src/providers/music_provider.dart';
import 'package:vibe_music_app/src/models/song_model.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';

class FavoritesController extends GetxController {
  // 状态
  var allSongs = <Song>[].obs;
  var currentPage = 1.obs;
  var isLoadingMore = false.obs;
  var hasMoreSongs = true.obs;
  
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
    
    // 添加滚动监听器
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        loadMoreSongs();
      }
    });
    
    // 加载收藏歌曲
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
        )
        .then((newSongs) {
      // 去重处理
      final uniqueNewSongs = removeDuplicateSongs(newSongs);
      
      if (currentPage.value == 1) {
        allSongs.value = uniqueNewSongs;
      } else {
        // 过滤掉已存在的歌曲
        final songsToAdd = uniqueNewSongs
            .where((song) => !allSongs.any((existingSong) => existingSong.id == song.id))
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
      AppLogger().e('Error loading favorite songs: $error', stackTrace: stackTrace);
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
      Get.snackbar('成功', '已取消收藏');
      allSongs.removeAt(index);
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
  
  /// 检查是否已登录
  bool get isAuthenticated {
    return _authProvider.isAuthenticated;
  }
}
