import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibe_music_app/src/providers/auth_provider.dart';
import 'package:vibe_music_app/src/screens/auth/login_screen.dart';
import 'package:vibe_music_app/src/screens/admin/admin_screen.dart';

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
  
  // 用于跟踪最后一次更新的用户数据，避免不必要的更新
  Map<String, String>? _lastUserInfo;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _introductionController.dispose();
    super.dispose();
  }
  
  @override
  void initState() {
    super.initState();
    // 在初始化时不调用 _updateFormFields，因为此时 context 不可用
    // 改为在 didChangeDependencies 中调用
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 当依赖变化时更新表单（例如用户登录/登出）
    _updateFormFields();
  }
  
  // 更新表单字段，只有当用户数据真正变化时才更新
  void _updateFormFields() {
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.user != null) {
      final currentUserInfo = {
        'username': authProvider.user!.username ?? '',
        'email': authProvider.user!.email ?? '',
        'phone': authProvider.user!.phone ?? '',
        'introduction': authProvider.user!.introduction ?? ''
      };
      
      // 只有当用户信息真正变化时才更新表单
      if (_lastUserInfo != currentUserInfo) {
        _usernameController.text = authProvider.user!.username ?? '';
        _emailController.text = authProvider.user!.email ?? '';
        _phoneController.text = authProvider.user!.phone ?? '';
        _introductionController.text = authProvider.user!.introduction ?? '';
        _lastUserInfo = currentUserInfo;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

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
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
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
                        _usernameController.text = authProvider.user!.username ?? '';
                        _emailController.text = authProvider.user!.email ?? '';
                        _phoneController.text = authProvider.user!.phone ?? '';
                        _introductionController.text = authProvider.user!.introduction ?? '';
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

                      final success = await authProvider.updateUserInfo(updatedInfo);
                      if (success && mounted) {
                        setState(() {
                          _isEditing = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile updated successfully')),
                        );
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to update profile')),
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
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image')),
        );
      }
    }
  }
}
