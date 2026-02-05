import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vibe_music_app/generated/app_localizations.dart';
import 'package:vibe_music_app/src/controllers/auth_controller.dart';
import 'package:vibe_music_app/src/controllers/music_controller.dart';
import 'package:vibe_music_app/src/models/song_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:vibe_music_app/src/components/pull_to_refresh.dart';
import 'package:vibe_music_app/src/services/image_preload_service.dart';
import 'package:vibe_music_app/src/utils/snackbar_manager.dart';
import 'package:vibe_music_app/src/routes/app_routes.dart';
import 'package:vibe_music_app/src/utils/glass_morphism/responsive_layout.dart';
import 'package:vibe_music_app/src/pages/home/widgets/controller.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';

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

class _SongListPageState extends State<SongListPage>
    with AutomaticKeepAliveClientMixin<SongListPage> {
  late Future<List<Song>> _futureSongs = Future.value([]); // 歌曲数据未来
  final Map<int, bool> _favoriteLoadingStates = {}; // 收藏操作加载状态
  int _currentCarouselIndex = 0; // 当前轮播图索引

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

  /// 滚动控制器，用于实现加载更多功能
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 在initState中只加载一次歌曲数据
    _loadSongs();
    // 监听滚动事件，实现加载更多
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 滚动事件处理，实现加载更多
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isLoadingMore &&
        !_hasReachedEnd) {
      _loadMoreSongs();
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // 必须调用super.build(context)来保持页面状态
    super.build(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final isDesktop = ScreenSize.isDesktop(context);

    return PullToRefresh(
      onRefresh: _handleRefresh,
      child: CustomScrollView(
        slivers: [
          // 顶部搜索栏
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: isDesktop ? _buildDesktopHeader() : _buildMobileHeader(),
            ),
          ),

          // 内容部分
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Column(
                  children: [
                    // 轮播图 - 使用RepaintBoundary减少重绘区域
                    RepaintBoundary(
                      child: _buildCarousel(),
                    ),

                    // 推荐歌单 - 使用RepaintBoundary减少重绘区域
                    RepaintBoundary(
                      child: _buildRecommendedPlaylists(),
                    ),

                    // 热门歌曲 - 使用RepaintBoundary减少重绘区域
                    RepaintBoundary(
                      child: _buildPopularSongs(isSmallScreen),
                    ),

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
      // 直接执行预加载操作
      ImagePreloadService().preloadCarouselImages(_carouselItems, context);
    }
    // 预加载推荐歌单图片
    if (_recommendedPlaylists.isNotEmpty) {
      // 直接执行预加载操作
      ImagePreloadService()
          .preloadPlaylistImages(_recommendedPlaylists, context);
    }
  }

  /// 当前页码
  int _currentPage = 1;

  /// 每页歌曲数量
  int _pageSize = 20;

  /// 是否正在加载更多数据
  bool _isLoadingMore = false;

  /// 是否已经加载完所有数据
  bool _hasReachedEnd = false;

  /// 加载歌曲数据
  Future<void> _loadSongs({bool forceRefresh = false}) async {
    final musicController = Get.find<MusicController>();
    int retryCount = 0;
    const maxRetries = 3;

    if (forceRefresh) {
      _currentPage = 1;
      _hasReachedEnd = false;
    }

    while (retryCount < maxRetries) {
      try {
        final songs = await musicController.loadRecommendedSongs(
            forceRefresh: forceRefresh || retryCount > 0);

        // 预加载歌曲封面图片
        if (mounted) {
          ImagePreloadService().preloadSongCovers(songs, context);
        }

        setState(() {
          _futureSongs = Future.value(songs);
          if (songs.length < _pageSize) {
            _hasReachedEnd = true;
          }
        });
        return; // 加载成功，退出循环
      } catch (error) {
        retryCount++;
        AppLogger().e('加载歌曲数据失败 (尝试 $retryCount/$maxRetries): $error');

        // 如果是最后一次尝试，设置为空列表
        if (retryCount >= maxRetries) {
          setState(() {
            _futureSongs = Future.value([]);
          });
        }

        // 等待一段时间后重试
        await Future.delayed(Duration(seconds: 1));
      }
    }
  }

  /// 加载更多歌曲数据
  Future<void> _loadMoreSongs() async {
    if (_isLoadingMore || _hasReachedEnd) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      final musicController = Get.find<MusicController>();
      final moreSongs = await musicController.loadRecommendedSongs();

      // 预加载歌曲封面图片
      if (mounted && moreSongs.isNotEmpty) {
        ImagePreloadService().preloadSongCovers(moreSongs, context);
      }

      setState(() {
        _isLoadingMore = false;
        if (moreSongs.length < _pageSize) {
          _hasReachedEnd = true;
        }
      });
    } catch (error) {
      AppLogger().e('加载更多歌曲数据失败: $error');
      setState(() {
        _isLoadingMore = false;
        _currentPage--;
      });
    }
  }

  /// 处理下拉刷新
  Future<void> _handleRefresh() async {
    // 重新加载歌曲数据，强制刷新
    await _loadSongs(forceRefresh: true);
    // 等待数据加载完成
    await _futureSongs;
  }

  /// 构建桌面端头部
  Widget _buildDesktopHeader() {
    return SizedBox.shrink();
  }

  /// 构建移动端头部
  Widget _buildMobileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
              onPageChanged: (index, reason) {
                setState(() {
                  _currentCarouselIndex = index;
                });
              },
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
                              color: Colors.black.withValues(alpha: 0.2),
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
                              ImageLoader.buildCachedNetworkImage(
                                item.imageUrl,
                                fit: BoxFit.cover,
                                width: 1000,
                                height: 500,
                                cacheWidth: 800,
                                cacheHeight: 400,
                                qualityLevel: ImageQualityLevel.high,
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
                                      Colors.black.withValues(alpha: 0.8),
                                      Colors.black.withValues(alpha: 0.4),
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
                                            color: Colors.black
                                                .withValues(alpha: 0.6),
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
                                            color: Colors.black
                                                .withValues(alpha: 0.6),
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
              final int index = entry.key;
              return Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == _currentCarouselIndex
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
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
    final localizations = AppLocalizations.of(context)!;

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
                localizations.recommendedPlaylists,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  // 这里可以添加查看更多歌单的逻辑
                  Get.snackbar(
                    '功能开发中',
                    '查看更多歌单功能即将上线',
                    backgroundColor: Colors.blue,
                    colorText: Colors.white,
                    duration: Duration(seconds: 2),
                  );
                },
                child: Text(
                  '${localizations.viewMore} >',
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
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: ImageLoader.buildCachedNetworkImage(
                                playlist.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 120,
                                cacheWidth: 300,
                                cacheHeight: 300,
                                qualityLevel: ImageQualityLevel.medium,
                                errorWidget: (context, url, error) => Container(
                                  width: double.infinity,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.2),
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

  /// 构建歌曲封面
  Widget _buildSongCover(String? coverUrl, bool isSmallScreen, bool isDesktop) {
    final double size = isSmallScreen ? 48 : (isDesktop ? 72 : 56);
    final int cacheSize = isSmallScreen ? 96 : (isDesktop ? 144 : 112);
    final double iconSize = isSmallScreen ? 24 : (isDesktop ? 36 : 28);

    Widget placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );

    Widget errorWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Icon(
        Icons.music_note,
        size: iconSize,
        color: Theme.of(context).colorScheme.primary,
      ),
    );

    if (coverUrl != null) {
      return ImageLoader.buildCachedNetworkImage(
        coverUrl,
        fit: BoxFit.cover,
        width: size,
        height: size,
        cacheWidth: 120,
        cacheHeight: 120,
        qualityLevel: ImageQualityLevel.low,
        placeholder: (context, url) => placeholder,
        errorWidget: (context, url, error) => errorWidget,
      );
    } else {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Icon(
          Icons.music_note,
          size: iconSize,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  /// 构建热门歌曲
  Widget _buildPopularSongs(bool isSmallScreen) {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations.hotSongs,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  // 这里可以添加查看更多热门歌曲的逻辑
                  Get.snackbar(
                    '功能开发中',
                    '查看更多热门歌曲功能即将上线',
                    backgroundColor: Colors.blue,
                    colorText: Colors.white,
                    duration: Duration(seconds: 2),
                  );
                },
                child: Text(
                  '${localizations.viewMore} >',
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
                // 加载错误时自动重试
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _loadSongs(forceRefresh: true);
                });
                return const Center(child: CircularProgressIndicator());
              }

              final songs = snapshot.data ?? [];

              // 歌曲列表为空时自动重试
              if (songs.isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _loadSongs(forceRefresh: true);
                });
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: songs.length + (_isLoadingMore ? 1 : 0),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  // 加载更多指示器
                  if (index == songs.length) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    );
                  }

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
                              color: Colors.black.withValues(alpha: 0.05),
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
                                child: _buildSongCover(
                                    coverUrl, isSmallScreen, isDesktop),
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
                                      Get.find<MusicController>();
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
                                                Get.find<AuthController>();
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
                                    final musicController =
                                        Get.find<MusicController>();
                                    // 将整个热门歌曲列表添加到播放列表
                                    for (final s in songs) {
                                      if (!musicController.playlist.any(
                                          (item) =>
                                              item.songUrl == s.songUrl)) {
                                        await musicController.addToPlaylist(s);
                                      }
                                    }
                                    // 播放选中的歌曲
                                    await musicController.playSong(song);
                                    // 导航到播放器页面（切换到底部导航栏的播放页）
                                    if (mounted) {
                                      final homeController =
                                          Get.find<HomeController>();
                                      homeController.changePage(1);
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
                                                  Get.find<MusicController>()
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
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
      ),
      child: const Icon(
        Icons.play_arrow,
        color: Colors.white,
        size: 18,
      ),
    );
  }
}
