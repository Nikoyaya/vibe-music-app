import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:vibe_music_app/src/data/database/entity/play_history_entity.dart';
import 'package:vibe_music_app/src/data/database/entity/playlist_song_entity.dart';
import 'package:vibe_music_app/src/services/api_service.dart';
import 'package:vibe_music_app/src/models/song_model.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';
import 'package:vibe_music_app/src/utils/database/database_manager.dart';
import 'package:vibe_music_app/src/utils/sp_util.dart';

/// 播放器状态枚举
enum AppPlayerState {
  stopped, // 停止状态
  playing, // 播放状态
  paused, // 暂停状态
  loading, // 加载状态
  completed, // 完成状态
}

/// 音乐提供者类，管理音频播放相关功能
class MusicProvider with ChangeNotifier {
  // 音频播放器实例
  final AudioPlayer _audioPlayer = AudioPlayer();
  // 当前播放器状态
  AppPlayerState _playerState = AppPlayerState.stopped;
  // 当前音频时长
  Duration _duration = Duration.zero;
  // 当前播放位置
  Duration _position = Duration.zero;
  // 播放列表
  List<Song> _playlist = [];
  // 当前播放索引
  int _currentIndex = 0;
  // 是否随机播放
  bool _isShuffle = false;
  // 重复模式
  RepeatMode _repeatMode = RepeatMode.none;
  // 音量大小（默认50%）
  double _volume = 0.5; // 默认音量设置为50%
  /// 收藏歌曲ID集合
  RxSet<int> _favoriteSongIds = <int>{}.obs; // 本地状态，用于跟踪收藏的歌曲ID

  /// 收藏歌曲列表缓存
  RxList<Song> _favoriteSongsCache = <Song>[].obs;

  /// 缓存时间戳
  DateTime? _favoriteSongsCacheTimestamp;

  /// 缓存过期时间（分钟）
  static const int CACHE_EXPIRY_MINUTES = 5;
  // 音频会话
  AudioSession? _audioSession; // 音频会话，用于获取和监听系统音量

  // 用于频繁变化数据的流控制器
  final _positionStreamController = StreamController<Duration>.broadcast();
  final _durationStreamController = StreamController<Duration>.broadcast();
  final _playerStateStreamController =
      StreamController<AppPlayerState>.broadcast();
  final _volumeStreamController = StreamController<double>.broadcast();

  // 流获取器
  Stream<Duration> get positionStream => _positionStreamController.stream;
  Stream<Duration> get durationStream => _durationStreamController.stream;
  Stream<AppPlayerState> get playerStateStream =>
      _playerStateStreamController.stream;
  Stream<double> get volumeStream => _volumeStreamController.stream;

  // 获取器
  AppPlayerState get playerState => _playerState;
  Duration get duration => _duration;
  Duration get position => _position;
  List<Song> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  Song? get currentSong =>
      _currentIndex >= 0 && _currentIndex < _playlist.length
          ? _playlist[_currentIndex]
          : null;
  bool get isShuffle => _isShuffle;
  RepeatMode get repeatMode => _repeatMode;
  double get volume => _volume;
  RxSet<int> get favoriteSongIds => _favoriteSongIds;

  /// 构造函数
  MusicProvider() {
    // 异步初始化音频播放器和加载播放状态
    _initialize();
  }

  /// 初始化方法
  Future<void> _initialize() async {
    await _initAudioPlayer();
    await _loadPlayState();
  }

