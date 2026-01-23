import 'package:get/get.dart';
import 'package:flutter/material.dart';

/// Snackbar管理类
/// 用于限制Snackbar的显示频率，避免过多的提示
class SnackbarManager {
  /// 单例实例
  static final SnackbarManager _instance = SnackbarManager._internal();

  /// 获取单例实例
  factory SnackbarManager() => _instance;

  /// 私有构造函数
  SnackbarManager._internal();

  /// 最大提示次数
  static const int MAX_SNACKBAR_COUNT = 6;

  /// 重置时间间隔（毫秒），超过此时间间隔后计数将重置为0。
  static const int RESET_INTERVAL = 15000; // 15秒

  ///  /// 提示计数
  int _snackbarCount = 0;

  /// 上次重置时间
  DateTime? _lastResetTime;

  /// 显示Snackbar
  /// [title]: 标题
  /// [message]: 消息
  /// [icon]: 图标
  /// [duration]: 持续时间
  /// [color]: 背景颜色
  void showSnackbar({
    required String title,
    required String message,
    Icon? icon,
    Duration? duration,
    Color? color,
  }) {
    // 检查是否需要重置计数
    _checkAndResetCount();

    // 检查是否超过最大提示次数
    if (_snackbarCount >= MAX_SNACKBAR_COUNT) {
      // 超过限制，不显示提示
      return;
    }

    // 显示Snackbar
    Get.snackbar(
      title,
      message,
      icon: icon,
      duration: duration ?? Duration(seconds: 2),
      backgroundColor: color ?? Get.theme.colorScheme.primary,
      colorText: Colors.white,
    );

    // 增加计数
    _snackbarCount++;
  }

  /// 检查并重置计数
  void _checkAndResetCount() {
    final now = DateTime.now();

    if (_lastResetTime == null) {
      // 第一次使用，设置重置时间
      _lastResetTime = now;
      return;
    }

    // 检查是否超过重置时间间隔
    final timeDiff = now.difference(_lastResetTime!);
    if (timeDiff.inMilliseconds >= RESET_INTERVAL) {
      // 超过时间间隔，重置计数
      _snackbarCount = 0;
      _lastResetTime = now;
    }
  }

  /// 重置计数（手动）
  void resetCount() {
    _snackbarCount = 0;
    _lastResetTime = DateTime.now();
  }

  /// 获取当前计数
  int get currentCount => _snackbarCount;

  /// 获取是否达到最大限制
  bool get isLimitReached => _snackbarCount >= MAX_SNACKBAR_COUNT;
}
