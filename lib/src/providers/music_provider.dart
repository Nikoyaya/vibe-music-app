import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:vibe_music_app/src/services/api_service.dart';
import 'package:vibe_music_app/src/models/song_model.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';

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
  // 收藏歌曲ID集合
  Set<int> _favoriteSongIds = {}; // 本地状态，用于跟踪收藏的歌曲ID
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

  /// 构造函数
  MusicProvider() {
    // 异步初始化音频播放器
    _initializeAudioPlayer();
  }

  /// 异步初始化音频播放器
  Future<void> _initializeAudioPlayer() async {
    await _initAudioPlayer();
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
      _playlist.removeAt(index);
      if (index < _currentIndex) {
        _currentIndex--;
      }
      notifyListeners();
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
  Future<List<Song>> loadUserFavoriteSongs(
      {int page = 1, int size = 20}) async {
    try {
      final response = await ApiService().getUserFavoriteSongs(page, size);
      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : jsonDecode(response.data);
        if (data['code'] == 200 && data['data'] != null) {
          final List<dynamic> items = data['data']['items'] ?? [];
          return items.map((item) => Song.fromJson(item)).toList();
        }
      }
    } catch (e) {
      AppLogger().e('加载用户收藏歌曲失败: $e');
    }
    return [];
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
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      AppLogger().e('从收藏中移除歌曲失败: $e');
    }
    return false;
  }

  /// 释放资源
  @override
  void dispose() {
    _audioPlayer.dispose();
    _positionStreamController.close();
    _durationStreamController.close();
    _playerStateStreamController.close();
    _volumeStreamController.close();
    super.dispose();
  }
}

/// 重复模式枚举
enum RepeatMode {
  none, // 不重复
  all, // 全部重复
  one, // 单曲重复
}
