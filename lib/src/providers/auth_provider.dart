import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/src/services/api_service.dart';
import 'package:vibe_music_app/src/services/global_notification_service.dart';
import 'package:vibe_music_app/src/models/user_model.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';
import 'package:vibe_music_app/src/utils/sp_util.dart';
import 'package:vibe_music_app/src/utils/deviceInfoUtils/device_info_manager.dart';

/// 认证状态枚举
enum AuthStatus {
  unknown, // 未知状态
  unauthenticated, // 未认证
  authenticated, // 已认证
  loading, // 加载中
}

/// 认证提供者
/// 管理用户认证状态、token和用户信息
class AuthProvider extends GetxController {
  /// 认证状态
  final _status = AuthStatus.unknown.obs;

  /// 访问令牌
  final _token = Rxn<String>();

  /// 刷新令牌
  final _refreshToken = Rxn<String>();

  /// 令牌过期时间
  final _tokenExpiry = Rxn<DateTime>();

  /// 刷新令牌过期时间
  final _refreshTokenExpiry = Rxn<DateTime>();

  /// 用户信息
  final _user = Rxn<User>();

  /// 错误消息
  final _errorMessage = Rxn<String>();

  /// 获取认证状态
  AuthStatus get status => _status.value;

  /// 获取用户信息
  User? get user => _user.value;

  /// 获取令牌
  String? get token => _token.value;

  /// 获取错误消息
  String? get errorMessage => _errorMessage.value;

  /// 是否已认证
  bool get isAuthenticated => _status.value == AuthStatus.authenticated;

  /// 构造函数
  AuthProvider() {
    _loadAuthData();
  }

  /// 加载认证数据
  Future<void> _loadAuthData() async {
    final token = SpUtil.get<String>('token');
    final tokenExpiry = SpUtil.get<String>('tokenExpiry');
    final refreshToken = SpUtil.get<String>('refreshToken');
    final refreshTokenExpiry = SpUtil.get<String>('refreshTokenExpiry');
    final userJson = SpUtil.get<String>('user');

    if (token != null && userJson != null) {
      _token.value = token;
      _refreshToken.value = refreshToken;
      _tokenExpiry.value =
          tokenExpiry != null ? DateTime.parse(tokenExpiry) : null;
      _refreshTokenExpiry.value = refreshTokenExpiry != null
          ? DateTime.parse(refreshTokenExpiry)
          : null;
      _user.value = User.fromJson(jsonDecode(userJson));
      ApiService().setToken(token);

      // 检查token是否过期
      if (_tokenExpiry.value != null &&
          _tokenExpiry.value!.isAfter(DateTime.now())) {
        _status.value = AuthStatus.authenticated;
        // 获取最新的用户信息
        await _fetchUserInfo();
      } else {
        await _tryRefreshToken();
      }
    } else {
      _status.value = AuthStatus.unauthenticated;
    }
  }

