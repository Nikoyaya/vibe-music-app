import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:vibe_music_app/src/services/api_service.dart';
import 'package:vibe_music_app/src/models/song_model.dart';
import 'package:vibe_music_app/src/models/enums.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';
import 'package:vibe_music_app/src/services/audio_player_service.dart';
import 'package:vibe_music_app/src/services/playlist_manager.dart';
import 'package:vibe_music_app/src/services/favorite_service.dart';

/// 音乐控制器类 - 作为各服务的协调者
/// 管理音频播放、播放列表和收藏歌曲等功能
class MusicController extends GetxController {
  // 音频播放器服务实例
  final AudioPlayerService _audioPlayerService = AudioPlayerService();
  // 播放列表管理服务实例
  final PlaylistManager _playlistManager = PlaylistManager();
  // 收藏歌曲服务实例
  final FavoriteService _favoriteService = FavoriteService();

  // 推荐歌曲缓存
  List<Song> _recommendedSongsCache = [];
  DateTime? _recommendedSongsCacheTimestamp;
  static const Duration _recommendedCacheExpiry = Duration(minutes: 30);

  // 获取器
  AppPlayerState get playerState => _audioPlayerService.playerState;
  Duration get duration => _audioPlayerService.duration;
  Duration get position => _audioPlayerService.position;
  List<Song> get playlist => _playlistManager.playlist;
  int get currentIndex => _playlistManager.currentIndex;
  Song? get currentSong => _playlistManager.currentSong;
  bool get isShuffle => _playlistManager.isShuffle;
  RepeatMode get repeatMode => _playlistManager.repeatMode;
  double get volume => _audioPlayerService.volume;
  RxSet<int> get favoriteSongIds => _favoriteService.favoriteSongIds;

  // 流获取器
  Stream<Duration> get positionStream => _audioPlayerService.positionStream;
  Stream<Duration> get durationStream => _audioPlayerService.durationStream;
  Stream<AppPlayerState> get playerStateStream =>
      _audioPlayerService.playerStateStream;
  Stream<double> get volumeStream => _audioPlayerService.volumeStream;

  /// 构造函数
  MusicController() {
    // 异步初始化音频播放器和加载播放状态
    _initialize();
  }

  /// 初始化方法
  /// 初始化所有服务并加载播放状态
  Future<void> _initialize() async {
    try {
      AppLogger().d('🔄 开始初始化 MusicController');

      // 初始化音频播放器服务
      await _audioPlayerService.initialize();

      // 加载播放列表
      await _playlistManager.loadPlaylist();

      // 加载收藏歌曲
      await _favoriteService.loadUserFavoriteSongs();

      // 恢复播放状态
      await _restorePlayState();

      AppLogger().d('✅ MusicController 初始化完成');
    } catch (e) {
      AppLogger().e('❌ MusicController 初始化失败: $e');
      // 即使初始化失败，也要确保应用能够正常启动
    }
  }

  /// 恢复播放状态
  /// 从存储中加载上次播放的歌曲和位置
  Future<void> _restorePlayState() async {
    try {
      // 加载最后播放的歌曲
      final lastPlayedSong = await _playlistManager.loadLastPlayedSong();
      if (lastPlayedSong == null) return;

      // 加载播放列表
      final playlist = _playlistManager.playlist;
      if (playlist.isEmpty) return;

      // 查找歌曲索引
      final index = _playlistManager.findSongIndex(lastPlayedSong, playlist);
      if (index >= 0) {
        _playlistManager.currentIndex = index;
        AppLogger().d('✅ 恢复播放状态，最后播放的歌曲: ${lastPlayedSong.songName}');

        // 准备音频播放器
        await _audioPlayerService.preparePlayer(lastPlayedSong);

        // 通知 UI 更新
        update();
      }
    } catch (e) {
      AppLogger().e('❌ 恢复播放状态失败: $e');
    }
  }

  /// 播放指定歌曲
  /// [song] 要播放的歌曲
  /// [playlist] 可选的播放列表
  Future<void> playSong(Song song, {List<Song>? playlist}) async {
    try {
      AppLogger().d('🎵 开始播放歌曲: ${song.songName}');

      // 如果提供了新的播放列表
      if (playlist != null) {
        await _playlistManager.updatePlaylist(playlist);
        await _playlistManager.setCurrentSong(song);
      } else if (_playlistManager.playlist.isNotEmpty) {
        // 如果没有提供新的播放列表，就在当前播放列表中查找选中的歌曲
        await _playlistManager.setCurrentSong(song);
      }

      // 立即更新UI，确保显示正确的歌曲信息
      update();

      // 播放歌曲
      await _audioPlayerService.playSong(song);

      // 保存播放历史
      await _playlistManager.savePlayHistory(song);

      AppLogger().d('✅ 歌曲播放成功: ${song.songName}');
    } catch (e, stackTrace) {
      AppLogger().e('播放歌曲 ${song.songName} 失败: $e');
      AppLogger().e('堆栈跟踪: $stackTrace');
      update();
    }
  }

