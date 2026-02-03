import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/generated/app_localizations.dart';
import 'package:vibe_music_app/src/pages/search/widgets/controller.dart';
import 'package:vibe_music_app/src/components/common_button.dart';
import 'package:vibe_music_app/src/components/common_card.dart';
import 'package:vibe_music_app/src/components/common_loading.dart';
import 'package:vibe_music_app/src/pages/search/components/search_bar.dart';
import 'package:vibe_music_app/src/providers/music_controller.dart';

class SearchView extends GetView<SearchPageController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.search ?? '搜索'),
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
                  text: AppLocalizations.of(context)?.search ?? '搜索',
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
                return CommonLoading(
                    text: AppLocalizations.of(context)?.loading ?? '搜索中...');
              } else if (controller.searchResults.isEmpty) {
                // 检查是否有搜索关键词
                if (controller.searchKeyword.value.isNotEmpty) {
                  // 有搜索关键词但无结果
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)?.noResults ?? '没有找到结果',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '"${controller.searchKeyword.value}"',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // 没有搜索关键词
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
                          AppLocalizations.of(context)?.search ?? '搜索歌曲',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                }
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
                                  song.artistName ??
                                      (AppLocalizations.of(context)?.artist ??
                                          '未知艺术家'),
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
                          // 更多按钮
                          IconButton(
                            icon: Icon(
                              Icons.more_vert,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            onPressed: () {
                              // 显示更多选项菜单
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: Icon(Icons.queue_play_next),
                                          title: Text(
                                              AppLocalizations.of(context)
                                                      ?.playNext ??
                                                  '下一首播放'),
                                          onTap: () {
                                            // 添加到下一首播放
                                            Get.find<MusicController>()
                                                .insertNextToPlay(song);
                                            Get.snackbar(
                                              AppLocalizations.of(context)
                                                      ?.success ??
                                                  '成功',
                                              AppLocalizations.of(context)
                                                      ?.addedToNextPlay ??
                                                  '已添加到下一首播放',
                                              backgroundColor: Colors.green,
                                              colorText: Colors.white,
                                              icon: Icon(Icons.check_circle,
                                                  color: Colors.white),
                                              duration: Duration(seconds: 2),
                                            );
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
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
