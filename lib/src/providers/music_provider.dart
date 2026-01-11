import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart' as audioplayers;
import 'package:vibe_music_app/src/services/api_service.dart';
import 'package:vibe_music_app/src/models/song_model.dart';

enum AppPlayerState {
  stopped,
  playing,
  paused,
  loading,
  completed,
}

class MusicProvider with ChangeNotifier {
  final audioplayers.AudioPlayer _audioPlayer = audioplayers.AudioPlayer();
  AppPlayerState _playerState = AppPlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  List<Song> _playlist = [];
  int _currentIndex = 0;
  bool _isShuffle = false;
  RepeatMode _repeatMode = RepeatMode.none;
  double _volume = 1.0;

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
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    _audioPlayer.onDurationChanged.listen((d) {
      _duration = d;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((p) {
      _position = p;
      notifyListeners();
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == audioplayers.PlayerState.playing) {
        _playerState = AppPlayerState.playing;
      } else if (state == audioplayers.PlayerState.paused) {
        _playerState = AppPlayerState.paused;
      } else if (state == audioplayers.PlayerState.completed) {
        _onSongComplete();
      } else if (state == audioplayers.PlayerState.stopped) {
        _playerState = AppPlayerState.stopped;
      }
      notifyListeners();
    });
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
      notifyListeners();
    }
  }

  Future<void> playSong(Song song, {List<Song>? playlist}) async {
    // 检查songUrl是否存在
    if (song.songUrl == null || song.songUrl!.isEmpty) {
      _playerState = AppPlayerState.stopped;
      debugPrint('Error: Song URL is null or empty for song: ${song.songName}');
      debugPrint('song.songUrl: ${song.songUrl}');
      return;
    }

    debugPrint('Attempting to play song: ${song.songName}');
    debugPrint('Artist: ${song.artistName}');
    debugPrint('Song URL: ${song.songUrl}');
    debugPrint('URL length: ${song.songUrl!.length}');
    debugPrint('URL validity: ${Uri.tryParse(song.songUrl!)?.isAbsolute}');

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
      // 先停止当前播放
      await _audioPlayer.stop();
      // 播放新歌曲
      debugPrint('About to play audio from URL');
      await _audioPlayer.play(audioplayers.UrlSource(song.songUrl!));
      _playerState = AppPlayerState.playing;
      debugPrint('Successfully started playing song: ${song.songName}');
      debugPrint('Audio player state after play: ${_audioPlayer.state}');
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error playing song ${song.songName}: $e');
      debugPrint('Stack trace: $stackTrace');
      _playerState = AppPlayerState.stopped;
      notifyListeners();
    }
  }

  Future<void> play() async {
    if (currentSong == null || currentSong!.songUrl == null) {
      debugPrint('Error: No valid song URL');
      return;
    }

    try {
      if (_playerState == AppPlayerState.paused) {
        await _audioPlayer.resume();
      } else {
        await _audioPlayer.stop();
        await _audioPlayer.play(audioplayers.UrlSource(currentSong!.songUrl!));
      }
    } catch (e) {
      debugPrint('Error playing song: $e');
      _playerState = AppPlayerState.stopped;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
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
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.none;
        break;
    }
    notifyListeners();
  }

  void setVolume(double volume) {
    _volume = volume;
    _audioPlayer.setVolume(volume);
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
      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : jsonDecode(response.data);
        if (data['code'] == 200 && data['data'] != null) {
          final List<dynamic> records = data['data']['records'] ?? [];
          return records.map((item) => Song.fromJson(item)).toList();
        }
      }
    } catch (e) {
      debugPrint('Error loading songs: $e');
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
      debugPrint('Error loading recommended songs: $e');
    }
    return [];
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

enum RepeatMode {
  none,
  all,
  one,
}
