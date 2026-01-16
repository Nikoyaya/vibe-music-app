import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vibe_music_app/src/services/api_service.dart';
import 'package:vibe_music_app/src/screens/admin/components/user_list.dart';
import 'package:vibe_music_app/src/screens/admin/components/song_list.dart';

/// 管理面板屏幕
/// 用于管理用户和歌曲
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  /// 当前选中的标签页
  int _currentTab = 0;

  /// 是否正在加载数据
  bool _isLoading = false;

  /// 错误消息
  String? _errorMessage;

  /// 用户管理
  List<dynamic> _users = [];

  /// 用户页码
  int _userPage = 1;

  /// 用户总数
  int _userTotal = 0;

  /// 用户每页大小
  final int _userPageSize = 10;

  /// 用户搜索控制器
  final TextEditingController _userSearchController = TextEditingController();

  /// 歌曲管理
  List<dynamic> _songs = [];

  /// 歌曲页码
  int _songPage = 1;

  /// 歌曲总数
  int _songTotal = 0;

  /// 歌曲每页大小
  final int _songPageSize = 10;

  /// 歌曲搜索控制器
  final TextEditingController _songSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers({bool loadMore = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (!loadMore) {
      _userPage = 1;
    }

    try {
      final response = await ApiService().getAllUsers(
        _userPage,
        _userPageSize,
        _userSearchController.text.isNotEmpty
            ? _userSearchController.text
            : null,
      );

      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : jsonDecode(response.data);
        if (data['code'] == 1) {
          setState(() {
            if (loadMore) {
              _users.addAll(data['data']['records'] ?? []);
            } else {
              _users = data['data']['records'] ?? [];
            }
            _userTotal = data['data']['total'] ?? 0;
          });
        } else {
          setState(() {
            _errorMessage = data['msg'] ?? '加载用户失败';
          });
        }
      } else {
        setState(() {
          _errorMessage = '网络错误: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '错误: $e';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadSongs({bool loadMore = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (!loadMore) {
      _songPage = 1;
    }

    try {
      final response = await ApiService().getAllSongs(
        _songPage,
        _songPageSize,
        songName: _songSearchController.text.isNotEmpty
            ? _songSearchController.text
            : null,
      );

      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : jsonDecode(response.data);
        if (data['code'] == 1) {
          setState(() {
            if (loadMore) {
              _songs.addAll(data['data']['records'] ?? []);
            } else {
              _songs = data['data']['records'] ?? [];
            }
            _songTotal = data['data']['total'] ?? 0;
          });
        } else {
          setState(() {
            _errorMessage = data['msg'] ?? '加载歌曲失败';
          });
        }
      } else {
        setState(() {
          _errorMessage = '网络错误: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '错误: $e';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  /// 清除用户搜索
  void _clearUserSearch() {
    _userSearchController.clear();
    _loadUsers();
  }

  /// 清除歌曲搜索
  void _clearSongSearch() {
    _songSearchController.clear();
    _loadSongs();
  }

  /// 处理删除用户
  void _handleDeleteUser(dynamic user) {
    _showDeleteUserDialog(user);
  }

  /// 处理删除歌曲
  void _handleDeleteSong(dynamic song) {
    _showDeleteSongDialog(song);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('管理面板'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              if (_currentTab == 0) {
                _loadUsers();
              } else {
                _loadSongs();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 标签栏
          TabBar(
            onTap: (index) {
              setState(() {
                _currentTab = index;
                if (index == 0 && _users.isEmpty) {
                  _loadUsers();
                } else if (index == 1 && _songs.isEmpty) {
                  _loadSongs();
                }
              });
            },
            tabs: const [
              Tab(text: '用户'),
              Tab(text: '歌曲'),
            ],
          ),
          // 内容
          Expanded(
            child: _currentTab == 0
                ? UserList(
                    users: _users,
                    isLoading: _isLoading,
                    searchController: _userSearchController,
                    onSearch: _loadUsers,
                    onClearSearch: _clearUserSearch,
                    onDeleteUser: _handleDeleteUser,
                  )
                : SongList(
                    songs: _songs,
                    isLoading: _isLoading,
                    searchController: _songSearchController,
                    onSearch: _loadSongs,
                    onClearSearch: _clearSongSearch,
                    onDeleteSong: _handleDeleteSong,
                  ),
          ),
        ],
      ),
    );
  }

  /// 显示删除用户对话框
  void _showDeleteUserDialog(dynamic user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('删除用户'),
        content: Text('确定要删除 "${user['username']}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // 实现删除用户逻辑
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 显示删除歌曲对话框
  void _showDeleteSongDialog(dynamic song) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('删除歌曲'),
        content: Text('确定要删除 "${song['songName']}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // 实现删除歌曲逻辑
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('删除'),
          ),
        ],
      ),
    );
  }
}