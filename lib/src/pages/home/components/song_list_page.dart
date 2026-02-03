import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vibe_music_app/generated/app_localizations.dart';
import 'package:vibe_music_app/src/providers/auth_provider.dart';
import 'package:vibe_music_app/src/providers/music_provider.dart';
import 'package:vibe_music_app/src/models/song_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:vibe_music_app/src/components/pull_to_refresh.dart';
import 'package:vibe_music_app/src/services/image_preload_service.dart';
import 'package:vibe_music_app/src/utils/snackbar_manager.dart';
import 'package:vibe_music_app/src/routes/app_routes.dart';
import 'package:vibe_music_app/src/utils/glass_morphism/responsive_layout.dart';

/// 歌曲列表页面
class SongListPage extends StatefulWidget {
  const SongListPage({super.key});

  @override
  State<SongListPage> createState() => _SongListPageState();
}

/// 歌曲列表类型枚举
enum SongListType {
  recommended, // 推荐歌曲
  favorite, // 收藏歌曲
}

/// 轮播图数据模型
class CarouselItem {
  final String imageUrl; // 图片URL
  final String title; // 标题
  final String description; // 描述

  CarouselItem({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}

/// 歌单数据模型
class PlaylistItem {
  final String imageUrl; // 图片URL
  final String title; // 标题
  final String playCount; // 播放次数

  PlaylistItem({
    required this.imageUrl,
    required this.title,
    required this.playCount,
  });
}

class _SongListPageState extends State<SongListPage> {
  late Future<List<Song>> _futureSongs; // 歌曲数据未来
  final SongListType _currentType = SongListType.recommended; // 当前歌曲列表类型
  final Map<int, bool> _favoriteLoadingStates = {}; // 收藏操作加载状态

  /// 轮播图数据
  final List<CarouselItem> _carouselItems = [
    CarouselItem(
      imageUrl: 'https://picsum.photos/id/1015/800/400',
      title: '一周欧美上新',
      description: '编辑精选最新欧美热歌，每周更新',
    ),
    CarouselItem(
      imageUrl: 'https://picsum.photos/id/1019/800/400',
      title: '经典华语歌曲',
      description: '华语音乐黄金时代，永恒的经典',
    ),
    CarouselItem(
      imageUrl: 'https://picsum.photos/id/1025/800/400',
      title: '日韩流行音乐',
      description: '最新日韩流行歌曲，引领潮流',
    ),
  ];

  /// 推荐歌单数据
  final List<PlaylistItem> _recommendedPlaylists = [
    PlaylistItem(
      imageUrl: 'https://picsum.photos/id/1/300/300',
      title: '[1963-至今] 日本经典动漫音乐大盘点',
      playCount: '3164.1万',
    ),
    PlaylistItem(
      imageUrl: 'https://picsum.photos/id/2/300/300',
      title: '武侠影视金曲100首 | 每个人心中的江湖梦',
      playCount: '3218.0万',
    ),
    PlaylistItem(
      imageUrl: 'https://picsum.photos/id/3/300/300',
      title: '华语青春 | 90后校园岁月的流行歌曲',
      playCount: '3233.7万',
    ),
    PlaylistItem(
      imageUrl: 'https://picsum.photos/id/4/300/300',
      title: '经典粤语合集【无损音质】',
      playCount: '9184.6万',
    ),
    PlaylistItem(
      imageUrl: 'https://picsum.photos/id/5/300/300',
      title: '世界古典钢琴音乐珍藏',
      playCount: '4021.7万',
    ),
    PlaylistItem(
      imageUrl: 'https://picsum.photos/id/6/300/300',
      title: '一周日语上新 | アニメソング',
      playCount: '9841.9万',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // 在initState中只加载一次歌曲数据
    _loadSongs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 预加载轮播图和推荐歌单图片
    _preloadImages();
  }

  /// 预加载图片
  void _preloadImages() {
    // 预加载轮播图图片
    if (_carouselItems.isNotEmpty) {
      ImagePreloadService().preloadCarouselImages(_carouselItems, context);
    }
    // 预加载推荐歌单图片
    if (_recommendedPlaylists.isNotEmpty) {
      ImagePreloadService()
          .preloadPlaylistImages(_recommendedPlaylists, context);
    }
  }

  /// 加载歌曲数据
  void _loadSongs() {
    final musicProvider = Get.find<MusicProvider>();
    setState(() {
      if (_currentType == SongListType.recommended) {
        _futureSongs = musicProvider.loadRecommendedSongs().then((songs) {
          // 预加载歌曲封面图片
          ImagePreloadService().preloadSongCovers(songs, context);
          return songs;
        });
      } else {
        _futureSongs = musicProvider.loadUserFavoriteSongs().then((songs) {
          // 预加载歌曲封面图片
          ImagePreloadService().preloadSongCovers(songs, context);
          return songs;
        });
      }
    });
  }

  /// 处理下拉刷新
  Future<void> _handleRefresh() async {
    // 重新加载歌曲数据
    _loadSongs();
    // 等待数据加载完成
    await _futureSongs;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;

    return PullToRefresh(
      onRefresh: _handleRefresh,
      child: CustomScrollView(
        slivers: [
          // 顶部搜索栏
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: !ScreenSize.isDesktop(context)
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 标题
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Vibe Music',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          // 操作按钮组
                          Row(
                            children: [
                              const SizedBox(width: 12),
                              // 搜索按钮
                              IconButton(
                                onPressed: () {
                                  Get.toNamed(AppRoutes.search);
                                },
                                icon: Icon(Icons.search),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : SizedBox.shrink(),
            ),
          ),

          // 内容部分
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Column(
                  children: [
                    // 轮播图
                    _buildCarousel(),

                    // 推荐歌单
                    _buildRecommendedPlaylists(),

                    // 热门歌曲
                    _buildPopularSongs(isSmallScreen),

                    // 底部间距
                    const SizedBox(height: 32),
                  ],
                );
              },
              childCount: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建轮播图
  Widget _buildCarousel() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 240.0,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 6),
              autoPlayAnimationDuration: const Duration(milliseconds: 1000),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              aspectRatio: 16 / 9,
              viewportFraction: 0.85,
              clipBehavior: Clip.hardEdge,
              enableInfiniteScroll: true,
              pauseAutoPlayOnTouch: true,
              scrollDirection: Axis.horizontal,
            ),
            items: _carouselItems.map((item) {
              return Builder(
                builder: (BuildContext context) {
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        // 这里可以添加点击轮播图的处理逻辑
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 12.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              spreadRadius: 2,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // 轮播图图片
                              CachedNetworkImage(
                                imageUrl: item.imageUrl,
                                fit: BoxFit.cover,
                                width: 1000,
                                height: 500,
                                placeholder: (context, url) => Container(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainer,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainer,
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported,
                                        size: 48),
                                  ),
                                ),
                              ),
                              // 渐变覆盖层
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    stops: const [0.0, 0.4, 0.8],
                                    colors: [
                                      Colors.black.withOpacity(0.8),
                                      Colors.black.withOpacity(0.4),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              // 文本内容
                              Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.description,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                        shadows: [
                                          Shadow(
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            offset: const Offset(0, 1),
                                            blurRadius: 3,
                                          ),
                                        ],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item.title,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                        shadows: [
                                          Shadow(
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            offset: const Offset(0, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          // 轮播图指示器
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _carouselItems.asMap().entries.map((entry) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.5),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 构建推荐歌单
  Widget _buildRecommendedPlaylists() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 375; // 针对小屏设备进行特殊处理
    int crossAxisCount;

    // 根据屏幕宽度动态调整列数
    if (screenWidth < 600) {
      crossAxisCount = isSmallScreen ? 2 : 2;
    } else if (screenWidth < 1024) {
      crossAxisCount = 3;
    } else if (screenWidth < 1440) {
      crossAxisCount = 4;
    } else {
      crossAxisCount = 5;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '推荐歌单',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: null,
                child: Text(
                  '查看更多 >',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          //const SizedBox(height: 16.0),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 20.0,
              childAspectRatio: 0.85,
            ),
            itemCount: _recommendedPlaylists.length,
            itemBuilder: (context, index) {
              final playlist = _recommendedPlaylists[index];
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (event) {
                  // 这里可以添加悬停进入的逻辑
                },
                onExit: (event) {
                  // 这里可以添加悬停离开的逻辑
                },
                child: GestureDetector(
                  onTap: () {
                    // 这里可以添加点击歌单的处理逻辑
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: CachedNetworkImage(
                                imageUrl: playlist.imageUrl,
                                width: double.infinity,
                                height: 120,
                                fit: BoxFit.cover,
                                memCacheWidth: 300,
                                memCacheHeight: 300,
                                maxWidthDiskCache: 300,
                                maxHeightDiskCache: 300,
                                errorWidget: (context, url, error) => Container(
                                  width: double.infinity,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Icon(
                                    Icons.music_note,
                                    size: 36,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                placeholder: (context, url) => Container(
                                  width: double.infinity,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8.0,
                            right: 8.0,
                            child: _PlaylistPlayButton(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      SizedBox(
                        height: 50,
                        child: Text(
                          playlist.title,
                          style: isSmallScreen
                              ? Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  )
                              : Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        playlist.playCount,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: isSmallScreen ? 10 : 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 构建热门歌曲
  Widget _buildPopularSongs(bool isSmallScreen) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '热门歌曲',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: null,
                child: Text(
                  '查看更多 >',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          FutureBuilder<List<Song>>(
            future: _futureSongs,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final songs = snapshot.data ?? [];

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: songs.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  final coverUrl = song.coverUrl;
                  final isDesktop = ScreenSize.isDesktop(context);
                  return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 6 : 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // 歌曲排名
                            Container(
                              width: 40,
                              height: isDesktop ? 80 : 60,
                              alignment: Alignment.center,
                              child: index < 3
                                  ? Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            index == 0
                                                ? Colors.redAccent
                                                : index == 1
                                                    ? Colors.orangeAccent
                                                    : Colors.yellowAccent,
                                            index == 0
                                                ? Colors.red
                                                : index == 1
                                                    ? Colors.orange
                                                    : Colors.yellow,
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: isDesktop ? 18 : 16,
                                        fontWeight: FontWeight.normal,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                            ),
                            // 歌曲封面
                            Container(
                              margin: const EdgeInsets.only(right: 16.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: coverUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: coverUrl,
                                        width: isSmallScreen
                                            ? 48
                                            : (isDesktop ? 72 : 56),
                                        height: isSmallScreen
                                            ? 48
                                            : (isDesktop ? 72 : 56),
                                        fit: BoxFit.cover,
                                        memCacheWidth: isSmallScreen
                                            ? 96
                                            : (isDesktop ? 144 : 112),
                                        memCacheHeight: isSmallScreen
                                            ? 96
                                            : (isDesktop ? 144 : 112),
                                        maxWidthDiskCache: isSmallScreen
                                            ? 96
                                            : (isDesktop ? 144 : 112),
                                        maxHeightDiskCache: isSmallScreen
                                            ? 96
                                            : (isDesktop ? 144 : 112),
                                        placeholder: (context, url) =>
                                            Container(
                                          width: isSmallScreen
                                              ? 48
                                              : (isDesktop ? 72 : 56),
                                          height: isSmallScreen
                                              ? 48
                                              : (isDesktop ? 72 : 56),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainer,
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          width: isSmallScreen
                                              ? 48
                                              : (isDesktop ? 72 : 56),
                                          height: isSmallScreen
                                              ? 48
                                              : (isDesktop ? 72 : 56),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainer,
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          child: Icon(
                                            Icons.music_note,
                                            size: isSmallScreen
                                                ? 24
                                                : (isDesktop ? 36 : 28),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: isSmallScreen
                                            ? 48
                                            : (isDesktop ? 72 : 56),
                                        height: isSmallScreen
                                            ? 48
                                            : (isDesktop ? 72 : 56),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainer,
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Icon(
                                          Icons.music_note,
                                          size: isSmallScreen
                                              ? 24
                                              : (isDesktop ? 36 : 28),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                              ),
                            ),
                            // 使用Expanded来确保文本部分适应剩余空间
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    song.songName ?? 'Unknown Song',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: isDesktop ? 16 : null,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          song.artistName ?? 'Unknown Artist',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                                fontSize: isDesktop ? 14 : null,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isDesktop &&
                                          song.albumName != null) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          '·',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            song.albumName!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                  fontSize: 14,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // 操作按钮
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 收藏按钮
                                Obx(() {
                                  final musicProvider =
                                      Get.find<MusicProvider>();
                                  // 访问可观察变量以触发重建
                                  final isFavorited = musicProvider
                                      .favoriteSongIds
                                      .contains(song.id);
                                  final isLoading =
                                      _favoriteLoadingStates[song.id] ?? false;

                                  return IconButton(
                                    onPressed: isLoading
                                        ? null
                                        : () async {
                                            final authProvider =
                                                Get.find<AuthProvider>();
                                            final localizations =
                                                AppLocalizations.of(context);
                                            if (!authProvider.isAuthenticated) {
                                              // 提示用户登录
                                              Get.snackbar(
                                                localizations?.tip ?? '提示',
                                                localizations?.pleaseLogin ??
                                                    '请先登录',
                                                backgroundColor: Colors.blue,
                                                colorText: Colors.white,
                                                icon: Icon(Icons.info,
                                                    color: Colors.white),
                                                duration: Duration(seconds: 2),
                                              );
                                              // 导航到登录页面
                                              Get.toNamed(AppRoutes.login);
                                              return;
                                            }

                                            // 设置加载状态
                                            setState(() {
                                              _favoriteLoadingStates[song.id!] =
                                                  true;
                                            });

                                            bool success;
                                            if (isFavorited) {
                                              success = await musicProvider
                                                  .removeFromFavorites(song);
                                              if (success && mounted) {
                                                SnackbarManager().showSnackbar(
                                                  title: '成功',
                                                  message: '已取消收藏',
                                                  icon: Icon(Icons.check_circle,
                                                      color: Colors.white),
                                                  duration:
                                                      Duration(seconds: 2),
                                                );
                                              }
                                            } else {
                                              success = await musicProvider
                                                  .addToFavorites(song);
                                              if (success && mounted) {
                                                SnackbarManager().showSnackbar(
                                                  title: '成功',
                                                  message: '已添加到收藏',
                                                  icon: Icon(Icons.check_circle,
                                                      color: Colors.white),
                                                  duration:
                                                      Duration(seconds: 2),
                                                );
                                              }
                                            }

                                            // 重置加载状态
                                            setState(() {
                                              _favoriteLoadingStates[song.id!] =
                                                  false;
                                            });
                                          },
                                    icon: isLoading
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                          )
                                        : Icon(
                                            isFavorited
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            size: isDesktop ? 20 : 18,
                                            color: isFavorited
                                                ? Colors.red
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                          ),
                                  );
                                }),
                                // 播放按钮
                                IconButton(
                                  onPressed: () async {
                                    // 将整个热门歌曲列表添加到播放列表
                                    await Get.find<MusicProvider>()
                                        .playSong(song, playlist: songs);
                                    // 导航到播放器页面
                                    if (mounted) {
                                      Get.toNamed(AppRoutes.player);
                                    }
                                  },
                                  icon: Icon(
                                    Icons.play_circle_outline,
                                    size: isDesktop ? 32 : 28,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                // 更多按钮
                                IconButton(
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
                                                leading:
                                                    Icon(Icons.queue_play_next),
                                                title: Text('下一首播放'),
                                                onTap: () {
                                                  // 添加到下一首播放
                                                  Get.find<MusicProvider>()
                                                      .insertNextToPlay(song);
                                                  final localizations =
                                                      AppLocalizations.of(
                                                          context);
                                                  Get.snackbar(
                                                    localizations?.success ??
                                                        '成功',
                                                    localizations
                                                            ?.addedToNextPlay ??
                                                        '已添加到下一首播放',
                                                    backgroundColor:
                                                        Colors.green,
                                                    colorText: Colors.white,
                                                    icon: Icon(
                                                        Icons.check_circle,
                                                        color: Colors.white),
                                                    duration:
                                                        Duration(seconds: 2),
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
                                  icon: Icon(
                                    Icons.more_vert,
                                    size: isDesktop ? 20 : 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ));
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 歌单播放按钮Widget
class _PlaylistPlayButton extends StatelessWidget {
  const _PlaylistPlayButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
      ),
      child: const Icon(
        Icons.play_arrow,
        color: Colors.white,
        size: 18,
      ),
    );
  }
}