  /// 播放当前歌曲
  Future<void> play() async {
    try {
      if (currentSong == null) {
        AppLogger().e('错误: 没有当前歌曲');
        return;
      }

      await _audioPlayerService.play();
      AppLogger().d('▶️ 播放当前歌曲: ${currentSong!.songName}');
      update();
    } catch (e) {
      AppLogger().e('播放歌曲失败: $e');
      update();
    }
  }

  /// 暂停当前歌曲
  Future<void> pause() async {
    try {
      await _audioPlayerService.pause();
      AppLogger().d('⏸️ 暂停当前歌曲');

      // 保存播放状态
      if (currentSong != null) {
        await _playlistManager.savePlayHistory(currentSong!);
      }

      update();
    } catch (e) {
      AppLogger().e('暂停播放失败: $e');
    }
  }

  /// 停止播放
  Future<void> stop() async {
    try {
      await _audioPlayerService.stop();
      AppLogger().d('⏹️ 停止播放');
      update();
    } catch (e) {
      AppLogger().e('停止播放失败: $e');
    }
  }

  /// 跳转到指定位置
  /// [position] 要跳转到的位置
  Future<void> seekTo(Duration position) async {
    try {
      await _audioPlayerService.seekTo(position);
      AppLogger().d('⏩ 跳转到位置: $position');
    } catch (e) {
      AppLogger().e('跳转播放位置失败: $e');
    }
  }

  /// 播放下一首歌曲
  Future<void> next() async {
    try {
      final nextSong = _playlistManager.getNextSong();
      if (nextSong != null) {
        await playSong(nextSong);
      }
    } catch (e) {
      AppLogger().e('播放下一首歌曲失败: $e');
    }
  }

  /// 播放上一首歌曲
  Future<void> previous() async {
    try {
      final previousSong = _playlistManager.getPreviousSong();
      if (previousSong != null) {
        await playSong(previousSong);
      }
    } catch (e) {
      AppLogger().e('播放上一首歌曲失败: $e');
    }
  }

  /// 切换随机播放模式
  void toggleShuffle() {
    _playlistManager.toggleShuffle();
    AppLogger().d('🔀 切换随机播放模式: ${_playlistManager.isShuffle}');
    update();
  }

  /// 切换重复模式
  void toggleRepeat() {
    _playlistManager.toggleRepeat();
    AppLogger().d('🔁 切换重复模式: ${_playlistManager.repeatMode}');
    update();
  }

