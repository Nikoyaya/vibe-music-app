import 'package:flutter/material.dart';

/// 用户项组件
/// 用于显示单个用户信息
class UserItem extends StatelessWidget {
  /// 用户信息
  final dynamic user;
  /// 删除用户回调
  final Function(dynamic) onDelete;

  const UserItem({
    Key? key,
    required this.user,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          (user['username']?[0] ?? 'U')
              .toString()
              .toUpperCase(),
        ),
      ),
      title: Text(user['username'] ?? '未知'),
      subtitle: Text(user['email'] ?? ''),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(
            label:
                Text(user['role'] == 1 ? '管理员' : '用户'),
            backgroundColor: user['role'] == 1
                ? Theme.of(context)
                    .colorScheme
                    .primaryContainer
                : Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => onDelete(user),
          ),
        ],
      ),
    );
  }
}