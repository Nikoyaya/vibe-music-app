import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vibe_music_app/src/services/api_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _currentTab = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // User management
  List<dynamic> _users = [];
  int _userPage = 1;
  int _userTotal = 0;
  final int _userPageSize = 10;
  final TextEditingController _userSearchController = TextEditingController();

  // Song management
  List<dynamic> _songs = [];
  int _songPage = 1;
  int _songTotal = 0;
  final int _songPageSize = 10;
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
            _errorMessage = data['msg'] ?? 'Failed to load users';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Network error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
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
            _errorMessage = data['msg'] ?? 'Failed to load songs';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Network error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
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
          // Tab Bar
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
              Tab(text: 'Users'),
              Tab(text: 'Songs'),
            ],
          ),
          // Content
          Expanded(
            child: _currentTab == 0 ? _buildUserTab() : _buildSongTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTab() {
    return Column(
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _userSearchController,
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _userSearchController.clear();
                  _loadUsers();
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onSubmitted: (_) => _loadUsers(),
          ),
        ),
        // User List
        Expanded(
          child: _isLoading && _users.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _users.isEmpty
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
                            _userSearchController.text.isEmpty
                                ? 'No users found'
                                : 'No results for "${_userSearchController.text}"',
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              (user['username']?[0] ?? 'U')
                                  .toString()
                                  .toUpperCase(),
                            ),
                          ),
                          title: Text(user['username'] ?? 'Unknown'),
                          subtitle: Text(user['email'] ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                label:
                                    Text(user['role'] == 1 ? 'Admin' : 'User'),
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
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _showDeleteUserDialog(user),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildSongTab() {
    return Column(
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _songSearchController,
            decoration: InputDecoration(
              hintText: 'Search songs...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _songSearchController.clear();
                  _loadSongs();
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onSubmitted: (_) => _loadSongs(),
          ),
        ),
        // Song List
        Expanded(
          child: _isLoading && _songs.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _songs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.music_note,
                            size: 64,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _songSearchController.text.isEmpty
                                ? 'No songs found'
                                : 'No results for "${_songSearchController.text}"',
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _songs.length,
                      itemBuilder: (context, index) {
                        final song = _songs[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: song['coverUrl'] != null
                                ? NetworkImage(song['coverUrl'])
                                : null,
                            child: song['coverUrl'] == null
                                ? const Icon(Icons.music_note)
                                : null,
                          ),
                          title: Text(song['songName'] ?? 'Unknown Song'),
                          subtitle:
                              Text(song['artistName'] ?? 'Unknown Artist'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${song['playCount'] ?? 0} plays'),
                              const SizedBox(width: 8),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _showDeleteSongDialog(song),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  void _showDeleteUserDialog(dynamic user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete "${user['username']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Implement delete user logic
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteSongDialog(dynamic song) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Song'),
        content: Text('Are you sure you want to delete "${song['songName']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Implement delete song logic
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