  /// 设置音量
  /// [volume] 音量大小（0.0-1.0）
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayerService.setVolume(volume);
      AppLogger().d('🔊 设置音量: $volume');
      update();
    } catch (e) {
      AppLogger().e('设置音量失败: $e');
    }
  }

  /// 添加歌曲到播放列表
  /// [song] 要添加的歌曲
  Future<void> addToPlaylist(Song song) async {
    try {
      await _playlistManager.addToPlaylist(song);
      AppLogger().d('➕ 添加歌曲到播放列表: ${song.songName}');
      update();
    } catch (e) {
      AppLogger().e('添加歌曲到播放列表失败: $e');
    }
  }

  /// 从播放列表移除歌曲
  /// [index] 要移除的歌曲索引
  Future<void> removeFromPlaylist(int index) async {
    try {
      await _playlistManager.removeFromPlaylist(index);
      AppLogger().d('➖ 从播放列表移除歌曲，索引: $index');
      update();
    } catch (e) {
      AppLogger().e('从播放列表移除歌曲失败: $e');
    }
  }

  /// 清空播放列表
  Future<void> clearPlaylist() async {
    try {
      await _playlistManager.clearPlaylist();
      AppLogger().d('🗑️ 清空播放列表');
      update();
    } catch (e) {
      AppLogger().e('清空播放列表失败: $e');
    }
  }

  /// 下一首播放
  /// 在当前歌曲后插入一首歌曲
  void insertNextToPlay(Song song) {
    try {
      _playlistManager.insertNextToPlay(song);
      AppLogger().d('🔜 插入下一首播放: ${song.songName}');
      update();
    } catch (e) {
      AppLogger().e('插入下一首播放失败: $e');
    }
  }

  /// 从API加载歌曲
  /// [page] 页码
  /// [size] 每页数量
  /// [artistName] 歌手名称（可选）
  /// [songName] 歌曲名称（可选）
  Future<List<Song>> loadSongs(
      {int page = 1,
      int size = 20,
      String? artistName,
      String? songName}) async {
    try {
      final response = await ApiService()
          .getAllSongs(page, size, artistName: artistName, songName: songName);

      AppLogger().d('加载歌曲响应状态: ${response.statusCode}');

      // 处理所有状态码，不仅仅是200
      final data =
          response.data is Map ? response.data : jsonDecode(response.data);

      if (data['code'] == 200 && data['data'] != null) {
        // 检查返回的数据结构是否符合预期
        if (data['data']['items'] != null) {
          final List<dynamic> items = data['data']['items'] ?? [];
          return items.map((item) => Song.fromJson(item)).toList();
        } else if (data['data']['records'] != null) {
          // 兼容可能的records字段
          final List<dynamic> items = data['data']['records'] ?? [];
          return items.map((item) => Song.fromJson(item)).toList();
        }
      } else {
        // 处理业务错误
        AppLogger().e('API返回错误代码: ${data['code']}');
        AppLogger().e('API错误信息: ${data['message']}');
      }
    } catch (e) {
      AppLogger().e('加载歌曲失败: $e');
    }
    return [];
  }

  /// 检查推荐歌曲缓存是否有效
  bool _isRecommendedSongsCacheValid() {
    if (_recommendedSongsCache.isEmpty ||
        _recommendedSongsCacheTimestamp == null) {
      return false;
    }
    final cacheAge =
        DateTime.now().difference(_recommendedSongsCacheTimestamp!);
    return cacheAge < _recommendedCacheExpiry;
  }

  /// 加载推荐歌曲
  /// [forceRefresh] 是否强制刷新（忽略缓存）
  Future<List<Song>> loadRecommendedSongs({bool forceRefresh = false}) async {
    // 检查缓存是否有效
    if (!forceRefresh && _isRecommendedSongsCacheValid()) {
      AppLogger().d('使用缓存的推荐歌曲');
      return _recommendedSongsCache;
    }

    try {
      final response = await ApiService().getRecommendedSongs();
      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : jsonDecode(response.data);
        if (data['code'] == 200 && data['data'] != null) {
          final List<dynamic> records = data['data'] ?? [];
          final songs = records.map((item) => Song.fromJson(item)).toList();
          // 更新缓存
          _recommendedSongsCache = songs;
          _recommendedSongsCacheTimestamp = DateTime.now();
          return songs;
        }
      }
    } catch (e) {
      AppLogger().e('加载推荐歌曲失败: $e');
      // 如果加载失败，返回缓存数据（如果有）
      if (_recommendedSongsCache.isNotEmpty) {
        AppLogger().d('加载失败，返回缓存的推荐歌曲');
        return _recommendedSongsCache;
      }
    }
    return [];
  }

  /// 加载用户收藏歌曲
  /// [page] 页码
  /// [size] 每页数量
  /// [forceRefresh] 是否强制刷新（忽略缓存）
  Future<List<Song>> loadUserFavoriteSongs(
      {int page = 1, int size = 20, bool forceRefresh = false}) async {
    return await _favoriteService.loadUserFavoriteSongs(
        page: page, size: size, forceRefresh: forceRefresh);
  }

  /// 检查歌曲是否已收藏
  /// [song] 要检查的歌曲
  bool isSongFavorited(Song song) {
    return _favoriteService.isSongFavorited(song);
  }

  /// 添加歌曲到收藏
  /// [song] 要添加的歌曲
  Future<bool> addToFavorites(Song song) async {
    return await _favoriteService.addToFavorites(song);
  }

  /// 从收藏中移除歌曲
  /// [song] 要移除的歌曲
  Future<bool> removeFromFavorites(Song song) async {
    return await _favoriteService.removeFromFavorites(song);
  }

  /// 释放资源
  /// 释放所有服务的资源
  @override
  void dispose() {
    try {
      // 保存播放状态
      if (currentSong != null) {
        _playlistManager.savePlayHistory(currentSong!);
        _playlistManager.savePlaylist();
      }

      // 释放各服务资源
      _audioPlayerService.dispose();

      AppLogger().d('✅ MusicController 资源释放完成');
    } catch (e) {
      AppLogger().e('❌ MusicController 资源释放失败: $e');
    }
    super.dispose();
  }
}
