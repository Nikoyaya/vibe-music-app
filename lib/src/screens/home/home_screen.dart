import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibe_music_app/src/providers/auth_provider.dart';
import 'package:vibe_music_app/src/providers/music_provider.dart';
import 'package:vibe_music_app/src/screens/player/player_screen.dart';
import 'package:vibe_music_app/src/screens/admin/admin_screen.dart';
import 'package:vibe_music_app/src/screens/search/search_screen.dart';
import 'package:vibe_music_app/src/screens/auth/login_screen.dart';
import 'package:vibe_music_app/src/screens/favorites/favorites_screen.dart';
import 'package:vibe_music_app/src/models/song_model.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';
import 'package:carousel_slider/carousel_slider.dart';

/// 主页屏幕
/// 包含底部导航栏和多个子页面
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// 当前选中的页面索引
  int _currentPage = 0;

  /// 底部导航栏对应的页面列表
  final List<Widget> _pages = [
    const SongListPage(), // 歌曲列表页面
    const SearchScreen(), // 搜索页面
    const FavoritesScreen(), // 收藏页面
    const ProfilePage(), // 个人中心页面
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentPage], // 显示当前选中的页面
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 正在播放音乐的小悬浮组件
          _buildCurrentlyPlayingBar(),
          // 底部导航栏
          SafeArea(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                  child: NavigationBar(
                    selectedIndex: _currentPage,
                    onDestinationSelected: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    destinations: const [
                      NavigationDestination(
                          icon: Icon(Icons.music_note), label: 'Songs'),
                      NavigationDestination(
                          icon: Icon(Icons.search), label: 'Search'),
                      NavigationDestination(
                          icon: Icon(Icons.favorite), label: '收藏'),
                      NavigationDestination(
                          icon: Icon(Icons.person), label: 'Profile'),
                    ],
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentlyPlayingBar() {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        if (musicProvider.currentSong == null ||
            musicProvider.playerState == AppPlayerState.stopped) {
          return const SizedBox.shrink();
        }

        final song = musicProvider.currentSong!;
        final duration = musicProvider.duration;
        final position = musicProvider.position;
        final progress = duration.inSeconds > 0
            ? position.inSeconds / duration.inSeconds
            : 0.0;

        return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                child: Container(
                  color:
                      Theme.of(context).colorScheme.surface.withOpacity(0.85),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 进度条
                      GestureDetector(
                        onTapDown: (TapDownDetails details) {
                          final RenderBox box =
                              context.findRenderObject() as RenderBox;
                          final tapPosition =
                              box.globalToLocal(details.globalPosition);
                          final progressWidth = box.size.width - 32;
                          final tapProgress = tapPosition.dx / progressWidth;
                          final newPosition = Duration(
                            seconds: (tapProgress * duration.inSeconds).toInt(),
                          );
                          musicProvider.seekTo(newPosition);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 6,
                          child: Container(
                            width: double.infinity,
                            height: 6,
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Colors.transparent,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    minHeight: 6,
                                  ),
                                ),
                                // 进度指示器
                                Positioned(
                                  left: progress *
                                          (MediaQuery.of(context).size.width -
                                              32) -
                                      6,
                                  top: -3,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // 歌曲信息和控制按钮
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PlayerScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              // 歌曲封面
                              Hero(
                                tag: 'currentSong',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: song.coverUrl != null
                                      ? Image.network(
                                          song.coverUrl!,
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Container(
                                              width: 56,
                                              height: 56,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primaryContainer,
                                              child: const Icon(
                                                  Icons.music_note,
                                                  size: 28),
                                            );
                                          },
                                        )
                                      : Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(Icons.music_note,
                                              size: 28, color: Colors.white),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // 歌曲信息
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      song.songName ?? 'Unknown Song',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      song.artistName ?? 'Unknown Artist',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                            fontWeight: FontWeight.w400,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),

                              // 控制按钮
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceVariant,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.skip_previous,
                                        size: 22,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                      onPressed: () => musicProvider.previous(),
                                      padding: const EdgeInsets.all(6),
                                      constraints:
                                          const BoxConstraints(minWidth: 36),
                                      splashRadius: 20,
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        musicProvider.playerState ==
                                                AppPlayerState.playing
                                            ? Icons.pause_circle_filled
                                            : Icons.play_circle_filled,
                                        size: 36,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      onPressed: () {
                                        if (musicProvider.playerState ==
                                            AppPlayerState.playing) {
                                          musicProvider.pause();
                                        } else {
                                          musicProvider.play();
                                        }
                                      },
                                      padding: const EdgeInsets.all(4),
                                      constraints:
                                          const BoxConstraints(minWidth: 44),
                                      splashRadius: 24,
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.skip_next,
                                        size: 22,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                      onPressed: () => musicProvider.next(),
                                      padding: const EdgeInsets.all(6),
                                      constraints:
                                          const BoxConstraints(minWidth: 36),
                                      splashRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
      },
    );
  }
}

class SongListPage extends StatefulWidget {
  const SongListPage({super.key});

  @override
  State<SongListPage> createState() => _SongListPageState();
}

enum SongListType {
  recommended,
  favorite,
}

// 模拟轮播图数据
class CarouselItem {
  final String imageUrl;
  final String title;
  final String description;

  CarouselItem({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}

// 模拟歌单数据
class PlaylistItem {
  final String imageUrl;
  final String title;
  final String playCount;

  PlaylistItem({
    required this.imageUrl,
    required this.title,
    required this.playCount,
  });
}

class _SongListPageState extends State<SongListPage> {
  late Future<List<Song>> _futureSongs;
  final SongListType _currentType = SongListType.recommended;

  // 轮播图数据
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

  // 推荐歌单数据
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

  void _loadSongs() {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    if (_currentType == SongListType.recommended) {
      _futureSongs = musicProvider.loadRecommendedSongs();
    } else {
      _futureSongs = musicProvider.loadUserFavoriteSongs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              child: AppBar(
                title: const Text('Vibe Music Player'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SearchScreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.account_circle),
                    onPressed: () {
                      // 切换到个人资料页面
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfilePage()),
                      );
                    },
                  ),
                ],
                backgroundColor: Colors.transparent,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 轮播图
          _buildCarousel(),

          // 推荐歌单
          _buildRecommendedPlaylists(),

          // 热门歌曲
          _buildPopularSongs(musicProvider, isSmallScreen),
        ],
      ),
    );
  }

  // 构建轮播图
  Widget _buildCarousel() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 180.0,
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
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  image: DecorationImage(
                    image: NetworkImage(item.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.description,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
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

  // 构建推荐歌单
  Widget _buildRecommendedPlaylists() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 375; // 针对小屏设备进行特殊处理
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '推荐歌单',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              TextButton(
                onPressed: () {},
                child: const Text('查看更多 >'),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isSmallScreen ? 2 : (screenWidth > 600 ? 3 : 2),
              crossAxisSpacing: 2.0,
              mainAxisSpacing: 2.0,
              childAspectRatio: 1.1,
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
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          playlist.imageUrl,
                          width: double.infinity,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 100,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.2),
                              child: const Icon(
                                Icons.music_note,
                                size: 30,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 2.0,
                        right: 6.0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.purple.withOpacity(0.8),
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  SizedBox(
                    height: 50,
                    child: Text(
                      playlist.title,
                      style: isSmallScreen
                          ? Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontSize: 12)
                          : Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    playlist.playCount,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: isSmallScreen ? 10 : 12,
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

  // 构建热门歌曲
  Widget _buildPopularSongs(MusicProvider musicProvider, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '热门歌曲',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12.0),
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
                  return Card(
                    margin:
                        EdgeInsets.symmetric(vertical: isSmallScreen ? 4 : 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // 使用Container代替ListTile的leading，避免宽度问题
                        Container(
                          margin: const EdgeInsets.only(right: 12.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: coverUrl != null
                                ? Image.network(
                                    coverUrl,
                                    width: isSmallScreen ? 40 : 48,
                                    height: isSmallScreen ? 40 : 48,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: isSmallScreen ? 40 : 48,
                                    height: isSmallScreen ? 40 : 48,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.2),
                                    child: Icon(
                                      Icons.music_note,
                                      size: isSmallScreen ? 20 : 24,
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
                                style: isSmallScreen
                                    ? Theme.of(context).textTheme.titleSmall
                                    : Theme.of(context).textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                song.artistName ?? 'Unknown Artist',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.7),
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
                            IconButton(
                              icon: Icon(
                                musicProvider.isSongFavorited(song)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: musicProvider.isSongFavorited(song)
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                              onPressed: () async {
                                final authProvider = Provider.of<AuthProvider>(
                                    context,
                                    listen: false);
                                if (!authProvider.isAuthenticated) {
                                  // 提示用户登录
                                  ScaffoldMessenger.of(context).showSnackBar(
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('已取消收藏')),
                                    );
                                  }
                                } else {
                                  success =
                                      await musicProvider.addToFavorites(song);
                                  if (success && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('已添加到收藏')),
                                    );
                                  }
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.play_arrow),
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

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _introductionController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _introductionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Initialize form fields when user data changes
    if (authProvider.user != null) {
      _usernameController.text = authProvider.user!.username ?? '';
      _emailController.text = authProvider.user!.email ?? '';
      _phoneController.text = authProvider.user!.phone ?? '';
      _introductionController.text = authProvider.user!.introduction ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: authProvider.isAuthenticated && !_isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                ),
              ]
            : [],
      ),
      body: Center(
        child: authProvider.isAuthenticated
            ? _isEditing
                ? _buildEditProfileForm(authProvider)
                : _buildProfileView(authProvider)
            : _buildLoginPrompt(),
      ),
    );
  }

  Widget _buildProfileView(AuthProvider authProvider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => _showImagePickerOptions(),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundImage: authProvider.user?.userAvatar != null
                    ? NetworkImage(authProvider.user!.userAvatar!)
                    : null,
                child: authProvider.user?.userAvatar == null
                    ? Text(
                        authProvider.user?.username?[0].toUpperCase() ?? 'U',
                        style: const TextStyle(fontSize: 32),
                      )
                    : null,
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          authProvider.user?.username ?? 'User',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(
          authProvider.user?.email ?? '',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (authProvider.user?.phone != null &&
            authProvider.user!.phone!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Phone: ${authProvider.user!.phone!}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        if (authProvider.user?.introduction != null &&
            authProvider.user!.introduction!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              authProvider.user!.introduction!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
        const SizedBox(height: 24),
        if (authProvider.isAdmin)
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminScreen()),
              );
            },
            icon: const Icon(Icons.admin_panel_settings),
            label: const Text('Admin Panel'),
          ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () async {
            await authProvider.logout();
            if (context.mounted) {
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            }
          },
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
  }

  Widget _buildEditProfileForm(AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter username';
                }
                if (!RegExp(r'^[a-zA-Z0-9_-]{4,16}$').hasMatch(value)) {
                  return 'Username must be 4-16 characters (letters, numbers, _, -)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value != null &&
                    value.isNotEmpty &&
                    !RegExp(r'^1[3456789]\d{9}$').hasMatch(value)) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _introductionController,
              decoration: const InputDecoration(
                labelText: 'Introduction',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              maxLength: 100,
              validator: (value) {
                if (value != null && value.length > 100) {
                  return 'Introduction must be less than 100 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      // Reset form fields to current user data
                      if (authProvider.user != null) {
                        _usernameController.text =
                            authProvider.user!.username ?? '';
                        _emailController.text = authProvider.user!.email ?? '';
                        _phoneController.text = authProvider.user!.phone ?? '';
                        _introductionController.text =
                            authProvider.user!.introduction ?? '';
                      }
                    });
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final updatedInfo = {
                        'username': _usernameController.text,
                        'email': _emailController.text,
                        'phone': _phoneController.text.isEmpty
                            ? null
                            : _phoneController.text,
                        'introduction': _introductionController.text.isEmpty
                            ? null
                            : _introductionController.text,
                      };

                      final success =
                          await authProvider.updateUserInfo(updatedInfo);
                      if (success && mounted) {
                        setState(() {
                          _isEditing = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Profile updated successfully')),
                        );
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Failed to update profile')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.person, size: 64),
        const SizedBox(height: 16),
        const Text('Please login to continue'),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          icon: const Icon(Icons.login),
          label: const Text('Login'),
        ),
      ],
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 500,
        maxHeight: 500,
      );

      if (pickedFile != null) {
        // Read image bytes instead of path
        final bytes = await pickedFile.readAsBytes();
        final success = await authProvider.updateUserAvatar(bytes);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Avatar updated successfully')),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update avatar')),
          );
        }
      }
    } catch (e) {
      AppLogger().e('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error picking image')),
        );
      }
    }
  }
}
