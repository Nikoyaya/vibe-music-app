import 'package:get/get.dart';
import 'package:vibe_music_app/src/providers/music_provider.dart';
import 'package:vibe_music_app/src/providers/auth_provider.dart';
import 'package:vibe_music_app/src/models/song_model.dart';

class PlayerController extends GetxController {
  // 状态
  var isExpanded = false.obs;
  var showVolumeIndicator = false.obs;
  var _currentSong = Rxn<Song>();
  var _isPlaying = false.obs;
  var _isShuffle = false.obs;
  var _repeatMode = 'none'.obs;
  var _volume = 0.5.obs;
  var _playlist = <Song>[].obs;
  var _currentIndex = 0.obs;

  // 提供者
  late MusicProvider _musicProvider;
  late AuthProvider _authProvider;

  @override
  void onInit() {
    super.onInit();
    _musicProvider = Get.find<MusicProvider>();
    _authProvider = Get.find<AuthProvider>();
    // 添加自己作为MusicProvider的监听器
    _musicProvider.addListener(_onMusicProviderChanged);
    // 初始化可观察变量
    _updateObservableVariables();
  }

  @override
  void onClose() {
    // 移除自己作为MusicProvider的监听器
    _musicProvider.removeListener(_onMusicProviderChanged);
    super.onClose();
  }

  /// 当MusicProvider状态变化时调用
  void _onMusicProviderChanged() {
    // 更新可观察变量
    _updateObservableVariables();
    // 通知GetX刷新UI
    update();
  }

  /// 更新可观察变量
  void _updateObservableVariables() {
    _currentSong.value = _musicProvider.currentSong;
    _isPlaying.value = _musicProvider.playerState == AppPlayerState.playing;
    _isShuffle.value = _musicProvider.isShuffle;
    switch (_musicProvider.repeatMode) {
      case RepeatMode.one:
        _repeatMode.value = 'one';
        break;
      case RepeatMode.all:
        _repeatMode.value = 'all';
        break;
      default:
        _repeatMode.value = 'none';
        break;
    }
    _volume.value = _musicProvider.volume;
    _playlist.value = _musicProvider.playlist;
    _currentIndex.value = _musicProvider.currentIndex;
  }

  /// 切换收藏状态
  Future<void> toggleFavorite() async {
    if (_musicProvider.currentSong == null) return;

    if (!_authProvider.isAuthenticated) {
      Get.snackbar('提示', '请先登录');
      Get.toNamed('/login');
      return;
    }

    final song = _musicProvider.currentSong!;
    bool success;

    if (_musicProvider.isSongFavorited(song)) {
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

  /// 切换播放列表展开状态
  void togglePlaylistExpanded() {
    isExpanded.value = !isExpanded.value;
  }

  /// 切换音量指示器显示状态
  void toggleVolumeIndicator() {
    showVolumeIndicator.value = !showVolumeIndicator.value;
  }

  /// 调整音量
  void adjustVolume(double delta) {
    const sensitivity = 0.005;
    double newVolume = _musicProvider.volume - delta * sensitivity;
    newVolume = newVolume.clamp(0.0, 1.0);
    _musicProvider.setVolume(newVolume);

    if (!showVolumeIndicator.value) {
      showVolumeIndicator.value = true;

      // 3秒后隐藏指示器
      Future.delayed(const Duration(seconds: 3), () {
        showVolumeIndicator.value = false;
      });
    }
  }

  /// 播放指定歌曲
  void playSongAtIndex(int index) {
    if (index >= 0 && index < _musicProvider.playlist.length) {
      _musicProvider.playSong(_musicProvider.playlist[index]);
    }
  }

  /// 处理播放列表中歌曲的收藏状态切换
  Future<void> handlePlaylistFavoriteToggle(Song song) async {
    if (!_authProvider.isAuthenticated) {
      Get.snackbar('提示', '请先登录');
      Get.toNamed('/login');
      return;
    }

    bool success;
    if (_musicProvider.isSongFavorited(song)) {
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

  /// 获取当前播放状态
  bool get isPlaying {
    return _isPlaying.value;
  }

  /// 获取随机播放状态
  bool get isShuffle {
    return _isShuffle.value;
  }

  /// 获取重复模式
  String get repeatMode {
    return _repeatMode.value;
  }

  /// 获取音量
  double get volume {
    return _volume.value;
  }

  /// 获取当前歌曲
  Song? get currentSong {
    return _currentSong.value;
  }

  /// 获取播放列表
  List<Song> get playlist {
    return _playlist.value;
  }

  /// 获取当前播放索引
  int get currentIndex {
    return _currentIndex.value;
  }

  /// 获取播放位置流
  Stream<Duration> get positionStream {
    return _musicProvider.positionStream;
  }

  /// 获取时长流
  Stream<Duration> get durationStream {
    return _musicProvider.durationStream;
  }

  /// 获取音量流
  Stream<double> get volumeStream {
    return _musicProvider.volumeStream;
  }

  /// 获取当前时长
  Duration get duration {
    return _musicProvider.duration;
  }

  /// 播放
  Future<void> play() async {
    await _musicProvider.play();
  }

  /// 暂停
  Future<void> pause() async {
    await _musicProvider.pause();
  }

  /// 上一首
  void previous() {
    _musicProvider.previous();
  }

  /// 下一首
  void next() {
    _musicProvider.next();
  }

  /// 切换随机播放
  void toggleShuffle() {
    _musicProvider.toggleShuffle();
  }

  /// 切换重复模式
  void toggleRepeat() {
    _musicProvider.toggleRepeat();
  }

  /// 设置音量
  void setVolume(double value) {
    _musicProvider.setVolume(value);
  }

  /// 跳转到指定位置
  Future<void> seekTo(Duration position) async {
    await _musicProvider.seekTo(position);
  }
}
