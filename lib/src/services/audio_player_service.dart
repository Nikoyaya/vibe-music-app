import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

// 导入 audioplayers 库，并添加前缀以避免命名冲突
import 'package:audioplayers/audioplayers.dart' as audioplayers;
import 'package:vibe_music_app/src/models/song_model.dart';
import 'package:vibe_music_app/src/models/enums.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';

/// 音频播放器服务
/// 负责处理音频播放相关的所有功能
class AudioPlayerService {
  /// 音频播放器实例（非桌面端使用）
  AudioPlayer? _audioPlayer;

  /// 桌面端音频播放器实例
  audioplayers.AudioPlayer? _desktopAudioPlayer;

  /// 当前播放器状态
  AppPlayerState _playerState = AppPlayerState.stopped;

  /// 当前音频时长
  Duration _duration = Duration.zero;

  /// 当前播放位置
  Duration _position = Duration.zero;

  /// 音量大小（默认50%）
  double _volume = 0.5; // 默认音量设置为50%

  /// 音频会话
  AudioSession? _audioSession; // 音频会话，用于获取和监听系统音量

  /// 重复模式
  RepeatMode _repeatMode = RepeatMode.none;

  /// 随机播放模式
  bool _isShuffle = false;

  /// 用于频繁变化数据的流控制器
  final _positionStreamController = StreamController<Duration>.broadcast();
  final _durationStreamController = StreamController<Duration>.broadcast();
  final _playerStateStreamController =
      StreamController<AppPlayerState>.broadcast();
  final _volumeStreamController = StreamController<double>.broadcast();

  /// 单例实例
  static final AudioPlayerService _instance = AudioPlayerService._internal();

  /// 获取单例实例
  factory AudioPlayerService() => _instance;

  /// 私有构造函数
  AudioPlayerService._internal();

  /// 流获取器
  Stream<Duration> get positionStream => _positionStreamController.stream;
  Stream<Duration> get durationStream => _durationStreamController.stream;
  Stream<AppPlayerState> get playerStateStream =>
      _playerStateStreamController.stream;
  Stream<double> get volumeStream => _volumeStreamController.stream;

  /// 获取器
  AppPlayerState get playerState => _playerState;
  Duration get duration => _duration;
  Duration get position => _position;
  double get volume => _volume;
  RepeatMode get repeatMode => _repeatMode;
  bool get isShuffle => _isShuffle;

  /// 检查是否为桌面端平台（不包括web）
  bool get _isDesktop {
    return !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.linux);
  }

  /// 初始化音频播放器
  Future<void> initialize() async {
    try {
      // 检查是否为桌面端平台（不包括web）
      final isDesktop = _isDesktop;
      AppLogger().d(
          '音频播放器初始化平台检测: isDesktop=$isDesktop, kIsWeb=$kIsWeb, defaultTargetPlatform=$defaultTargetPlatform');

      if (!isDesktop) {
        // 非桌面端平台（移动端和web），初始化 just_audio 播放器
        await _initAudioPlayer();
      } else {
        // 桌面端平台，初始化 audioplayers 播放器
        await _initDesktopAudioPlayer();
      }

      AppLogger().d('✅ 音频播放器初始化完成');
    } catch (e) {
      AppLogger().e('❌ 音频播放器初始化失败: $e');
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
      }
    });

    // 监听播放位置变化 - 使用流而不是 notifyListeners
    _audioPlayer!.positionStream.listen((p) {
      _position = p;
      _positionStreamController.add(p);
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
    } else {
      // 播放完成
      _playerState = AppPlayerState.completed;
      _playerStateStreamController.add(_playerState);
    }
  }

  /// 播放指定歌曲
  /// [song] 要播放的歌曲
  Future<void> playSong(Song song) async {
    // 检查songUrl是否存在
    if (song.songUrl == null || song.songUrl!.isEmpty) {
      _playerState = AppPlayerState.stopped;
      AppLogger().e('错误: 歌曲URL为空或不存在，歌曲名称: ${song.songName}');
      AppLogger().e('歌曲URL: ${song.songUrl}');
      return;
    }

    _playerState = AppPlayerState.loading;
    _playerStateStreamController.add(_playerState);

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
    } catch (e, stackTrace) {
      AppLogger().e('播放歌曲 ${song.songName} 失败: $e');
      AppLogger().e('堆栈跟踪: $stackTrace');
      _playerState = AppPlayerState.stopped;
      _playerStateStreamController.add(_playerState);
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
    _playerStateStreamController.add(_playerState);
    AppLogger().d('使用 just_audio 成功开始播放歌曲: ${song.songName}');
    AppLogger().d('播放后音频播放器状态: ${_audioPlayer!.playerState}');
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
    _playerStateStreamController.add(_playerState);
    AppLogger().d('使用 audioplayers 成功开始播放歌曲: ${song.songName}');
  }

  /// 播放当前歌曲
  Future<void> play() async {
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
        _playerStateStreamController.add(_playerState);
        AppLogger().d('使用 just_audio 播放当前歌曲');
      } else {
        // 桌面端平台，使用 audioplayers 播放器
        if (_desktopAudioPlayer == null) {
          throw Exception('桌面端音频播放器未初始化');
        }
        await _desktopAudioPlayer!.resume();
        _playerState = AppPlayerState.playing;
        _playerStateStreamController.add(_playerState);
        AppLogger().d('使用 audioplayers 播放当前歌曲');
      }
    } catch (e) {
      AppLogger().e('播放歌曲失败: $e');
      _playerState = AppPlayerState.stopped;
      _playerStateStreamController.add(_playerState);
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
      _playerStateStreamController.add(_playerState);
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
      _playerStateStreamController.add(_playerState);
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

  /// 切换随机播放模式
  void toggleShuffle() {
    _isShuffle = !_isShuffle;
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
    } catch (e) {
      AppLogger().e('设置音量失败: $e');
    }
  }

  /// 准备音频播放器但不自动播放
  Future<void> preparePlayer(Song song) async {
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
          _playerStateStreamController.add(_playerState);
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
          _playerStateStreamController.add(_playerState);
        }
      }
      AppLogger().d('✅ 音频播放器准备完成，状态: 暂停');
    } catch (e) {
      AppLogger().e('❌ 准备音频播放器失败: $e');
      _playerState = AppPlayerState.stopped;
      _playerStateStreamController.add(_playerState);
    }
  }

  /// 释放资源
  void dispose() {
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
