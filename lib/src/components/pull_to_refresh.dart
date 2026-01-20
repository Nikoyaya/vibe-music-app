import 'package:flutter/material.dart';

/// 通用下拉刷新组件
///
/// 用于实现下拉刷新功能，可在多个页面复用
/// 基于Flutter内置的RefreshIndicator组件封装
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

  /// 通用下拉刷新构造函数
  ///
  /// [参数说明]:
  /// - [child]: 下拉刷新包裹的子组件
  /// - [onRefresh]: 刷新时的回调函数，返回Future
  /// - [refreshText]: 刷新时的提示文本，默认'下拉刷新'
  /// - [refreshSuccessText]: 刷新成功时的提示文本，默认'刷新成功'
  /// - [refreshFailedText]: 刷新失败时的提示文本，默认'刷新失败'
  /// - [refreshColor]: 刷新指示器颜色，默认使用主题的primary颜色
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

  /// 处理刷新逻辑
  ///
  /// 1. 检查是否正在刷新，如果是则直接返回
  /// 2. 设置刷新状态为true
  /// 3. 调用外部传入的刷新回调函数
  /// 4. 根据回调结果调用刷新控制器的success或error方法
  /// 5. 最终设置刷新状态为false
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
      // 刷新回调
      onRefresh: _handleRefresh,
      // 刷新指示器颜色
      color: widget.refreshColor ?? Theme.of(context).colorScheme.primary,
      // 刷新指示器背景色
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      // 刷新指示器位移
      displacement: 80,
      // 刷新指示器线宽
      strokeWidth: 3,
      // 子组件
      child: widget.child,
    );
  }
}

/// 刷新控制器类
///
/// 用于控制刷新状态和动画
/// 提供刷新成功、失败和完成的方法
class RefreshController {
  /// 刷新成功
  ///
  /// 调用此方法表示刷新操作成功完成
  void success() {
    // 可以在这里添加刷新成功的逻辑
  }

  /// 刷新失败
  ///
  /// 调用此方法表示刷新操作失败
  void error() {
    // 可以在这里添加刷新失败的逻辑
  }

  /// 完成刷新
  ///
  /// 调用此方法表示刷新操作完成，无论成功或失败
  void complete() {
    // 可以在这里添加完成刷新的逻辑
  }
}
