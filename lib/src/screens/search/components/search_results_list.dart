import 'package:flutter/material.dart';
import 'package:vibe_music_app/src/models/song_model.dart';
import 'package:vibe_music_app/src/screens/search/components/search_result_item.dart';

/// 搜索结果列表组件
/// 用于显示搜索结果列表，包含加载状态和空状态
class SearchResultsList extends StatelessWidget {
  /// 是否正在搜索
  final bool isSearching;

  /// 搜索结果列表
  final List<Song> searchResults;

  /// 点击结果项回调
  final Function(Song) onResultTap;

  const SearchResultsList({
    Key? key,
    required this.isSearching,
    required this.searchResults,
    required this.onResultTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: isSearching
          ? const Center(child: CircularProgressIndicator())
          : searchResults.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.music_note,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '搜索歌曲',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final song = searchResults[index];
                    return SearchResultItem(
                      song: song,
                      onTap: onResultTap,
                    );
                  },
                ),
    );
  }
}
