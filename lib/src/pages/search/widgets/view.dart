import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/src/pages/search/widgets/controller.dart';
import 'package:vibe_music_app/src/components/common_button.dart';
import 'package:vibe_music_app/src/components/common_card.dart';
import 'package:vibe_music_app/src/components/common_loading.dart';
import 'package:vibe_music_app/src/pages/search/components/search_bar.dart';

class SearchView extends GetView<SearchPageController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('搜索'),
      ),
      body: Column(
        children: [
          // 搜索栏
          Obx(() => CustomSearchBar(
                controller: controller.searchController,
                searchKeyword: controller.searchKeyword.value,
                onSearchKeywordChanged: (value) {
                  controller.searchKeyword.value = value;
                },
                onClearSearch: controller.clearSearch,
                onSubmitSearch: () => controller.searchSongs(),
              )),
          // 搜索按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() => CommonButton(
                  text: '搜索',
                  onPressed: () => controller.searchSongs(),
                  isLoading: controller.isSearching.value,
                  icon: const Icon(Icons.search),
                )),
          ),
          const SizedBox(height: 16),
          // 搜索结果列表
          Expanded(
            child: Obx(() {
              if (controller.isSearching.value) {
                return const CommonLoading(text: '搜索中...');
              } else if (controller.searchResults.isEmpty) {
                return Center(
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
                );
              } else {
                return ListView.builder(
                  controller: controller.scrollController,
                  itemCount: controller.searchResults.length,
                  itemBuilder: (context, index) {
                    final song = controller.searchResults[index];
                    final coverUrl = song.coverUrl;
                    final isFavorited = controller.isSongFavorited(song);

                    return CommonCard(
                      onTap: () => controller.handleResultTap(song),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // 歌曲封面
                          CircleAvatar(
                            backgroundImage: coverUrl != null
                                ? NetworkImage(coverUrl)
                                : null,
                            child: coverUrl == null
                                ? Icon(Icons.music_note)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          // 歌曲信息
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.songName ?? '未知歌曲',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  song.artistName ?? '未知艺术家',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // 收藏按钮
                          IconButton(
                            icon: Icon(
                              isFavorited
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorited
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                            onPressed: () => controller.handleFavoriteTap(song),
                          ),
                          // 播放按钮
                          Icon(Icons.play_arrow,
                              color: Theme.of(context).colorScheme.primary),
                        ],
                      ),
                    );
                  },
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
