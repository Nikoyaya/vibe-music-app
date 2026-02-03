import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibe_music_app/generated/app_localizations.dart';
import 'package:vibe_music_app/src/providers/auth_provider.dart';
import 'package:vibe_music_app/src/providers/language_provider.dart';
import 'package:vibe_music_app/src/components/language_selector.dart';
import 'package:vibe_music_app/src/routes/app_routes.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';

/// 个人中心页面
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false; // 是否处于编辑模式
  final _formKey = GlobalKey<FormState>(); // 表单键
  final TextEditingController _usernameController =
      TextEditingController(); // 用户名控制器
  final TextEditingController _emailController =
      TextEditingController(); // 邮箱控制器
  final TextEditingController _phoneController =
      TextEditingController(); // 手机号控制器
  final TextEditingController _introductionController =
      TextEditingController(); // 个人简介控制器

  /// 用于跟踪最后一次更新的用户数据，避免不必要的更新
  Map<String, String>? _lastUserInfo;

  @override
  void initState() {
    super.initState();
    // 在初始化时不调用 _updateFormFields，因为此时 context 不可用
    // 改为在 didChangeDependencies 中调用
  }

  @override
  void dispose() {
    // 释放控制器资源
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _introductionController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 当依赖变化时更新表单（例如用户登录/登出）
    _updateFormFields();
  }

  /// 更新表单字段，只有当用户数据真正变化时才更新
  void _updateFormFields() {
    final authProvider = Get.find<AuthProvider>();
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
    } else {
      // 用户未登录，清空表单字段
      if (_lastUserInfo != null) {
        _usernameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _introductionController.clear();
        _lastUserInfo = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Get.find<AuthProvider>();
    final languageProvider = Get.find<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.profile ?? '个人中心'),
        actions: [
          Obx(() {
            if (authProvider.isAuthenticated && !_isEditing) {
              return IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Obx(() {
                // 每次认证状态变化时更新表单字段
                _updateFormFields();
                return authProvider.isAuthenticated
                    ? _isEditing
                        ? _buildEditProfileForm(authProvider)
                        : _buildProfileView(authProvider)
                    : _buildLoginPrompt();
              }),
            ),
            const SizedBox(height: 32),
            LanguageSelector(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 构建个人资料查看页面
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
            '${AppLocalizations.of(context)?.phone ?? '手机号'}: ${authProvider.user!.phone!}',
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
          label: Text(AppLocalizations.of(context)?.logout ?? '退出登录'),
        ),
      ],
    );
  }

  /// 构建个人资料编辑表单
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
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)?.username ?? '用户名',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)?.enterUsername ??
                      '请输入用户名';
                }
                if (!RegExp(r'^[a-zA-Z0-9_-]{4,16}$').hasMatch(value)) {
                  return AppLocalizations.of(context)?.usernameFormat ??
                      '用户名必须是4-16个字符（字母、数字、_、-）';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)?.email ?? '邮箱',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)?.enterEmail ?? '请输入邮箱';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
                  return AppLocalizations.of(context)?.validEmail ??
                      '请输入有效的邮箱地址';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)?.phone ?? '手机号',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value != null &&
                    value.isNotEmpty &&
                    !RegExp(r'^1[3456789]\d{9}$').hasMatch(value)) {
                  return AppLocalizations.of(context)?.validPhone ??
                      '请输入有效的手机号';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _introductionController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)?.introduction ?? '个人简介',
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              maxLength: 100,
              validator: (value) {
                if (value != null && value.length > 100) {
                  return AppLocalizations.of(context)?.introductionLimit ??
                      '个人简介不能超过100个字符';
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
                      // 重置表单字段为当前用户数据
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
                  label: Text(AppLocalizations.of(context)?.cancel ?? '取消'),
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
                        Get.snackbar(
                          AppLocalizations.of(context)?.success ?? '成功',
                          AppLocalizations.of(context)?.profileUpdateSuccess ??
                              '个人资料更新成功',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          icon: Icon(Icons.check_circle, color: Colors.white),
                          duration: Duration(seconds: 2),
                        );
                      } else if (mounted) {
                        Get.snackbar(
                          AppLocalizations.of(context)?.error ?? '错误',
                          AppLocalizations.of(context)?.profileUpdateFailed ??
                              '更新个人资料失败',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                          icon: Icon(Icons.error, color: Colors.white),
                          duration: Duration(seconds: 2),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: Text(AppLocalizations.of(context)?.save ?? '保存'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建登录提示页面
  Widget _buildLoginPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.person, size: 64),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context)?.pleaseLogin ?? '请先登录'),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            Get.toNamed(AppRoutes.login);
          },
          icon: const Icon(Icons.login),
          label: Text(AppLocalizations.of(context)?.login ?? '登录'),
        ),
      ],
    );
  }

  /// 显示图片选择选项
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: Text(AppLocalizations.of(context)?.takePhoto ?? '拍照'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(
                  AppLocalizations.of(context)?.chooseFromGallery ?? '从相册选择'),
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

  /// 选择图片
  Future<void> _pickImage(ImageSource source) async {
    final authProvider = Get.find<AuthProvider>();
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 500,
        maxHeight: 500,
      );

      if (pickedFile != null) {
        // 读取图片字节而不是路径
        final bytes = await pickedFile.readAsBytes();
        final success = await authProvider.updateUserAvatar(bytes);

        if (success && mounted) {
          Get.snackbar(
            AppLocalizations.of(context)?.success ?? '成功',
            AppLocalizations.of(context)?.avatarUpdateSuccess ?? '头像更新成功',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: Icon(Icons.check_circle, color: Colors.white),
            duration: Duration(seconds: 2),
          );
        } else if (mounted) {
          Get.snackbar(
            AppLocalizations.of(context)?.error ?? '错误',
            AppLocalizations.of(context)?.avatarUpdateFailed ?? '更新头像失败',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            icon: Icon(Icons.error, color: Colors.white),
            duration: Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      AppLogger().e('选择图片错误: $e');
      if (mounted) {
        Get.snackbar(
          AppLocalizations.of(context)?.error ?? '错误',
          AppLocalizations.of(context)?.imagePickFailed ?? '选择图片失败',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: Icon(Icons.error, color: Colors.white),
          duration: Duration(seconds: 2),
        );
      }
    }
  }
}
