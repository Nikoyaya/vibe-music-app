import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vibe_music_app/src/providers/auth_provider.dart';
import 'package:vibe_music_app/src/providers/music_provider.dart';
import 'package:vibe_music_app/src/screens/player/player_screen.dart';
import 'package:vibe_music_app/src/screens/search/search_screen.dart';
import 'package:vibe_music_app/src/screens/auth/login_screen.dart';
import 'package:vibe_music_app/src/models/song_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:vibe_music_app/src/components/pull_to_refresh.dart';

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

  /// 加载歌曲数据
  void _loadSongs() {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    setState(() {
      if (_currentType == SongListType.recommended) {
        _futureSongs = musicProvider.loadRecommendedSongs();
      } else {
        _futureSongs = musicProvider.loadUserFavoriteSongs();
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

    return Scaffold(
      body: PullToRefresh(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          slivers: [
            // 可滚动的AppBar，支持渐变和消失效果
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              shadowColor: Theme.of(context).colorScheme.shadow,
              elevation: 2,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              // 配置滚动行为
              expandedHeight: 80,
              floating: false,
              pinned: false,
              snap: false,
              // 滚动时的渐变效果
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 标题
                            Text(
                              'Vibe Music Player',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            // 搜索按钮
                            IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SearchScreen()),
                                );
                              },
                              color: Theme.of(context).colorScheme.onSurface,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 40),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
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
                    ],
                  );
                },
                childCount: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建轮播图
  Widget _buildCarousel() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 200.0,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 5),
          enlargeCenterPage: true,
          aspectRatio: 16 / 9,
          viewportFraction: 0.9,
          clipBehavior: Clip.hardEdge,
        ),
        items: _carouselItems.map((item) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(item.imageUrl),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.shadow,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.description,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
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
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  /// 构建推荐歌单
  Widget _buildRecommendedPlaylists() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 375; // 针对小屏设备进行特殊处理
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
          const SizedBox(height: 16.0),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isSmallScreen ? 2 : (screenWidth > 600 ? 3 : 2),
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.85,
            ),
            itemCount: _recommendedPlaylists.length,
            itemBuilder: (context, index) {
              final playlist = _recommendedPlaylists[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: CachedNetworkImage(
                          imageUrl: playlist.imageUrl,
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
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
                              color: Theme.of(context).colorScheme.primary,
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
                          : Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// 构建热门歌曲
  Widget _buildPopularSongs(bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '热门歌曲',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
                  return Container(
                    margin:
                        EdgeInsets.symmetric(vertical: isSmallScreen ? 6 : 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.shadow,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // 歌曲排名
                        Container(
                          width: 36,
                          height: 60,
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: index < 3
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: index < 3
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                          ),
                        ),
                        // 歌曲封面
                        Container(
                          margin: const EdgeInsets.only(right: 16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: coverUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: coverUrl,
                                    width: isSmallScreen ? 48 : 56,
                                    height: isSmallScreen ? 48 : 56,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      width: isSmallScreen ? 48 : 56,
                                      height: isSmallScreen ? 48 : 56,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      width: isSmallScreen ? 48 : 56,
                                      height: isSmallScreen ? 48 : 56,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Icon(
                                        Icons.music_note,
                                        size: isSmallScreen ? 24 : 28,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: isSmallScreen ? 48 : 56,
                                    height: isSmallScreen ? 48 : 56,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Icon(
                                      Icons.music_note,
                                      size: isSmallScreen ? 24 : 28,
                                      color:
                                          Theme.of(context).colorScheme.primary,
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
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                song.artistName ?? 'Unknown Artist',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 14,
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
                        // 操作按钮
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 使用Consumer只监听收藏状态变化
                            Consumer<MusicProvider>(
                              builder: (context, musicProvider, child) {
                                return IconButton(
                                  icon: Icon(
                                    musicProvider.isSongFavorited(song)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: musicProvider.isSongFavorited(song)
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                  ),
                                  onPressed: () async {
                                    final authProvider =
                                        Provider.of<AuthProvider>(context,
                                            listen: false);
                                    if (!authProvider.isAuthenticated) {
                                      // 提示用户登录
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(content: Text('请先登录')),
                                      );
                                      // 导航到登录页面
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginScreen()),
                                      );
                                      return;
                                    }

                                    bool success;
                                    if (musicProvider.isSongFavorited(song)) {
                                      success = await musicProvider
                                          .removeFromFavorites(song);
                                      if (success && mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text('已取消收藏')),
                                        );
                                      }
                                    } else {
                                      success = await musicProvider
                                          .addToFavorites(song);
                                      if (success && mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text('已添加到收藏')),
                                        );
                                      }
                                    }
                                  },
                                );
                              },
                            ),
                            Consumer<MusicProvider>(
                              builder: (context, musicProvider, child) {
                                return IconButton(
                                  icon: Icon(
                                    Icons.play_circle_outline,
                                    size: 28,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  onPressed: () async {
                                    // 将整个热门歌曲列表添加到播放列表
                                    await musicProvider.playSong(song,
                                        playlist: songs);
                                    // 导航到播放器页面
                                    if (mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const PlayerScreen()),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                          ],
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
