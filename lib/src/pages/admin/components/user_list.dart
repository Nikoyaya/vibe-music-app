import 'package:flutter/material.dart';
import 'package:vibe_music_app/src/pages/admin/components/user_item.dart';

/// 用户列表组件
/// 用于显示和管理用户列表
class UserList extends StatelessWidget {
  /// 用户列表
  final List<dynamic> users;

  /// 是否正在加载
  final bool isLoading;

  /// 搜索控制器
  final TextEditingController searchController;

  /// 搜索回调
  final Function() onSearch;

  /// 清除搜索回调
  final Function() onClearSearch;

  /// 删除用户回调
  final Function(dynamic) onDeleteUser;

  const UserList({
    Key? key,
    required this.users,
    required this.isLoading,
    required this.searchController,
    required this.onSearch,
    required this.onClearSearch,
    required this.onDeleteUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 搜索
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: '搜索用户...',
              prefixIcon: Icon(Icons.search),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: onClearSearch,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onSubmitted: (_) => onSearch(),
          ),
        ),
        // 用户列表
        Expanded(
          child: isLoading && users.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : users.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people,
                            size: 64,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            searchController.text.isEmpty
                                ? '未找到用户'
                                : '没有"${searchController.text}"的结果',
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return UserItem(
                          user: user,
                          onDelete: onDeleteUser,
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
