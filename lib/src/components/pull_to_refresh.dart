import 'package:flutter/material.dart';

/// 通用下拉刷新组件
/// 用于实现下拉刷新功能，可在多个页面复用
class PullToRefresh extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 刷新回调函数
  final Future<void> Function() onRefresh;

  /// 刷新时的提示文本
  final String refreshText;

  /// 刷新成功时的提示文本
  final String refreshSuccessText;

  /// 刷新失败时的提示文本
  final String refreshFailedText;

  /// 刷新指示器颜色
  final Color? refreshColor;

  const PullToRefresh({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.refreshText = '下拉刷新',
    this.refreshSuccessText = '刷新成功',
    this.refreshFailedText = '刷新失败',
    this.refreshColor,
  }) : super(key: key);

  @override
  State<PullToRefresh> createState() => _PullToRefreshState();
}

class _PullToRefreshState extends State<PullToRefresh> {
  /// 刷新控制器
  final RefreshController _refreshController = RefreshController();

  /// 刷新状态
  bool _isRefreshing = false;

  @override
  void dispose() {
    super.dispose();
  }

  /// 处理刷新
  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await widget.onRefresh();
      _refreshController.success();
    } catch (e) {
      _refreshController.error();
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: widget.refreshColor ?? Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      displacement: 80,
      strokeWidth: 3,
      child: widget.child,
    );
  }
}

/// 刷新控制器类
/// 用于控制刷新状态和动画
class RefreshController {
  /// 刷新成功
  void success() {
    // 可以在这里添加刷新成功的逻辑
  }

  /// 刷新失败
  void error() {
    // 可以在这里添加刷新失败的逻辑
  }

  /// 完成刷新
  void complete() {
    // 可以在这里添加完成刷新的逻辑
  }
}
