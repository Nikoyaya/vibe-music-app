import 'dart:async';
import 'package:get/get.dart';
import 'package:vibe_music_app/src/controllers/music_controller.dart';
import 'package:vibe_music_app/src/controllers/auth_controller.dart';
import 'package:vibe_music_app/src/models/song_model.dart';
import 'package:vibe_music_app/src/models/enums.dart';
import 'package:vibe_music_app/src/routes/app_routes.dart';
import 'package:vibe_music_app/src/services/localization_service.dart';

/// 播放器页面控制器
/// 管理播放器页面的状态和交互逻辑
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
  late MusicController _musicController;
  late AuthController _authController;

  // 流订阅
  late StreamSubscription<AppPlayerState> _playerStateSubscription;

  // 收藏加载状态
  final favoriteLoadingStates = <int, bool>{};

  @override
  void onInit() {
    super.onInit();
    _musicController = Get.find<MusicController>();
    _authController = Get.find<AuthController>();
    // 添加自己作为MusicController的监听器
    _musicController.addListener(_onMusicProviderChanged);
    // 直接监听播放器状态流，确保UI能及时更新
    _playerStateSubscription =
        _musicController.playerStateStream.listen((state) {
      _isPlaying.value = state == AppPlayerState.playing;
      // 强制更新UI
      update();
    });
    // 初始化可观察变量
    _updateObservableVariables();
  }

  @override
  void onClose() {
    // 移除自己作为MusicController的监听器
    _musicController.removeListener(_onMusicProviderChanged);
    // 取消流订阅
    _playerStateSubscription.cancel();
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
    // 当播放列表为空时，确保_currentSong被设置为null
    if (_musicController.playlist.isEmpty) {
      _currentSong.value = null;
      _isPlaying.value = false;
      _playlist.value = [];
      _currentIndex.value = 0;
    } else {
      _currentSong.value = _musicController.currentSong;
      _isPlaying.value = _musicController.playerState == AppPlayerState.playing;
      // 创建播放列表的副本，确保UI检测到变化
      _playlist.value = [..._musicController.playlist];
      _currentIndex.value = _musicController.currentIndex;
    }
    _isShuffle.value = _musicController.isShuffle;
    switch (_musicController.repeatMode) {
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
    _volume.value = _musicController.volume;
  }

  /// 强制刷新播放列表UI
  /// 当收藏状态变化时调用，确保UI正确显示收藏图标
  void refreshPlaylistUI() {
    // 通过重新赋值播放列表来强制UI刷新
    _playlist.value = [..._musicController.playlist];
    // 通知GetX刷新UI
    update();
  }

  /// 切换收藏状态
  Future<void> toggleFavorite() async {
    if (_musicController.currentSong == null) return;

    if (!_authController.isAuthenticated) {
      Get.snackbar(LocalizationService.instance.tip,
          LocalizationService.instance.pleaseLogin);
      Get.toNamed(AppRoutes.login);
      return;
    }

    final song = _musicController.currentSong!;

    // 检查歌曲是否有id
    if (song.id == null) {
      Get.snackbar(LocalizationService.instance.tip, '歌曲信息不完整，无法收藏');
      return;
    }

    // 检查是否正在加载
    final isLoading = favoriteLoadingStates[song.id!] ?? false;
    if (isLoading) return;

    // 设置加载状态
    favoriteLoadingStates[song.id!] = true;
    update();

    bool success;

    if (_musicController.isSongFavorited(song)) {
      success = await _musicController.removeFromFavorites(song);
      if (success) {
        Get.snackbar(LocalizationService.instance.success,
            LocalizationService.instance.removedFromFavorites);
        // 强制刷新UI，确保收藏状态正确显示
        refreshPlaylistUI();
      }
    } else {
      success = await _musicController.addToFavorites(song);
      if (success) {
        Get.snackbar(LocalizationService.instance.success,
            LocalizationService.instance.addedToFavorites,
            duration: const Duration(seconds: 1));
        // 强制刷新UI，确保收藏状态正确显示
        refreshPlaylistUI();
      }
    }

    // 重置加载状态
    favoriteLoadingStates[song.id!] = false;
    // 更新UI
    update(['playerCover', 'playerSongInfo', 'favoriteButton']);
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
    double newVolume = _musicController.volume - delta * sensitivity;
    newVolume = newVolume.clamp(0.0, 1.0);
    _musicController.setVolume(newVolume);

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
    if (index >= 0 && index < _musicController.playlist.length) {
      _musicController.playSong(_musicController.playlist[index]);
    }
  }

  /// 处理播放列表中歌曲的收藏状态切换
  Future<void> handlePlaylistFavoriteToggle(Song song) async {
    if (!_authController.isAuthenticated) {
      Get.snackbar(LocalizationService.instance.tip,
          LocalizationService.instance.pleaseLogin);
      Get.toNamed(AppRoutes.login);
      return;
    }

    // 检查歌曲是否有id
    if (song.id == null) {
      Get.snackbar(LocalizationService.instance.tip, '歌曲信息不完整，无法收藏');
      return;
    }

    // 检查是否正在加载
    final isLoading = favoriteLoadingStates[song.id!] ?? false;
    if (isLoading) return;

    // 设置加载状态
    favoriteLoadingStates[song.id!] = true;
    update();

    bool success;
    if (_musicController.isSongFavorited(song)) {
      success = await _musicController.removeFromFavorites(song);
      if (success) {
        Get.snackbar(LocalizationService.instance.success,
            LocalizationService.instance.removedFromFavorites);
        // 强制刷新UI，确保收藏状态正确显示
        refreshPlaylistUI();
      }
    } else {
      success = await _musicController.addToFavorites(song);
      if (success) {
        Get.snackbar(LocalizationService.instance.success,
            LocalizationService.instance.addedToFavorites,
            duration: const Duration(seconds: 1));
        // 强制刷新UI，确保收藏状态正确显示
        refreshPlaylistUI();
      }
    }

    // 重置加载状态
    favoriteLoadingStates[song.id!] = false;
    // 更新UI
    update(['playerCover', 'playerSongInfo', 'favoriteButton']);
  }

  /// 检查歌曲是否已收藏
  bool isSongFavorited(Song song) {
    return _musicController.isSongFavorited(song);
  }

  /// 从播放列表移除歌曲
  void removeFromPlaylist(int index) {
    _musicController.removeFromPlaylist(index);
    // 更新本地状态
    _updateObservableVariables();
  }

  /// 清空播放列表
  void clearPlaylist() {
    _musicController.clearPlaylist();
    // 更新本地状态
    _updateObservableVariables();
    // 通知所有GetBuilder更新UI，特别是指定了id的组件
    update();
    // 确保更新特定的UI组件
    update(['playerCover', 'playerSongInfo', 'playerControls']);
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
    return _musicController.positionStream;
  }

  /// 获取时长流
  Stream<Duration> get durationStream {
    return _musicController.durationStream;
  }

  /// 获取音量流
  Stream<double> get volumeStream {
    return _musicController.volumeStream;
  }

  /// 获取当前时长
  Duration get duration {
    return _musicController.duration;
  }

  /// 播放
  Future<void> play() async {
    await _musicController.play();
  }

  /// 暂停
  Future<void> pause() async {
    await _musicController.pause();
  }

  /// 上一首
  void previous() {
    _musicController.previous();
  }

  /// 下一首
  void next() {
    _musicController.next();
  }

  /// 切换随机播放
  void toggleShuffle() {
    _musicController.toggleShuffle();
  }

  /// 切换重复模式
  void toggleRepeat() {
    _musicController.toggleRepeat();
  }

  /// 设置音量
  void setVolume(double value) {
    _musicController.setVolume(value);
  }

  /// 跳转到指定位置
  Future<void> seekTo(Duration position) async {
    await _musicController.seekTo(position);
  }
}