  /// 获取用户信息
  Future<void> _fetchUserInfo() async {
    try {
      final response = await ApiService().getUserInfo();
      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : jsonDecode(response.data);
        if (data['code'] == 200 && data['data'] != null) {
          _user.value = User.fromJson(data['data']);
          await SpUtil.put('user', jsonEncode(_user.value!.toJson()));
        }
      }
    } catch (e) {
      AppLogger().e('获取用户信息失败: $e');
    }
  }

  /// 尝试刷新令牌
  Future<bool> _tryRefreshToken() async {
    if (_refreshToken.value == null ||
        _refreshTokenExpiry.value == null ||
        _refreshTokenExpiry.value!.isBefore(DateTime.now())) {
      return false;
    }

    try {
      final response = await ApiService().refreshToken(_refreshToken.value!);

      // 检查是否为登录过期错误（HTTP 401 + 错误码1010）
      if (response.statusCode == 401) {
        final data = response.data is Map ? response.data : null;
        if (data != null && data['code'] == 1010) {
          // 登录过期，清空登录信息并显示提示
          AppLogger().w('refreshToken返回登录过期错误: ${data['message']}');
          await logout();
          // 显示登录过期提示对话框
          AppLogger().d('尝试显示登录过期提示对话框，上下文是否可用: ${Get.context != null}');
          if (Get.context != null) {
            AppLogger().d('开始显示登录过期提示对话框');
            await GlobalNotificationService()
                .showLoginExpiredDialog(Get.context!);
            AppLogger().d('登录过期提示对话框显示完成');
          } else {
            AppLogger().w('无法显示登录过期提示：Get.context 为 null');
            // 如果上下文不可用，延迟一秒后再次尝试
            Future.delayed(Duration(seconds: 1), () async {
              if (Get.context != null) {
                AppLogger().d('延迟后上下文可用，显示登录过期提示对话框');
                await GlobalNotificationService()
                    .showLoginExpiredDialog(Get.context!);
              } else {
                AppLogger().e('延迟后上下文仍然不可用，无法显示登录过期提示');
              }
            });
          }
          return false;
        }
      }

      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : jsonDecode(response.data);
        if (data['code'] == 200 && data['data'] != null) {
          _token.value = data['data']['accessToken'];
          _tokenExpiry.value =
              DateTime.parse(data['data']['accessTokenExpireTime']);
          ApiService().setToken(_token.value);

          await SpUtil.put('token', _token.value!);
          await SpUtil.put(
              'tokenExpiry', _tokenExpiry.value!.toIso8601String());

          _status.value = AuthStatus.authenticated;
          return true;
        }
      }
    } catch (e) {
      AppLogger().e('刷新Token失败: $e');
    }

    await logout();
    return false;
  }

  /// 用户登录
  Future<bool> login(String usernameOrEmail, String password) async {
    _status.value = AuthStatus.loading;
    _errorMessage.value = null;

    try {
      AppLogger().d('🔍 开始登录: usernameOrEmail=$usernameOrEmail');

      final response = await ApiService().login(usernameOrEmail, password);

      AppLogger().d('📊 登录响应状态码: ${response.statusCode}');
      AppLogger().d('📋 登录响应体: ${response.data}');

      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : jsonDecode(response.data);
        AppLogger().d(
            '🔍 解析后的数据 - code: ${data['code']}, message: ${data['message']}');

        if (data['code'] == 200 && data['data'] != null) {
          AppLogger().d('✅ 登录成功，开始处理Token和用户数据...');

          _token.value = data['data']['accessToken'];
          _refreshToken.value = data['data']['refreshToken'];
          _tokenExpiry.value =
              DateTime.parse(data['data']['accessTokenExpireTime']);
          _refreshTokenExpiry.value =
              DateTime.parse(data['data']['refreshTokenExpireTime']);

          AppLogger().d(
              '🔑 Token信息 - accessToken: ${_token.value != null ? "存在" : "null"}, refreshToken: ${_refreshToken.value != null ? "存在" : "null"}');

          // 使用基础信息创建用户，详细用户信息通过_fetchUserInfo获取
          _user.value = User();

          AppLogger().d('👤 用户基本信息创建成功: ${_user.value?.username}');

          // 先设置Token，再获取完整的用户信息（因为getUserInfo需要认证）
          ApiService().setToken(_token.value);
          await _fetchUserInfo();

          await SpUtil.put('token', _token.value!);
          await SpUtil.put(
              'tokenExpiry', _tokenExpiry.value!.toIso8601String());
          if (_refreshToken.value != null) {
            await SpUtil.put('refreshToken', _refreshToken.value!);
            await SpUtil.put('refreshTokenExpiry',
                _refreshTokenExpiry.value!.toIso8601String());
          }
          await SpUtil.put('user', jsonEncode(_user.value!.toJson()));

          // 验证保存状态
          _logSpUtilState();

          // 获取设备信息并调用后端接口
          await _sendDeviceInfo();

          _status.value = AuthStatus.authenticated;
          AppLogger().d('🎉 登录流程完成，状态更新为已认证');
          return true;
        } else {
          _errorMessage.value =
              '服务器响应: code=${data['code']}, message=${data['message']}';
          AppLogger().e('❌ 登录失败: ${_errorMessage.value}');
          _status.value = AuthStatus.unauthenticated;
          return false;
        }
      } else {
        _errorMessage.value = '网络错误: ${response.statusCode}';
        AppLogger().e('❌ 网络错误: ${_errorMessage.value}');
        _status.value = AuthStatus.unauthenticated;
        return false;
      }
    } catch (e) {
      _errorMessage.value = '连接错误: $e';
      AppLogger().e('❌ 连接错误: ${_errorMessage.value}');
      _status.value = AuthStatus.unauthenticated;
      return false;
    }
  }

  /// 注册新用户
  Future<bool> register(String email, String username, String password,
      String verificationCode) async {
    _status.value = AuthStatus.loading;
    _errorMessage.value = null;

    try {
      final response = await ApiService()
          .register(email, username, password, verificationCode);

      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : jsonDecode(response.data);
        if (data['code'] == 200) {
          _status.value = AuthStatus.unauthenticated;
          return true;
        } else {
          _errorMessage.value = data['message'] ?? '注册失败';
          _status.value = AuthStatus.unauthenticated;
          return false;
        }
      } else {
        _errorMessage.value = '网络错误: ${response.statusCode}';
        _status.value = AuthStatus.unauthenticated;
        return false;
      }
    } catch (e) {
      _errorMessage.value = '连接错误: $e';
      _status.value = AuthStatus.unauthenticated;
      return false;
    }
  }

  /// 发送验证码
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

  /// 验证验证码
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

  /// 用户登出
  Future<void> logout() async {
    try {
      await ApiService().logout();
    } catch (_) {}

    _token.value = null;
    _refreshToken.value = null;
    _user.value = null;
    _status.value = AuthStatus.unauthenticated;
    ApiService().setToken(null);

    await SpUtil.remove('token');
    await SpUtil.remove('refreshToken');
    await SpUtil.remove('user');
  }

  /// 更新用户信息
  Future<bool> updateUserInfo(Map<String, dynamic> userInfo) async {
    try {
      final response = await ApiService().updateUserInfo(userInfo);
      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : jsonDecode(response.data);
        if (data['code'] == 200) {
          // 如果data['data']不为null，使用它更新用户信息；否则刷新用户信息
          if (data['data'] != null) {
            _user.value = User.fromJson(data['data']);
          } else {
            // 后端未返回用户数据，重新获取最新用户信息
            await _fetchUserInfo();
          }
          await SpUtil.put('user', jsonEncode(_user!.toJson()));
          return true;
        }
      }
      return false;
    } catch (e) {
      AppLogger().e('更新用户信息失败: $e');
      return false;
    }
  }

  /// 更新用户头像
  Future<bool> updateUserAvatar(Uint8List avatarBytes) async {
    // 检查用户是否已经登录
    if (!isAuthenticated || _user == null) {
      AppLogger().e('错误: 用户未登录');
      return false;
    }

    try {
      final response = await ApiService().updateUserAvatar(avatarBytes);
      AppLogger().d('头像更新响应: ${response.statusCode}, ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['code'] == 200) {
          // 更新成功后刷新用户信息
          await _fetchUserInfo();
          return true;
        } else {
          AppLogger().e('错误: 无效的响应数据格式');
        }
      } else {
        AppLogger().e('错误: 服务器返回状态码 ${response.statusCode}');
      }
      return false;
    } catch (e) {
      AppLogger().e('更新用户头像失败: $e');
      return false;
    }
  }

  /// 清除错误信息
  void clearError() {
    _errorMessage.value = null;
  }

  /// 记录SpUtil存储状态
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

  /// 发送设备信息到后端
  Future<void> _sendDeviceInfo() async {
    try {
      AppLogger().d('📱 开始获取设备信息...');

      // 获取当前设备信息
      final deviceInfo = await DeviceInfoManager.getCurrentPlatformDeviceInfo();

      // 确定客户端类型
      String clientType;
      if (kIsWeb) {
        clientType = "web";
      } else {
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            clientType = "android";
            break;
          case TargetPlatform.iOS:
            clientType = "ios";
            break;
          default:
            clientType = "other";
        }
      }

      AppLogger().d('📱 设备信息获取结果: ${deviceInfo != null ? "成功" : "失败"}');
      AppLogger().d('📱 客户端类型: $clientType');

      // 检查设备信息是否发生变更
      final storedDeviceInfo = SpUtil.get<String>('deviceInfo');
      final storedClientType = SpUtil.get<String>('clientType');

      // 将当前设备信息转换为字符串，用于比较
      final currentDeviceInfoStr =
          deviceInfo != null ? jsonEncode(deviceInfo) : null;

      // 检查是否需要更新设备信息
      bool needUpdate = false;

      if (storedDeviceInfo == null || storedClientType == null) {
        // 首次登录，需要更新
        needUpdate = true;
        AppLogger().d('📱 首次登录，需要更新设备信息');
      } else if (storedDeviceInfo != currentDeviceInfoStr ||
          storedClientType != clientType) {
        // 设备信息发生变更，需要更新
        needUpdate = true;
        AppLogger().d('📱 设备信息发生变更，需要更新');
        AppLogger().d('📱 存储的设备信息: $storedDeviceInfo');
        AppLogger().d('📱 当前设备信息: $currentDeviceInfoStr');
        AppLogger().d('📱 存储的客户端类型: $storedClientType');
        AppLogger().d('📱 当前客户端类型: $clientType');
      } else {
        // 设备信息未发生变更，不需要更新
        AppLogger().d('📱 设备信息未发生变更，不需要更新');
      }

      if (needUpdate) {
        // 调用后端接口
        final response = await ApiService().getClientIp(clientType, deviceInfo);

        AppLogger().d('📊 获取客户端IP响应状态码: ${response.statusCode}');

        // 只检查状态码，不需要处理返回的result信息
        if (response.statusCode == 200) {
          AppLogger().d('✅ 获取客户端IP和设备信息成功');
          // 存储设备信息到 SharedPreferences
          if (currentDeviceInfoStr != null) {
            await SpUtil.put('deviceInfo', currentDeviceInfoStr);
          }
          await SpUtil.put('clientType', clientType);
          AppLogger().d('✅ 设备信息已存储到 SharedPreferences');
        } else {
          AppLogger().e('❌ 网络错误: ${response.statusCode}');
        }
      }
    } catch (e) {
      AppLogger().e('❌ 发送设备信息失败: $e');
      // 设备信息发送失败不影响登录流程
    }
  }
}
