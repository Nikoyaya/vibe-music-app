import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

// 导入 audioplayers 库，并添加前缀以避免命名冲突
import 'package:audioplayers/audioplayers.dart' as audioplayers;
import 'package:vibe_music_app/src/services/api_service.dart';
import 'package:vibe_music_app/src/models/song_model.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';
import 'package:vibe_music_app/src/utils/sp_util.dart';

/// 播放器状态枚举
enum AppPlayerState {
  stopped, // 停止状态
  playing, // 播放状态
  paused, // 暂停状态
  loading, // 加载状态
  completed, // 完成状态
}

/// 音乐控制器类，管理音频播放相关功能
class MusicController extends GetxController {
  // 音频播放器实例（非桌面端使用）
  AudioPlayer? _audioPlayer;

  // 桌面端音频播放器实例
  audioplayers.AudioPlayer? _desktopAudioPlayer;
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

  /// 收藏操作节流控制
  final _favoriteOperation = false.obs;
  static const int throttleDelay = 500; // 收藏操作节流延迟时间

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
  MusicController() {
    // 异步初始化音频播放器和加载播放状态
    _initialize();
  }

  /// 检查是否为桌面端平台（不包括web）
  bool get _isDesktop {
    return !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.linux);
  }

  /// 初始化方法
  Future<void> _initialize() async {
    try {
      // 检查是否为桌面端平台（不包括web）
      final isDesktop = _isDesktop;
      AppLogger().d(
          '初始化平台检测: isDesktop=$isDesktop, kIsWeb=$kIsWeb, defaultTargetPlatform=$defaultTargetPlatform');

      if (!isDesktop) {
        // 非桌面端平台（移动端和web），初始化 just_audio 播放器
        await _initAudioPlayer();
      } else {
        // 桌面端平台，初始化 audioplayers 播放器
        await _initDesktopAudioPlayer();
      }

      await _loadPlayState();
    } catch (e) {
      AppLogger().e('❌ 初始化失败: $e');
      // 即使初始化失败，也要确保应用能够正常启动
    }
  }

  /// 初始化桌面端音频播放器
  Future<void> _initDesktopAudioPlayer() async {
    try {
      // 初始化 audioplayers 播放器
      _desktopAudioPlayer = audioplayers.AudioPlayer();
      AppLogger().d('✅ 桌面端音频播放器初始化成功');

      // 监听播放状态
      _desktopAudioPlayer?.onPlayerStateChanged.listen((state) {
        AppPlayerState newState;
        switch (state) {
          case audioplayers.PlayerState.stopped:
            newState = AppPlayerState.stopped;
            break;
          case audioplayers.PlayerState.playing:
            newState = AppPlayerState.playing;
            break;
          case audioplayers.PlayerState.paused:
            newState = AppPlayerState.paused;
            break;
          case audioplayers.PlayerState.completed:
            _onSongComplete();
            return;
          default:
            newState = AppPlayerState.loading;
            break;
        }

        if (_playerState != newState) {
          _playerState = newState;
          _playerStateStreamController.add(newState);
          update();
        }
      });

      // 监听播放位置
      _desktopAudioPlayer?.onPositionChanged.listen((position) {
        _position = position;
        _positionStreamController.add(position);
      });

      // 监听音频时长
      _desktopAudioPlayer?.onDurationChanged.listen((duration) {
        _duration = duration;
        _durationStreamController.add(duration);
        update();
      });
    } catch (e) {
      AppLogger().e('❌ 桌面端音频播放器初始化失败: $e');
    }
  }

  /// 初始化音频播放器
  Future<void> _initAudioPlayer() async {
    // 创建 just_audio 播放器实例
    _audioPlayer = AudioPlayer();

    // 初始化音频会话
    _audioSession = await AudioSession.instance;
    await _audioSession!.configure(const AudioSessionConfiguration.music());

    // 注意：audio_session 0.2.x 版本的方法名可能不同，这里使用兼容的方式
    // 当用户调整系统音量时，音频会话会自动更新播放器音量
    // 设置初始音量
    _audioPlayer!.setVolume(_volume);

    // 监听音频时长变化
    _audioPlayer!.durationStream.listen((d) {
      AppLogger().d('durationStream 收到数据: $d');
      if (d != null) {
        _duration = d;
        AppLogger().d('更新时长为: ${d.inMinutes}:${d.inSeconds % 60}');
        _durationStreamController.add(d);
        // 只有当时长显著变化时才通知监听器
        update();
      }
    });

    // 监听播放位置变化 - 使用流而不是 notifyListeners
    _audioPlayer!.positionStream.listen((p) {
      _position = p;
      _positionStreamController.add(p);
      // 不要在这里调用 notifyListeners() 以避免频繁重建
    });

    // 监听播放器状态变化
    _audioPlayer!.playerStateStream.listen((state) {
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
        update();
      }
    });

    // 设置默认循环模式
    _audioPlayer!.setLoopMode(LoopMode.off);
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
      update();
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

    // AppLogger().d('尝试播放歌曲: ${song.songName}');
    // AppLogger().d('歌手: ${song.artistName}');
    // AppLogger().d('歌曲URL: ${song.songUrl}');
    // AppLogger().d('URL长度: ${song.songUrl!.length}');
    // AppLogger().d('URL有效性: ${Uri.tryParse(song.songUrl!)?.isAbsolute}');

    _playerState = AppPlayerState.loading;
    update();

    if (playlist != null) {
      // 如果提供了新的播放列表
      _playlist = playlist;
      _currentIndex = _playlist.indexOf(song);
      if (_currentIndex < 0) _currentIndex = 0;
      // 保存新的播放列表
      await savePlaylist();
    } else if (_playlist.isNotEmpty) {
      // 如果没有提供新的播放列表，就在当前播放列表中查找选中的歌曲
      final index = _playlist.indexOf(song);
      if (index >= 0) {
        _currentIndex = index;
      }
    }

    // 检查是否为桌面端平台（不包括web）
    final isDesktop = _isDesktop;
    AppLogger().d(
        'playSong 平台检测: isDesktop=$isDesktop, kIsWeb=$kIsWeb, defaultTargetPlatform=$defaultTargetPlatform');

    try {
      if (!isDesktop) {
        // 非桌面端平台，使用 just_audio 播放器
        await _playSongWithJustAudio(song);
      } else {
        // 桌面端平台，使用 audioplayers 播放器
        await _playSongWithAudioPlayers(song);
      }

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
      update();
    }
  }

  /// 使用 just_audio 播放歌曲
  Future<void> _playSongWithJustAudio(Song song) async {
    if (_audioPlayer == null) {
      throw Exception('音频播放器未初始化');
    }

    // 重置播放器
    await _audioPlayer!.stop();
    // 设置音频源
    AppLogger().d('使用 just_audio 准备从URL播放音频');
    await _audioPlayer!.setUrl(song.songUrl!);
    // 播放歌曲
    await _audioPlayer!.play();
    _playerState = AppPlayerState.playing;
    AppLogger().d('使用 just_audio 成功开始播放歌曲: ${song.songName}');
    AppLogger().d('播放后音频播放器状态: ${_audioPlayer!.playerState}');
    update();
  }

  /// 使用 audioplayers 播放歌曲
  Future<void> _playSongWithAudioPlayers(Song song) async {
    if (_desktopAudioPlayer == null) {
      throw Exception('桌面端音频播放器未初始化');
    }

    // 重置播放器
    await _desktopAudioPlayer!.stop();
    // 设置音频源
    AppLogger().d('使用 audioplayers 准备从URL播放音频');
    await _desktopAudioPlayer!.setSourceUrl(song.songUrl!);
    // 播放歌曲
    await _desktopAudioPlayer!.resume();
    _playerState = AppPlayerState.playing;
    AppLogger().d('使用 audioplayers 成功开始播放歌曲: ${song.songName}');
    update();
  }

  /// 播放当前歌曲
  Future<void> play() async {
    if (currentSong == null || currentSong!.songUrl == null) {
      AppLogger().e('错误: 没有有效的歌曲URL');
      return;
    }

    // 检查是否为桌面端平台（不包括web）
    final isDesktop = _isDesktop;

    try {
      if (!isDesktop) {
        // 非桌面端平台，使用 just_audio 播放器
        if (_audioPlayer == null) {
          throw Exception('音频播放器未初始化');
        }
        await _audioPlayer!.play();
        _playerState = AppPlayerState.playing;
        AppLogger().d('使用 just_audio 播放当前歌曲');
      } else {
        // 桌面端平台，使用 audioplayers 播放器
        if (_desktopAudioPlayer == null) {
          throw Exception('桌面端音频播放器未初始化');
        }
        await _desktopAudioPlayer!.resume();
        _playerState = AppPlayerState.playing;
        AppLogger().d('使用 audioplayers 播放当前歌曲');
      }
      update();
    } catch (e) {
      AppLogger().e('播放歌曲失败: $e');
      _playerState = AppPlayerState.stopped;
      update();
    }
  }

  /// 暂停当前歌曲
  Future<void> pause() async {
    // 检查是否为桌面端平台（不包括web）
    final isDesktop = _isDesktop;

    try {
      if (!isDesktop) {
        // 非桌面端平台，使用 just_audio 播放器
        if (_audioPlayer != null) {
          await _audioPlayer!.pause();
        }
      } else {
        // 桌面端平台，使用 audioplayers 播放器
        if (_desktopAudioPlayer != null) {
          await _desktopAudioPlayer!.pause();
        }
      }
      _playerState = AppPlayerState.paused;
      update();

      // 保存播放状态
      if (currentSong != null) {
        await savePlayHistory(currentSong!);
        await savePlaylist();
      }
    } catch (e) {
      AppLogger().e('暂停播放失败: $e');
    }
  }

  /// 停止播放
  Future<void> stop() async {
    // 检查是否为桌面端平台（不包括web）
    final isDesktop = _isDesktop;

    try {
      if (!isDesktop) {
        // 非桌面端平台，使用 just_audio 播放器
        if (_audioPlayer != null) {
          await _audioPlayer!.stop();
        }
      } else {
        // 桌面端平台，使用 audioplayers 播放器
        if (_desktopAudioPlayer != null) {
          await _desktopAudioPlayer!.stop();
        }
      }
      _playerState = AppPlayerState.stopped;
      _position = Duration.zero;
      update();
    } catch (e) {
      AppLogger().e('停止播放失败: $e');
    }
  }

  /// 跳转到指定位置
  /// [position] 要跳转到的位置
  Future<void> seekTo(Duration position) async {
    // 检查是否为桌面端平台（不包括web）
    final isDesktop = _isDesktop;

    try {
      if (!isDesktop) {
        // 非桌面端平台，使用 just_audio 播放器
        if (_audioPlayer != null) {
          await _audioPlayer!.seek(position);
        }
      } else {
        // 桌面端平台，使用 audioplayers 播放器
        if (_desktopAudioPlayer != null) {
          await _desktopAudioPlayer!.seek(position);
        }
      }
    } catch (e) {
      AppLogger().e('跳转播放位置失败: $e');
    }
  }

  /// 播放下一首歌曲
  Future<void> next() async {
    if (_playlist.isNotEmpty) {
      if (_isShuffle) {
        // 随机播放
        _currentIndex = (_playlist.length * 999).toInt() % _playlist.length;
      } else {
        // 顺序播放
        _currentIndex = (_currentIndex + 1) % _playlist.length;
      }
      await playSong(_playlist[_currentIndex]);
    }
  }

  /// 播放上一首歌曲
  Future<void> previous() async {
    if (_playlist.isNotEmpty) {
      _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
      await playSong(_playlist[_currentIndex]);
    }
  }

  /// 切换随机播放模式
  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    update();
  }

  /// 切换重复模式
  void toggleRepeat() {
    // 检查是否为桌面端平台（不包括web）
    final isDesktop = _isDesktop;

    switch (_repeatMode) {
      case RepeatMode.none:
        // 切换到全部循环
        _repeatMode = RepeatMode.all;
        if (!isDesktop && _audioPlayer != null) {
          _audioPlayer!.setLoopMode(LoopMode.all);
        }
        break;
      case RepeatMode.all:
        // 切换到单曲循环
        _repeatMode = RepeatMode.one;
        if (!isDesktop && _audioPlayer != null) {
          _audioPlayer!.setLoopMode(LoopMode.one);
        }
        break;
      case RepeatMode.one:
        // 切换到不循环
        _repeatMode = RepeatMode.none;
        if (!isDesktop && _audioPlayer != null) {
          _audioPlayer!.setLoopMode(LoopMode.off);
        }
        break;
    }
    update();
  }

  /// 设置音量
  /// [volume] 音量大小（0.0-1.0）
  Future<void> setVolume(double volume) async {
    // 检查是否为桌面端平台（不包括web）
    final isDesktop = _isDesktop;

    try {
      _volume = volume;
      if (!isDesktop) {
        // 非桌面端平台，使用 just_audio 播放器
        if (_audioPlayer != null) {
          _audioPlayer!.setVolume(volume);
        }
      } else {
        // 桌面端平台，使用 audioplayers 播放器
        if (_desktopAudioPlayer != null) {
          await _desktopAudioPlayer!.setVolume(volume);
        }
      }
      _volumeStreamController.add(volume);
      update();
    } catch (e) {
      AppLogger().e('设置音量失败: $e');
    }
  }

  /// 添加歌曲到播放列表
  /// [song] 要添加的歌曲
  Future<void> addToPlaylist(Song song) async {
    _playlist.add(song);
    await savePlaylist();
    update();
  }

  /// 从播放列表移除歌曲
  /// [index] 要移除的歌曲索引
  Future<void> removeFromPlaylist(int index) async {
    if (index >= 0 && index < _playlist.length) {
      final removedSong = _playlist[index];
      _playlist.removeAt(index);
      if (index < _currentIndex) {
        _currentIndex--;
      } else if (index == _currentIndex && _currentIndex >= _playlist.length) {
        _currentIndex = _playlist.length - 1;
      }
      // 保存播放列表
      await savePlaylist();
      update();
      AppLogger().d('✅ 从播放列表移除歌曲: ${removedSong.songName}');
    }
  }

  /// 清空播放列表
  Future<void> clearPlaylist() async {
    _playlist.clear();
    _currentIndex = 0;
    await savePlaylist();
    update();
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

  /// 推荐歌曲缓存
  List<Song> _recommendedSongsCache = [];
  DateTime? _recommendedSongsCacheTimestamp;
  static const Duration _recommendedCacheExpiry = Duration(minutes: 30);

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
    update();
  }

  /// 从缓存中移除收藏歌曲
  void _removeSongFromCache(int songId) {
    _favoriteSongsCache.removeWhere((song) => song.id == songId);
    _favoriteSongIds.remove(songId);

    // 通知监听器收藏状态已更新
    update();
  }

  /// 向缓存中添加收藏歌曲
  void _addSongToCache(Song song) {
    if (!_favoriteSongsCache.any((s) => s.id == song.id)) {
      _favoriteSongsCache.insert(0, song);
      if (song.id != null) {
        _favoriteSongIds.add(song.id!);
      }

      // 通知监听器收藏状态已更新
      update();
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
        final data =
            response.data is Map ? response.data : jsonDecode(response.data);
        if (data['code'] == 200) {
          // 更新本地状态
          _favoriteSongIds.add(song.id!);
          // 更新缓存
          _addSongToCache(song);
          update();
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
        final data =
            response.data is Map ? response.data : jsonDecode(response.data);
        if (data['code'] == 200) {
          // 更新本地状态
          _favoriteSongIds.remove(song.id!);
          // 更新缓存
          _removeSongFromCache(song.id!);
          update();
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

  /// 准备音频播放器但不自动播放
  Future<void> _prepareAudioPlayer(Song song) async {
    if (song.songUrl == null || song.songUrl!.isEmpty) return;

    try {
      final isDesktop = _isDesktop;

      if (!isDesktop) {
        // 非桌面端平台，使用 just_audio 播放器
        if (_audioPlayer != null) {
          // 重置播放器
          await _audioPlayer!.stop();
          // 设置音频源
          AppLogger().d('准备音频播放器，设置音频源: ${song.songUrl}');
          await _audioPlayer!.setUrl(song.songUrl!);
          // 不自动播放，保持暂停状态
          await _audioPlayer!.pause();
          _playerState = AppPlayerState.paused;
        }
      } else {
        // 桌面端平台，使用 audioplayers 播放器
        if (_desktopAudioPlayer != null) {
          // 重置播放器
          await _desktopAudioPlayer!.stop();
          // 设置音频源
          AppLogger().d('准备桌面端音频播放器，设置音频源: ${song.songUrl}');
          await _desktopAudioPlayer!.setSourceUrl(song.songUrl!);
          // 不自动播放，保持暂停状态
          // audioplayers 在设置源后默认是暂停状态
          _playerState = AppPlayerState.paused;
        }
      }
      AppLogger().d('✅ 音频播放器准备完成，状态: 暂停');
      update();
    } catch (e) {
      AppLogger().e('❌ 准备音频播放器失败: $e');
      _playerState = AppPlayerState.stopped;
    }
  }

  /// 从播放列表中查找歌曲索引
  int _findSongIndex(Song song, List<Song> playlist) {
    // 首先尝试通过 songUrl 查找歌曲
    var index = playlist.indexWhere((s) => s.songUrl == song.songUrl);

    // 如果找不到，尝试通过 songName 和 artistName 查找
    if (index < 0) {
      index = playlist.indexWhere((s) =>
          s.songName == song.songName && s.artistName == song.artistName);
    }

    // 如果还是找不到，使用第一个歌曲
    if (index < 0) {
      index = 0;
    }

    return index;
  }

  /// 从数据库加载播放状态
  Future<void> _loadPlayState() async {
    try {
      // 检查是否是第一次启动
      final isFirstLaunch =
          SpUtil.get<bool>('isFirstLaunch', defaultValue: true);

      if (isFirstLaunch!) {
        // 第一次启动，设置标记
        await SpUtil.put('isFirstLaunch', false);
        AppLogger().d('✅ 首次启动应用，跳过加载上次播放状态');
        // 首次启动时，不加载上次播放的歌曲，直接返回
        return;
      }

      // 加载最后播放的歌曲
      final lastPlayedSong = await _loadLastPlayedSong();
      if (lastPlayedSong == null) return;

      // 加载播放列表
      await _loadPlaylist();
      if (_playlist.isEmpty) return;

      // 查找歌曲索引
      _currentIndex = _findSongIndex(lastPlayedSong, _playlist);
      AppLogger().d('✅ 恢复播放状态，最后播放的歌曲: ${lastPlayedSong.songName}');

      // 准备音频播放器
      final currentSong = _playlist[_currentIndex];
      await _prepareAudioPlayer(currentSong);

      // 通知 UI 更新
      update();
    } catch (e) {
      AppLogger().e('❌ 加载播放状态失败: $e');
    }
  }

  /// 通用存储操作方法 - 同时保存到数据库和 SharedPreferences，确保数据可靠性
  /// [dbOperation] 数据库操作函数
  /// [spOperation] SharedPreferences操作函数
  /// [operationName] 操作名称，用于日志
  Future<void> _storageOperation(
    Future<void> Function() dbOperation,
    Future<void> Function() spOperation,
    String operationName,
  ) async {
    try {
      // 尝试保存到数据库
      await dbOperation();
    } catch (dbError) {
      AppLogger().e('⚠️  数据库不可用: $dbError');
    }

    try {
      // 无论数据库操作是否成功，都尝试保存到 SharedPreferences
      await spOperation();
    } catch (spError) {
      AppLogger().e('⚠️  SharedPreferences 不可用: $spError');
    }
  }

  /// 通用加载操作方法 - 优先使用数据库，失败则使用SharedPreferences
  /// [dbOperation] 数据库操作函数
  /// [spOperation] SharedPreferences操作函数
  /// [operationName] 操作名称，用于日志
  Future<T?> _loadOperation<T>(
    Future<T?> Function() dbOperation,
    Future<T?> Function() spOperation,
    String operationName,
  ) async {
    try {
      // 优先使用数据库
      final result = await dbOperation();
      if (result != null) {
        return result;
      }
    } catch (dbError) {
      AppLogger().e('⚠️  数据库不可用，尝试使用 SharedPreferences: $dbError');
    }
    // 数据库不可用或无结果时，使用 SharedPreferences
    return await spOperation();
  }

  /// 加载最后播放的歌曲
  Future<Song?> _loadLastPlayedSong() async {
    try {
      // 直接从 SharedPreferences 加载，不使用数据库
      final lastPlayedSongJson = SpUtil.get<String>('lastPlayedSong');
      if (lastPlayedSongJson != null) {
        try {
          final Map<String, dynamic> json = jsonDecode(lastPlayedSongJson);
          AppLogger().d('✅ 从 SharedPreferences 加载最后播放歌曲成功');
          return Song.fromJson(json);
        } catch (jsonError) {
          AppLogger().e('⚠️  解析 SharedPreferences 最后播放歌曲数据失败: $jsonError');
        }
      }
      return null;
    } catch (e) {
      AppLogger().e('❌ 加载最后播放歌曲失败: $e');
      return null;
    }
  }

  /// 加载播放列表
  Future<void> _loadPlaylist() async {
    try {
      AppLogger().d('🔄 开始加载播放列表');
      AppLogger().d('当前播放列表长度: ${_playlist.length}');

      // 直接从 SharedPreferences 加载，不使用数据库
      AppLogger().d('💾 尝试从 SharedPreferences 加载播放列表');
      final playlistJson = SpUtil.get<String>('playlist');
      AppLogger().d('从 SharedPreferences 获取到的播放列表数据: $playlistJson');
      if (playlistJson != null) {
        try {
          final List<dynamic> jsonList = jsonDecode(playlistJson);
          AppLogger().d('从 SharedPreferences 解析到 ${jsonList.length} 首歌曲');
          _playlist.clear();
          for (final item in jsonList) {
            final song = Song.fromJson(item);
            _playlist.add(song);
            AppLogger().d('添加歌曲到播放列表: ${song.songName}');
          }
          AppLogger()
              .d('✅ 从 SharedPreferences 加载播放列表成功，共 ${_playlist.length} 首歌曲');
          update();
          return;
        } catch (jsonError) {
          AppLogger().e('⚠️  解析 SharedPreferences 播放列表数据失败: $jsonError');
        }
      }

      // 如果所有存储都没有播放列表数据，记录日志
      if (_playlist.isEmpty) {
        AppLogger().d('⚠️  所有存储都没有播放列表数据，播放列表为空');
      } else {
        AppLogger().d('✅ 播放列表加载完成，共 ${_playlist.length} 首歌曲');
      }
    } catch (e) {
      AppLogger().e('❌ 加载播放列表失败: $e');
    }
  }

  /// 保存播放列表
  Future<void> savePlaylist() async {
    AppLogger().d('🔄 开始保存播放列表');
    AppLogger().d('当前播放列表长度: ${_playlist.length}');

    for (int i = 0; i < _playlist.length; i++) {
      final song = _playlist[i];
      AppLogger().d('要保存的歌曲 $i: ${song.songName} - ${song.artistName}');
    }

    // 直接保存到 SharedPreferences，不使用数据库
    try {
      final playlistJson =
          jsonEncode(_playlist.map((song) => song.toJson()).toList());
      AppLogger().d('💾 尝试保存播放列表到 SharedPreferences');
      AppLogger().d('要保存到 SharedPreferences 的数据长度: ${playlistJson.length}');
      AppLogger().d('要保存到 SharedPreferences 的数据: $playlistJson');

      final success = await SpUtil.put('playlist', playlistJson);
      AppLogger().d('保存到 SharedPreferences 结果: $success');
      AppLogger().d('✅ 保存播放列表到 SharedPreferences 成功，共 ${_playlist.length} 首歌曲');
    } catch (e) {
      AppLogger().e('❌ 保存播放列表到 SharedPreferences 失败: $e');
    }

    AppLogger().d('✅ 播放列表保存完成');
  }

  /// 保存播放历史
  Future<void> savePlayHistory(Song song) async {
    // 直接保存到 SharedPreferences，不使用数据库
    try {
      final lastPlayedSongJson = jsonEncode(song.toJson());
      await SpUtil.put('lastPlayedSong', lastPlayedSongJson);
      AppLogger().d('✅ 保存播放历史到 SharedPreferences 成功: ${song.songName}');
    } catch (e) {
      AppLogger().e('❌ 保存播放历史到 SharedPreferences 失败: $e');
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
      update();
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
    // 释放音频播放器资源
    if (_audioPlayer != null) {
      _audioPlayer!.dispose();
    }
    // 释放桌面端音频播放器资源
    if (_desktopAudioPlayer != null) {
      _desktopAudioPlayer!.dispose();
    }
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
