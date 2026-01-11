import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_music_app/src/providers/music_provider.dart';
import 'package:vibe_music_app/src/screens/player/player_screen.dart';
import 'package:vibe_music_app/src/models/song_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';
  bool _isSearching = false;
  List<Song> _searchResults = [];
  int _currentPage = 1;
  final int _pageSize = 20;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _searchSongs({bool loadMore = false}) async {
    if (_searchKeyword.isEmpty) return;

    if (!loadMore) {
      setState(() {
        _isSearching = true;
        _searchResults = [];
        _currentPage = 1;
      });
    }

    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    final songs = await musicProvider.loadSongs(
      page: _currentPage,
      size: _pageSize,
      songName: _searchKeyword,
    );

    if (mounted) {
      setState(() {
        if (loadMore) {
          _searchResults.addAll(songs);
        } else {
          _searchResults = songs;
        }
        _isSearching = false;
      });
    }
  }

  void _loadMore() {
    if (_isSearching) return;
    _currentPage++;
    _searchSongs(loadMore: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search songs, artists...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchKeyword = '';
                      _searchResults = [];
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              onChanged: (value) {
                _searchKeyword = value;
              },
              onSubmitted: (_) {
                _searchSongs();
              },
            ),
          ),
          // Search Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _searchSongs,
                icon: const Icon(Icons.search),
                label: const Text('Search'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.music_note,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Search for songs',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final song = _searchResults[index];
                          final coverUrl = song.coverUrl;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: coverUrl != null
                                  ? NetworkImage(coverUrl)
                                  : null,
                              child: coverUrl == null
                                  ? const Icon(Icons.music_note)
                                  : null,
                            ),
                            title: Text(song.songName ?? 'Unknown Song'),
                            subtitle: Text(song.artistName ?? 'Unknown Artist'),
                            trailing: const Icon(Icons.play_arrow),
                            onTap: () {
                              final musicProvider = Provider.of<MusicProvider>(
                                  context,
                                  listen: false);
                              musicProvider.playSong(song,
                                  playlist: _searchResults);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const PlayerScreen()),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
