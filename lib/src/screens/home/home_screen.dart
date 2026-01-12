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
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 0;

  final List<Widget> _pages = [
    const SongListPage(),
    const SearchScreen(),
    const FavoritesScreen(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentPage],
      bottomNavigationBar: SafeArea(
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
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
                title: const Text('Glass Music Player'),
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
                        Colors.black.withValues(alpha: 0.8),
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
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              childAspectRatio: 0.8,
            ),
            itemCount: _recommendedPlaylists.length,
            itemBuilder: (context, index) {
              final playlist = _recommendedPlaylists[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          playlist.imageUrl,
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 8.0,
                        right: 8.0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.purple.withValues(alpha: 0.8),
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    playlist.title,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    playlist.playCount,
                    style: Theme.of(context).textTheme.bodySmall,
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
                    child: ListTile(
                      leading: ClipRRect(
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
                                    .withValues(alpha: 0.2),
                                child: Icon(
                                  Icons.music_note,
                                  size: isSmallScreen ? 20 : 24,
                                ),
                              ),
                      ),
                      title: Text(
                        song.songName ?? 'Unknown Song',
                        style: isSmallScreen
                            ? Theme.of(context).textTheme.titleSmall
                            : Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        song.artistName ?? 'Unknown Artist',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
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
                              // 先播放歌曲，等待播放开始后再导航
                              await musicProvider
                                  .playSong(song, playlist: [song]);
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
                      onTap: () async {
                        // 先播放歌曲，等待播放开始后再导航
                        await musicProvider.playSong(song, playlist: [song]);
                        // 导航到播放器页面
                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PlayerScreen()),
                          );
                        }
                      },
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
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error picking image')),
        );
      }
    }
  }
}