  /// 初始化音频播放器
  Future<void> _initAudioPlayer() async {
    // 初始化音频会话
    _audioSession = await AudioSession.instance;
    await _audioSession!.configure(const AudioSessionConfiguration.music());

    // 注意：audio_session 0.2.x 版本的方法名可能不同，这里使用兼容的方式
    // 当用户调整系统音量时，音频会话会自动更新播放器音量
    // 设置初始音量
    _audioPlayer.setVolume(_volume);

    // 监听音频时长变化
    _audioPlayer.durationStream.listen((d) {
      AppLogger().d('durationStream 收到数据: $d');
      if (d != null) {
        _duration = d;
        AppLogger().d('更新时长为: ${d.inMinutes}:${d.inSeconds % 60}');
        _durationStreamController.add(d);
        // 只有当时长显著变化时才通知监听器
        notifyListeners();
      }
    });

    // 监听播放位置变化 - 使用流而不是 notifyListeners
    _audioPlayer.positionStream.listen((p) {
      _position = p;
      _positionStreamController.add(p);
      // 不要在这里调用 notifyListeners() 以避免频繁重建
    });

    // 监听播放器状态变化
    _audioPlayer.playerStateStream.listen((state) {
      AppPlayerState newState;
      switch (state.processingState) {
        case ProcessingState.idle:
        case ProcessingState.loading:
          newState = AppPlayerState.loading;
          break;
        case ProcessingState.buffering:
          newState = AppPlayerState.loading;
          break;
        case ProcessingState.ready:
          newState =
              state.playing ? AppPlayerState.playing : AppPlayerState.paused;
          break;
        case ProcessingState.completed:
          _onSongComplete();
          return;
      }

      if (_playerState != newState) {
        _playerState = newState;
        _playerStateStreamController.add(newState);
        notifyListeners();
      }
    });

    // 设置默认循环模式
    _audioPlayer.setLoopMode(LoopMode.off);
  }

  /// 歌曲播放完成时的处理
  void _onSongComplete() {
    if (_repeatMode == RepeatMode.one) {
      // 单曲循环
      seekTo(Duration.zero);
      play();
    } else if (_currentIndex < _playlist.length - 1 ||
        _repeatMode == RepeatMode.all) {
      // 播放下一首或全部循环
      next();
    } else {
      // 播放完成
      _playerState = AppPlayerState.completed;
      _playerStateStreamController.add(_playerState);
      notifyListeners();
    }
  }

  /// 播放指定歌曲
  /// [song] 要播放的歌曲
  /// [playlist] 可选的播放列表
  Future<void> playSong(Song song, {List<Song>? playlist}) async {
    // 检查songUrl是否存在
    if (song.songUrl == null || song.songUrl!.isEmpty) {
      _playerState = AppPlayerState.stopped;
      AppLogger().e('错误: 歌曲URL为空或不存在，歌曲名称: ${song.songName}');
      AppLogger().e('歌曲URL: ${song.songUrl}');
      return;
    }

    AppLogger().d('尝试播放歌曲: ${song.songName}');
    AppLogger().d('歌手: ${song.artistName}');
    AppLogger().d('歌曲URL: ${song.songUrl}');
    AppLogger().d('URL长度: ${song.songUrl!.length}');
    AppLogger().d('URL有效性: ${Uri.tryParse(song.songUrl!)?.isAbsolute}');

    _playerState = AppPlayerState.loading;
    notifyListeners();

    if (playlist != null) {
      // 如果提供了新的播放列表
      _playlist = playlist;
      _currentIndex = _playlist.indexOf(song);
      if (_currentIndex < 0) _currentIndex = 0;
    } else if (_playlist.isNotEmpty) {
      // 如果没有提供新的播放列表，就在当前播放列表中查找选中的歌曲
      final index = _playlist.indexOf(song);
      if (index >= 0) {
        _currentIndex = index;
      }
    }

    try {
      // 重置播放器
      await _audioPlayer.stop();
      // 设置音频源
      AppLogger().d('准备从URL播放音频');
      await _audioPlayer.setUrl(song.songUrl!);
      // 播放歌曲
      await _audioPlayer.play();
      _playerState = AppPlayerState.playing;
      AppLogger().d('成功开始播放歌曲: ${song.songName}');
      AppLogger().d('播放后音频播放器状态: ${_audioPlayer.playerState}');
      notifyListeners();

      // 保存播放历史
      if (currentSong != null) {
        await savePlayHistory(currentSong!);
      }
      // 保存播放列表
      await savePlaylist();
    } catch (e, stackTrace) {
      AppLogger().e('播放歌曲 ${song.songName} 失败: $e');
      AppLogger().e('堆栈跟踪: $stackTrace');
      _playerState = AppPlayerState.stopped;
      notifyListeners();
    }
  }

  /// 播放当前歌曲
  Future<void> play() async {
    if (currentSong == null || currentSong!.songUrl == null) {
      AppLogger().e('错误: 没有有效的歌曲URL');
      return;
    }

    try {
      await _audioPlayer.play();
      _playerState = AppPlayerState.playing;
      notifyListeners();
    } catch (e) {
      AppLogger().e('播放歌曲失败: $e');
      _playerState = AppPlayerState.stopped;
      notifyListeners();
    }
  }

