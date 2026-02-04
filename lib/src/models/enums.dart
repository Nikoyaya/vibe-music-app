/// 播放器状态枚举
enum AppPlayerState {
  stopped, // 停止状态
  playing, // 播放状态
  paused, // 暂停状态
  loading, // 加载状态
  completed, // 完成状态
}

/// 重复模式枚举
enum RepeatMode {
  none, // 不重复
  all, // 全部重复
  one, // 单曲重复
}
