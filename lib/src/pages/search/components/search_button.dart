import 'package:flutter/material.dart';

/// 搜索按钮组件
/// 用于触发搜索操作
class SearchButton extends StatelessWidget {
  /// 搜索回调
  final Function() onSearch;

  const SearchButton({
    Key? key,
    required this.onSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: onSearch,
          icon: Icon(Icons.search),
          label: Text('搜索'),
        ),
      ),
    );
  }
}
