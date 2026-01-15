import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:vibe_music_app/src/services/api_service.dart';
import 'package:vibe_music_app/src/models/song_model.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';

enum AppPlayerState {
  stopped,
  playing,
  paused,
  loading,
  completed,
}

class MusicProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  AppPlayerState _playerState = AppPlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  List<Song> _playlist = [];
  int _currentIndex = 0;
  bool _isShuffle = false;
  RepeatMode _repeatMode = RepeatMode.none;
  double _volume = 0.5; // 默认音量设置为50%
  Set<int> _favoriteSongIds = {}; // Local state to track favorite song IDs
  AudioSession? _audioSession; // 音频会话，用于获取和监听系统音量

  // Stream controllers for frequently changing data
  final _positionStreamController = StreamController<Duration>.broadcast();
  final _durationStreamController = StreamController<Duration>.broadcast();
  final _playerStateStreamController =
      StreamController<AppPlayerState>.broadcast();
  final _volumeStreamController = StreamController<double>.broadcast();

  // Stream getters
  Stream<Duration> get positionStream => _positionStreamController.stream;
  Stream<Duration> get durationStream => _durationStreamController.stream;
  Stream<AppPlayerState> get playerStateStream =>
      _playerStateStreamController.stream;
  Stream<double> get volumeStream => _volumeStreamController.stream;

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

  MusicProvider() {
    // 异步初始化音频播放器
    _initializeAudioPlayer();
  }

  /// 异步初始化音频播放器
  Future<void> _initializeAudioPlayer() async {
    await _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    // 初始化音频会话
    _audioSession = await AudioSession.instance;
    await _audioSession!.configure(const AudioSessionConfiguration.music());

    // 注意：audio_session 0.2.x 版本的方法名可能不同，这里使用兼容的方式
    // 当用户调整系统音量时，音频会话会自动更新播放器音量
    // 设置初始音量
    _audioPlayer.setVolume(_volume);

    // Listen for duration changes
    _audioPlayer.durationStream.listen((d) {
      if (d != null) {
        _duration = d;
        _durationStreamController.add(d);
        // Only notify listeners when duration changes significantly
        notifyListeners();
      }
    });

    // Listen for position changes - use stream instead of notifyListeners
    _audioPlayer.positionStream.listen((p) {
      _position = p;
      _positionStreamController.add(p);
      // Don't call notifyListeners() here to avoid frequent rebuilds
    });

    // Listen for player state changes
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

    // Set default loop mode
    _audioPlayer.setLoopMode(LoopMode.off);
  }

  void _onSongComplete() {
    if (_repeatMode == RepeatMode.one) {
      seekTo(Duration.zero);
      play();
    } else if (_currentIndex < _playlist.length - 1 ||
        _repeatMode == RepeatMode.all) {
      next();
    } else {
      _playerState = AppPlayerState.completed;
      _playerStateStreamController.add(_playerState);
      notifyListeners();
    }
  }

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

  Future<void> pause() async {
    await _audioPlayer.pause();
    _playerState = AppPlayerState.paused;
    notifyListeners();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _playerState = AppPlayerState.stopped;
    _position = Duration.zero;
    notifyListeners();
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void next() {
    if (_playlist.isNotEmpty) {
      if (_isShuffle) {
        _currentIndex = (_playlist.length * 999).toInt() % _playlist.length;
      } else {
        _currentIndex = (_currentIndex + 1) % _playlist.length;
      }
      playSong(_playlist[_currentIndex]);
    }
  }

  void previous() {
    if (_playlist.isNotEmpty) {
      _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
      playSong(_playlist[_currentIndex]);
    }
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    notifyListeners();
  }

  void toggleRepeat() {
    switch (_repeatMode) {
      case RepeatMode.none:
        _repeatMode = RepeatMode.all;
        _audioPlayer.setLoopMode(LoopMode.all);
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        _audioPlayer.setLoopMode(LoopMode.one);
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.none;
        _audioPlayer.setLoopMode(LoopMode.off);
        break;
    }
    notifyListeners();
  }

  void setVolume(double volume) {
    _volume = volume;
    _audioPlayer.setVolume(volume);
    _volumeStreamController.add(volume);
    notifyListeners();
  }

  void addToPlaylist(Song song) {
    _playlist.add(song);
    notifyListeners();
  }

  void removeFromPlaylist(int index) {
    if (index >= 0 && index < _playlist.length) {
      _playlist.removeAt(index);
      if (index < _currentIndex) {
        _currentIndex--;
      }
      notifyListeners();
    }
  }

  void clearPlaylist() {
    _playlist.clear();
    _currentIndex = 0;
    notifyListeners();
  }

  // Load songs from API
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

  // Load user favorite songs
  Future<List<Song>> loadUserFavoriteSongs(
      {int page = 1, int size = 20}) async {
    try {
      final response = await ApiService().getAllSongs(page, size);
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

  // Check if song is favorited
  bool isSongFavorited(Song song) {
    if (song.id == null) return false;
    return _favoriteSongIds.contains(song.id);
  }

  // Add song to favorites
  Future<bool> addToFavorites(Song song) async {
    if (song.id == null) return false;

    try {
      // Call API to add favorite song
      final response = await ApiService().addFavoriteSong(song.id!);
      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : jsonDecode(response.data);
        if (data['code'] == 200) {
          // Update local state
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

  // Remove song from favorites
  Future<bool> removeFromFavorites(Song song) async {
    if (song.id == null) return false;

    try {
      // Call API to remove favorite song
      final response = await ApiService().removeFavoriteSong(song.id!);
      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : jsonDecode(response.data);
        if (data['code'] == 200) {
          // Update local state
          _favoriteSongIds.remove(song.id!);
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      AppLogger().e('Error removing song from favorites: $e');
    }
    return false;
  }

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

enum RepeatMode {
  none,
  all,
  one,
}
