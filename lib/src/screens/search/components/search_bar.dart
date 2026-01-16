import 'package:flutter/material.dart';

/// 搜索栏组件
/// 用于输入搜索关键词并提供清除功能
class CustomSearchBar extends StatelessWidget {
  /// 搜索输入控制器
  final TextEditingController controller;

  /// 搜索关键词
  final String searchKeyword;

  /// 关键词变化回调
  final Function(String) onSearchKeywordChanged;

  /// 清除搜索回调
  final Function() onClearSearch;

  /// 提交搜索回调
  final Function() onSubmitSearch;

  const CustomSearchBar({
    Key? key,
    required this.controller,
    required this.searchKeyword,
    required this.onSearchKeywordChanged,
    required this.onClearSearch,
    required this.onSubmitSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: '搜索歌曲、歌手...',
          prefixIcon: Icon(Icons.search),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: onClearSearch,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        onChanged: onSearchKeywordChanged,
        onSubmitted: (_) => onSubmitSearch(),
      ),
    );
  }
}
