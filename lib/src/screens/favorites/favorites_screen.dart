import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_music_app/src/providers/auth_provider.dart';
import 'package:vibe_music_app/src/providers/music_provider.dart';
import 'package:vibe_music_app/src/screens/auth/login_screen.dart';
import 'package:vibe_music_app/src/screens/player/player_screen.dart';
import 'package:vibe_music_app/src/models/song_model.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Song> _allSongs = []; // Store all loaded songs
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _isLoadingMore = false; // Whether we're currently loading more songs
  bool _hasMoreSongs = true; // Whether there are more songs to load
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadFavoriteSongs();

    // Add scroll listener to load more songs when scrolling near the bottom
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreSongs();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.isAuthenticated && _allSongs.isEmpty) {
      _loadFavoriteSongs();
    }
  }

  void _loadFavoriteSongs() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      setState(() {
        _currentPage = 1;
        _allSongs.clear();
        _hasMoreSongs = true;
      });
      _fetchFavoriteSongs();
    }
  }

  void _loadMoreSongs() {
    if (!_isLoadingMore && _hasMoreSongs) {
      _fetchFavoriteSongs();
    }
  }

  void _fetchFavoriteSongs() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) return;

    setState(() {
      _isLoadingMore = true;
    });

    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    musicProvider
        .loadUserFavoriteSongs(
      page: _currentPage,
      size: _pageSize,
    )
        .then((newSongs) {
      setState(() {
        if (_currentPage == 1) {
          _allSongs = newSongs;
        } else {
          _allSongs.addAll(newSongs);
        }

        // If we got fewer songs than requested, we've reached the end
        if (newSongs.length < _pageSize) {
          _hasMoreSongs = false;
        } else {
          _currentPage++;
        }

        _isLoadingMore = false;
      });
    }).catchError((error) {
      setState(() {
        _isLoadingMore = false;
      });
      AppLogger().e('Error loading favorite songs: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final musicProvider = Provider.of<MusicProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
      ),
      body: Center(
        child: authProvider.isAuthenticated
            ? _buildFavoriteSongsList(musicProvider)
            : _buildLoginPrompt(),
      ),
    );
  }

  Widget _buildFavoriteSongsList(MusicProvider musicProvider) {
    // Show loading indicator if we're on the first page and still loading
    if (_allSongs.isEmpty && _isLoadingMore) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_allSongs.isEmpty) {
      return const Center(
        child: Text('您还没有收藏任何音乐'),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _allSongs.length +
          (_isLoadingMore ? 1 : 0), // Add 1 for loading indicator
      itemBuilder: (context, index) {
        // If we've reached the end and are loading more, show a loading indicator
        if (index == _allSongs.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final song = _allSongs[index];
        final coverUrl = song.coverUrl;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: coverUrl != null ? NetworkImage(coverUrl) : null,
            child: coverUrl == null ? const Icon(Icons.music_note) : null,
          ),
          title: Text(song.songName ?? 'Unknown Song'),
          subtitle: Text(song.artistName ?? 'Unknown Artist'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.favorite,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () async {
                  final success = await musicProvider.removeFromFavorites(song);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已取消收藏')),
                    );
                    // Remove the song from the local list
                    setState(() {
                      _allSongs.removeAt(index);
                    });
                  }
                },
              ),
              const Icon(Icons.play_arrow),
            ],
          ),
          onTap: () async {
            // 先播放歌曲，等待播放开始后再导航
            await musicProvider.playSong(song, playlist: _allSongs);
            // 导航到播放器页面
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PlayerScreen()),
            );
          },
        );
      },
    );
  }

  Widget _buildLoginPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.favorite,
          size: 64,
          color: Colors.grey,
        ),
        const SizedBox(height: 16),
        const Text(
          '请登录查看您的收藏音乐',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          icon: const Icon(Icons.login),
          label: const Text('去登录'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
