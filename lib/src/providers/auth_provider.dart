import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:vibe_music_app/src/services/api_service.dart';
import 'package:vibe_music_app/src/models/user_model.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';
import 'package:vibe_music_app/src/utils/sp_util.dart';

enum AuthStatus {
  unknown,
  unauthenticated,
  authenticated,
  loading,
}

class AuthProvider with ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  String? _token;
  String? _refreshToken;
  DateTime? _tokenExpiry;
  DateTime? _refreshTokenExpiry;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get token => _token;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAdmin => _user?.role == 1;

  AuthProvider() {
    _loadAuthData();
  }

  Future<void> _loadAuthData() async {
    final token = SpUtil.get<String>('token');
    final tokenExpiry = SpUtil.get<String>('tokenExpiry');
    final refreshToken = SpUtil.get<String>('refreshToken');
    final refreshTokenExpiry = SpUtil.get<String>('refreshTokenExpiry');
    final userJson = SpUtil.get<String>('user');

    if (token != null && userJson != null) {
      _token = token;
      _refreshToken = refreshToken;
      _tokenExpiry = tokenExpiry != null ? DateTime.parse(tokenExpiry) : null;
      _refreshTokenExpiry = refreshTokenExpiry != null
          ? DateTime.parse(refreshTokenExpiry)
          : null;
      _user = User.fromJson(jsonDecode(userJson));
      ApiService().setToken(token);

      // 检查token是否过期
      if (_tokenExpiry != null && _tokenExpiry!.isAfter(DateTime.now())) {
        _status = AuthStatus.authenticated;
        // 获取最新的用户信息
        await _fetchUserInfo();
      } else {
        await _tryRefreshToken();
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> _fetchUserInfo() async {
    try {
      final response = await ApiService().getUserInfo();
      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : jsonDecode(response.data);
        if (data['code'] == 200 && data['data'] != null) {
          _user = User.fromJson(data['data']);
          await SpUtil.put('user', jsonEncode(_user!.toJson()));
          notifyListeners();
        }
      }
    } catch (e) {
      AppLogger().e('Failed to fetch user info: $e');
    }
  }

  Future<bool> _tryRefreshToken() async {
    if (_refreshToken == null ||
        _refreshTokenExpiry == null ||
        _refreshTokenExpiry!.isBefore(DateTime.now())) {
      return false;
    }

    try {
      final response = await ApiService().refreshToken(_refreshToken!);
      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : jsonDecode(response.data);
        if (data['code'] == 200 && data['data'] != null) {
          _token = data['data']['accessToken'];
          _tokenExpiry = DateTime.parse(data['data']['accessTokenExpireTime']);
          ApiService().setToken(_token);

          await SpUtil.put('token', _token!);
          await SpUtil.put('tokenExpiry', _tokenExpiry!.toIso8601String());

          _status = AuthStatus.authenticated;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      AppLogger().e('Refresh token failed: $e');
    }

    await logout();
    return false;
  }

  Future<bool> login(String usernameOrEmail, String password,
      {bool isAdmin = false}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      AppLogger()
          .d('🔍 开始登录: isAdmin=$isAdmin, usernameOrEmail=$usernameOrEmail');

      final response = isAdmin
          ? await ApiService().adminLogin(usernameOrEmail, password)
          : await ApiService().login(usernameOrEmail, password);

      AppLogger().d('📊 登录响应状态码: ${response.statusCode}');
      AppLogger().d('📋 登录响应体: ${response.data}');

      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : jsonDecode(response.data);
        AppLogger().d(
            '🔍 解析后的数据 - code: ${data['code']}, message: ${data['message']}');

        if (data['code'] == 200 && data['data'] != null) {
          AppLogger().d('✅ 登录成功，开始处理Token和用户数据...');

          _token = data['data']['accessToken'];
          _refreshToken = data['data']['refreshToken'];
          _tokenExpiry = DateTime.parse(data['data']['accessTokenExpireTime']);
          _refreshTokenExpiry =
              DateTime.parse(data['data']['refreshTokenExpireTime']);

          AppLogger().d(
              '🔑 Token信息 - accessToken: ${_token != null ? "存在" : "null"}, refreshToken: ${_refreshToken != null ? "存在" : "null"}');

          // 使用基础信息创建用户，详细用户信息通过_fetchUserInfo获取
          _user = User();

          AppLogger().d('👤 用户基本信息创建成功: ${_user?.username}');

          // 先设置Token，再获取完整的用户信息（因为getUserInfo需要认证）
          ApiService().setToken(_token);
          await _fetchUserInfo();

          await SpUtil.put('token', _token!);
          await SpUtil.put('tokenExpiry', _tokenExpiry!.toIso8601String());
          if (_refreshToken != null) {
            await SpUtil.put('refreshToken', _refreshToken!);
            await SpUtil.put(
                'refreshTokenExpiry', _refreshTokenExpiry!.toIso8601String());
          }
          await SpUtil.put('user', jsonEncode(_user!.toJson()));

          // 验证保存状态
          _logSpUtilState();

          _status = AuthStatus.authenticated;
          notifyListeners();
          AppLogger().d('🎉 登录流程完成，状态更新为已认证');
          return true;
        } else {
          _errorMessage =
              'Server response: code=${data['code']}, message=${data['message']}';
          AppLogger().e('❌ 登录失败: $_errorMessage');
          _status = AuthStatus.unauthenticated;
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = 'Network error: ${response.statusCode}';
        AppLogger().e('❌ 网络错误: $_errorMessage');
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
      AppLogger().e('❌ 连接错误: $_errorMessage');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String username, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService().register(email, username, password);

      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : jsonDecode(response.data);
        if (data['code'] == 200) {
          _status = AuthStatus.unauthenticated;
          notifyListeners();
          return true;
        } else {
          _errorMessage = data['msg'] ?? 'Registration failed';
          _status = AuthStatus.unauthenticated;
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = 'Network error: ${response.statusCode}';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendVerificationCode(String email) async {
    try {
      final response = await ApiService().sendVerificationCode(email);
      final data =
          response.data is Map ? response.data : jsonDecode(response.data);
      return data['code'] == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyVerificationCode(String email, String code) async {
    try {
      final response = await ApiService().verifyVerificationCode(email, code);
      final data =
          response.data is Map ? response.data : jsonDecode(response.data);
      return data['code'] == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await ApiService().logout();
    } catch (_) {}

    _token = null;
    _refreshToken = null;
    _user = null;
    _status = AuthStatus.unauthenticated;
    ApiService().setToken(null);

    await SpUtil.remove('token');
    await SpUtil.remove('refreshToken');
    await SpUtil.remove('user');

    notifyListeners();
  }

  Future<bool> updateUserInfo(Map<String, dynamic> userInfo) async {
    try {
      final response = await ApiService().updateUserInfo(userInfo);
      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : jsonDecode(response.data);
        if (data['code'] == 200) {
          // 如果data['data']不为null，使用它更新用户信息；否则刷新用户信息
          if (data['data'] != null) {
            _user = User.fromJson(data['data']);
          } else {
            // 后端未返回用户数据，重新获取最新用户信息
            await _fetchUserInfo();
          }
          await SpUtil.put('user', jsonEncode(_user!.toJson()));
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      AppLogger().e('Failed to update user info: $e');
      return false;
    }
  }

  Future<bool> updateUserAvatar(Uint8List avatarBytes) async {
    // 检查用户是否已经登录
    if (!isAuthenticated || _user == null) {
      AppLogger().e('Error: User not authenticated');
      return false;
    }

    try {
      final response = await ApiService().updateUserAvatar(avatarBytes);
      AppLogger().d(
          'Avatar update response: ${response.statusCode}, ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['code'] == 200) {
          // 更新成功后刷新用户信息
          await _fetchUserInfo();
          return true;
        } else {
          AppLogger().e('Error: Invalid response data format');
        }
      } else {
        AppLogger()
            .e('Error: Server returned status code ${response.statusCode}');
      }
      return false;
    } catch (e) {
      AppLogger().e('Failed to update user avatar: $e');
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _logSpUtilState() async {
    AppLogger().d('🔐 SpUtil 存储状态:');
    AppLogger().d(
        '  token: ${SpUtil.get<String>('token') != null ? "✓ 已保存" : "✗ 未保存"}');
    AppLogger().d('  tokenExpiry: ${SpUtil.get<String>('tokenExpiry')}');
    AppLogger().d(
        '  refreshToken: ${SpUtil.get<String>('refreshToken') != null ? "✓ 已保存" : "✗ 未保存"}');
    AppLogger()
        .d('  refreshTokenExpiry: ${SpUtil.get<String>('refreshTokenExpiry')}');
    AppLogger()
        .d('  user: ${SpUtil.get<String>('user') != null ? "✓ 已保存" : "✗ 未保存"}');
  }
}
