import 'package:flutter/material.dart';
import 'package:vibe_music_app/src/screens/admin/components/song_item.dart';

/// 歌曲列表组件
/// 用于显示和管理歌曲列表
class SongList extends StatelessWidget {
  /// 歌曲列表
  final List<dynamic> songs;
  /// 是否正在加载
  final bool isLoading;
  /// 搜索控制器
  final TextEditingController searchController;
  /// 搜索回调
  final Function() onSearch;
  /// 清除搜索回调
  final Function() onClearSearch;
  /// 删除歌曲回调
  final Function(dynamic) onDeleteSong;

  const SongList({
    Key? key,
    required this.songs,
    required this.isLoading,
    required this.searchController,
    required this.onSearch,
    required this.onClearSearch,
    required this.onDeleteSong,
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
              hintText: '搜索歌曲...',
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
        // 歌曲列表
        Expanded(
          child: isLoading && songs.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : songs.isEmpty
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
                            searchController.text.isEmpty
                                ? '未找到歌曲'
                                : '没有"${searchController.text}"的结果',
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        return SongItem(
                          song: song,
                          onDelete: onDeleteSong,
                        );
                      },
                    ),
        ),
      ],
    );
  }
}