import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_music_app/src/providers/music_provider.dart';
import 'package:vibe_music_app/src/screens/player/player_screen.dart';
import 'package:vibe_music_app/src/models/song_model.dart';
import 'package:vibe_music_app/src/screens/search/components/search_bar.dart';
import 'package:vibe_music_app/src/screens/search/components/search_button.dart';
import 'package:vibe_music_app/src/screens/search/components/search_results_list.dart';

/// 搜索屏幕
/// 用于搜索歌曲
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  /// 搜索输入控制器
  final TextEditingController _searchController = TextEditingController();

  /// 搜索关键词
  String _searchKeyword = '';

  /// 是否正在搜索
  bool _isSearching = false;

  /// 搜索结果列表
  List<Song> _searchResults = [];

  /// 当前页码
  int _currentPage = 1;

  /// 每页大小
  final int _pageSize = 20;

  /// 滚动控制器，用于实现下拉加载更多
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 搜索歌曲
  /// [loadMore]: 是否加载更多数据
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

  /// 清除搜索
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchKeyword = '';
      _searchResults = [];
    });
  }

  /// 处理搜索结果点击
  void _handleResultTap(Song song) {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    musicProvider.playSong(song, playlist: _searchResults);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PlayerScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('搜索'),
      ),
      body: Column(
        children: [
          // 搜索栏
          CustomSearchBar(
            controller: _searchController,
            searchKeyword: _searchKeyword,
            onSearchKeywordChanged: (value) {
              _searchKeyword = value;
            },
            onClearSearch: _clearSearch,
            onSubmitSearch: _searchSongs,
          ),
          // 搜索按钮
          SearchButton(
            onSearch: _searchSongs,
          ),
          const SizedBox(height: 16),
          // 搜索结果列表
          SearchResultsList(
            isSearching: _isSearching,
            searchResults: _searchResults,
            onResultTap: _handleResultTap,
          ),
        ],
      ),
    );
  }
}