  /// 暂停当前歌曲
  Future<void> pause() async {
    await _audioPlayer.pause();
    _playerState = AppPlayerState.paused;
    notifyListeners();

    // 保存播放状态
    if (currentSong != null) {
      await savePlayHistory(currentSong!);
      await savePlaylist();
    }
  }

  /// 停止播放
  Future<void> stop() async {
    await _audioPlayer.stop();
    _playerState = AppPlayerState.stopped;
    _position = Duration.zero;
    notifyListeners();
  }

  /// 跳转到指定位置
  /// [position] 要跳转到的位置
  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  /// 播放下一首歌曲
  void next() {
    if (_playlist.isNotEmpty) {
      if (_isShuffle) {
        // 随机播放
        _currentIndex = (_playlist.length * 999).toInt() % _playlist.length;
      } else {
        // 顺序播放
        _currentIndex = (_currentIndex + 1) % _playlist.length;
      }
      playSong(_playlist[_currentIndex]);
    }
  }

  /// 播放上一首歌曲
  void previous() {
    if (_playlist.isNotEmpty) {
      _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
      playSong(_playlist[_currentIndex]);
    }
  }

  /// 切换随机播放模式
  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    notifyListeners();
  }

  /// 切换重复模式
  void toggleRepeat() {
    switch (_repeatMode) {
      case RepeatMode.none:
        // 切换到全部循环
        _repeatMode = RepeatMode.all;
        _audioPlayer.setLoopMode(LoopMode.all);
        break;
      case RepeatMode.all:
        // 切换到单曲循环
        _repeatMode = RepeatMode.one;
        _audioPlayer.setLoopMode(LoopMode.one);
        break;
      case RepeatMode.one:
        // 切换到不循环
        _repeatMode = RepeatMode.none;
        _audioPlayer.setLoopMode(LoopMode.off);
        break;
    }
    notifyListeners();
  }

  /// 设置音量
  /// [volume] 音量大小（0.0-1.0）
  void setVolume(double volume) {
    _volume = volume;
    _audioPlayer.setVolume(volume);
    _volumeStreamController.add(volume);
    notifyListeners();
  }

  /// 添加歌曲到播放列表
  /// [song] 要添加的歌曲
  void addToPlaylist(Song song) {
    _playlist.add(song);
    notifyListeners();
  }

  /// 从播放列表移除歌曲
  /// [index] 要移除的歌曲索引
  void removeFromPlaylist(int index) {
    if (index >= 0 && index < _playlist.length) {
      final removedSong = _playlist[index];
      _playlist.removeAt(index);
      if (index < _currentIndex) {
        _currentIndex--;
      } else if (index == _currentIndex && _currentIndex >= _playlist.length) {
        _currentIndex = _playlist.length - 1;
      }
      // 保存播放列表
      savePlaylist();
      notifyListeners();
      AppLogger().d('✅ 从播放列表移除歌曲: ${removedSong.songName}');
    }
  }

  /// 清空播放列表
  void clearPlaylist() {
    _playlist.clear();
    _currentIndex = 0;
    notifyListeners();
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
      AppLogger().d('加载歌曲响应数据: ${response.data}');

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

  /// 加载推荐歌曲
  Future<List<Song>> loadRecommendedSongs() async {
    try {
      final response = await ApiService().getRecommendedSongs();
      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : jsonDecode(response.data);
        if (data['code'] == 200 && data['data'] != null) {
          final List<dynamic> records = data['data'] ?? [];
          return records.map((item) => Song.fromJson(item)).toList();
        }
      }
    } catch (e) {
      AppLogger().e('加载推荐歌曲失败: $e');
    }
    return [];
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
        final data =
            response.data is Map ? response.data : jsonDecode(response.data);
        if (data['code'] == 200 && data['data'] != null) {
          final List<dynamic> items = data['data']['items'] ?? [];
          final songs = items.map((item) => Song.fromJson(item)).toList();

          // 如果是第一页，更新缓存
          if (page == 1) {
            _updateFavoriteSongsCache(songs);
          }

          return songs;
        }
      }
    } catch (e) {
      AppLogger().e('加载用户收藏歌曲失败: $e');
    }
    return [];
  }

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

    // 通知监听器收藏状态已更新
    notifyListeners();
  }

  /// 从缓存中移除收藏歌曲
  void _removeSongFromCache(int songId) {
    _favoriteSongsCache.removeWhere((song) => song.id == songId);
    _favoriteSongIds.remove(songId);

    // 通知监听器收藏状态已更新
    notifyListeners();
  }

  /// 向缓存中添加收藏歌曲
  void _addSongToCache(Song song) {
    if (!_favoriteSongsCache.any((s) => s.id == song.id)) {
      _favoriteSongsCache.insert(0, song);
      if (song.id != null) {
        _favoriteSongIds.add(song.id!);
      }

      // 通知监听器收藏状态已更新
      notifyListeners();
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

    try {
      // 调用API添加收藏歌曲
      final response = await ApiService().collectSong(song.id!);
      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : jsonDecode(response.data);
        if (data['code'] == 200) {
          // 更新本地状态
          _favoriteSongIds.add(song.id!);
          // 更新缓存
          _addSongToCache(song);
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      AppLogger().e('添加歌曲到收藏失败: $e');
    }
    return false;
  }

  /// 从收藏中移除歌曲
  /// [song] 要移除的歌曲
  Future<bool> removeFromFavorites(Song song) async {
    if (song.id == null) return false;

    try {
      // 调用API移除收藏歌曲
      final response = await ApiService().cancelCollectSong(song.id!);
      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : jsonDecode(response.data);
        if (data['code'] == 200) {
          // 更新本地状态
          _favoriteSongIds.remove(song.id!);
          // 更新缓存
          _removeSongFromCache(song.id!);
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      AppLogger().e('从收藏中移除歌曲失败: $e');
    }
    return false;
  }

  /// 从数据库加载播放状态
  Future<void> _loadPlayState() async {
    try {
      // 检查是否是第一次启动
      final isFirstLaunch =
          SpUtil.get<bool>('isFirstLaunch', defaultValue: true);

      if (!isFirstLaunch!) {
        // 加载最后播放的歌曲
        final lastPlayedSong = await _loadLastPlayedSong();
        if (lastPlayedSong != null) {
          // 加载播放列表
          await _loadPlaylist();
          // 恢复播放状态
          if (_playlist.isNotEmpty) {
            // 首先尝试通过 songUrl 查找歌曲
            var index = _playlist
                .indexWhere((song) => song.songUrl == lastPlayedSong.songUrl);

            // 如果找不到，尝试通过 songName 和 artistName 查找
            if (index < 0) {
              index = _playlist.indexWhere((song) =>
                  song.songName == lastPlayedSong.songName &&
                  song.artistName == lastPlayedSong.artistName);
            }

            // 如果还是找不到，使用第一个歌曲
            if (index < 0) {
              index = 0;
            }

            _currentIndex = index;
            AppLogger().d('✅ 恢复播放状态，最后播放的歌曲: ${lastPlayedSong.songName}');

            // 准备音频播放器但不自动播放
            final currentSong = _playlist[_currentIndex];
            if (currentSong.songUrl != null &&
                currentSong.songUrl!.isNotEmpty) {
              try {
                // 重置播放器
                await _audioPlayer.stop();
                // 设置音频源
                AppLogger().d('准备音频播放器，设置音频源: ${currentSong.songUrl}');
                await _audioPlayer.setUrl(currentSong.songUrl!);
                // 不自动播放，保持暂停状态
                await _audioPlayer.pause();
                _playerState = AppPlayerState.paused;
                AppLogger().d('✅ 音频播放器准备完成，状态: 暂停');
                notifyListeners();
              } catch (e) {
                AppLogger().e('❌ 准备音频播放器失败: $e');
                _playerState = AppPlayerState.stopped;
              }
            }
          }
        }
      } else {
        // 第一次启动，设置标记
        await SpUtil.put('isFirstLaunch', false);
        AppLogger().d('✅ 首次启动应用，初始化播放状态');
      }
    } catch (e) {
      AppLogger().e('❌ 加载播放状态失败: $e');
    }
  }

  /// 加载最后播放的歌曲
  Future<Song?> _loadLastPlayedSong() async {
    try {
      final db = await DatabaseManager().database;
      final playHistory = await db.playHistoryDao.getRecentPlayHistory(1);

      if (playHistory.isNotEmpty) {
        final history = playHistory[0];
        return Song(
          id: null,
          songName: history.songName,
          artistName: history.artistName,
          songUrl: history.songUrl,
          coverUrl: history.coverUrl,
          duration: history.duration,
        );
      }
    } catch (e) {
      AppLogger().e('❌ 加载最后播放歌曲失败: $e');
    }
    return null;
  }

  /// 加载播放列表
  Future<void> _loadPlaylist() async {
    try {
      final db = await DatabaseManager().database;
      final playlistSongs = await db.playlistSongDao.getSongsByPlaylistId(1);

      if (playlistSongs.isNotEmpty) {
        _playlist.clear();
        for (final playlistSong in playlistSongs) {
          final song = Song(
            id: null,
            songName: playlistSong.songName,
            artistName: playlistSong.artistName,
            songUrl: playlistSong.songUrl,
            coverUrl: playlistSong.coverUrl,
            duration: playlistSong.duration,
          );
          _playlist.add(song);
        }
        AppLogger().d('✅ 从数据库加载播放列表成功，共 ${_playlist.length} 首歌曲');
        notifyListeners();
      }
    } catch (e) {
      AppLogger().e('❌ 加载播放列表失败: $e');
    }
  }

  /// 保存播放列表到数据库
  Future<void> savePlaylist() async {
    try {
      final db = await DatabaseManager().database;

      // 清空现有播放列表
      await db.playlistSongDao.deleteSongsByPlaylistId(1);

      // 保存当前播放列表
      for (int i = 0; i < _playlist.length; i++) {
        final song = _playlist[i];
        final playlistSong = PlaylistSong(
          id: 0,
          playlistId: 1, // 默认播放列表
          songId: song.id?.toString() ?? '',
          songName: song.songName ?? '',
          artistName: song.artistName ?? '',
          coverUrl: song.coverUrl ?? '',
          songUrl: song.songUrl ?? '',
          duration: song.duration ?? '',
          position: i,
          createdAt: DateTime.now().toIso8601String(),
        );
        await db.playlistSongDao.insertPlaylistSong(playlistSong);
      }

      AppLogger().d('✅ 保存播放列表到数据库成功，共 ${_playlist.length} 首歌曲');
    } catch (e) {
      AppLogger().e('❌ 保存播放列表失败: $e');
    }
  }

  /// 保存播放历史
  Future<void> savePlayHistory(Song song) async {
    try {
      final db = await DatabaseManager().database;
      final playHistory = PlayHistory(
        id: 0,
        songId: song.id?.toString() ?? '',
        songName: song.songName ?? '',
        artistName: song.artistName ?? '',
        coverUrl: song.coverUrl ?? '',
        songUrl: song.songUrl ?? '',
        duration: song.duration ?? '',
        playedAt: DateTime.now().toIso8601String(),
      );
      await db.playHistoryDao.insertPlayHistory(playHistory);
      AppLogger().d('✅ 保存播放历史成功: ${song.songName}');
    } catch (e) {
      AppLogger().e('❌ 保存播放历史失败: $e');
    }
  }

  /// 下一首播放
  void insertNextToPlay(Song song) {
    try {
      if (_currentIndex < _playlist.length - 1) {
        // 在当前歌曲后插入
        _playlist.insert(_currentIndex + 1, song);
      } else {
        // 在列表末尾添加
        _playlist.add(song);
      }
      // 保存播放列表
      savePlaylist();
      notifyListeners();
      AppLogger().d('✅ 插入下一首播放: ${song.songName}');
    } catch (e) {
      AppLogger().e('❌ 插入下一首播放失败: $e');
    }
  }

  /// 释放资源
  void dispose() {
    // 保存播放状态
    if (currentSong != null) {
      savePlayHistory(currentSong!);
      savePlaylist();
    }
    _audioPlayer.dispose();
    _positionStreamController.close();
    _durationStreamController.close();
    _playerStateStreamController.close();
    _volumeStreamController.close();
  }
}

/// 重复模式枚举
enum RepeatMode {
  none, // 不重复
  all, // 全部重复
  one, // 单曲重复
}
