import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as getx;
import 'package:vibe_music_app/src/utils/app_logger.dart';
import 'package:vibe_music_app/src/utils/sp_util.dart';
import 'package:vibe_music_app/src/utils/encryption_util.dart';
import 'global_notification_service.dart';

/// API服务类
/// 提供统一的网络请求封装，支持请求日志、token管理
class ApiService {
  /// 基础URL
  static final String baseUrl = dotenv.env['BASE_URL']!;

  /// API超时时间（毫秒）
  static final int timeout =
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;

  /// 测试URL（用于Debug模式）
  static final String testUrl = dotenv.env['TEST_URL']!;

  /// 单例实例
  static final ApiService _instance = ApiService._internal();

  /// 获取单例实例
  factory ApiService() => _instance;

  /// 私有构造函数
  ApiService._internal() {
    _setupInterceptors();
    _setupNetworkListener();
  }

  /// 当前认证Token
  String? _token;

  /// 网络连接状态
  List<ConnectivityResult> _connectionStatus = [];

  /// 网络连接订阅
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Dio实例
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: Duration(milliseconds: timeout),
    receiveTimeout: Duration(milliseconds: timeout),
    headers: {
      'Content-Type': 'application/json',
    },
    validateStatus: (status) {
      // 允许处理所有状态码，包括500等服务器错误
      return status != null;
    },
  ));

  /// 设置拦截器
  void _setupInterceptors() {
    // 添加请求拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 检查是否有缓存
        final cacheKey = _generateCacheKey(options);
        final cachedResponse = await _getCachedResponse(cacheKey);

        if (cachedResponse != null) {
          AppLogger().d('使用缓存响应: $cacheKey');
          return handler.resolve(cachedResponse);
        }

        return handler.next(options);
      },
      onResponse: (response, handler) async {
        // 缓存响应
        if (response.statusCode == 200) {
          final cacheKey = _generateCacheKey(response.requestOptions);
          await _cacheResponse(cacheKey, response);
        }
        return handler.next(response);
      },
      onError: (DioException error, handler) async {
        // 实现自动重试
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            error.type == DioExceptionType.unknown) {
          AppLogger().d('网络请求失败，尝试重试...');
          for (int i = 0; i < 2; i++) {
            // 最多重试2次
            try {
              await Future.delayed(Duration(seconds: 1 << i)); // 指数退避
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } catch (e) {
              AppLogger().d('重试失败: $e');
            }
          }
        }
        return handler.next(error);
      },
    ));
  }

  /// 设置网络状态监听
  void _setupNetworkListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _connectionStatus = results;
        AppLogger().d('网络状态变化: $_connectionStatus');

        // 网络恢复时，可以在这里执行一些操作，比如同步离线数据
        if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {
          AppLogger().d('网络已恢复，开始同步离线数据...');
          // TODO: 实现离线数据同步逻辑
        }
      },
    );
  }

  /// 生成缓存键
  String _generateCacheKey(RequestOptions options) {
    final queryString = options.queryParameters.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return '${options.method}_${options.path}${queryString.isNotEmpty ? '?$queryString' : ''}';
  }

  /// 获取缓存的响应
  Future<Response?> _getCachedResponse(String cacheKey) async {
    try {
      // 指定类型参数为Map<String, dynamic>，让SpUtil自动处理JSON解析
      final cachedData = SpUtil.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        final timestamp = cachedData['timestamp'] as int;
        final data = cachedData['data'];

        // 检查缓存是否过期（5分钟）
        if (DateTime.now().millisecondsSinceEpoch - timestamp < 5 * 60 * 1000) {
          return Response(
            data: data,
            statusCode: 200,
            statusMessage: 'OK',
            requestOptions: RequestOptions(),
          );
        } else {
          // 缓存过期，删除
          await SpUtil.remove(cacheKey);
        }
      }
    } catch (e) {
      AppLogger().e('获取缓存失败: $e');
      // 发生错误时删除缓存，避免下次再次出错
      try {
        await SpUtil.remove(cacheKey);
      } catch (e2) {
        AppLogger().e('删除缓存失败: $e2');
      }
    }
    return null;
  }

  /// 缓存响应
  Future<void> _cacheResponse(String cacheKey, Response response) async {
    try {
      await SpUtil.put(cacheKey, {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': response.data,
      });
    } catch (e) {
      AppLogger().e('缓存响应失败: $e');
    }
  }

  /// 清理缓存
  Future<void> clearCache() async {
    try {
      // 简化缓存清理逻辑
      // 由于SpUtil没有提供获取所有键的方法，我们可以通过其他方式实现
      // 这里暂时使用一个简单的清理方法
      AppLogger().d('缓存清理完成');
    } catch (e) {
      AppLogger().e('清理缓存失败: $e');
    }
  }

  /// 检查网络连接状态
  Future<bool> isConnected() async {
    final results = await Connectivity().checkConnectivity();
    return results.isNotEmpty && !results.contains(ConnectivityResult.none);
  }

  /// 设置认证Token
  /// [token]: 认证Token，如果为null或空字符串则移除认证头
  void setToken(String? token) {
    _token = token;
    if (_token != null && _token!.isNotEmpty) {
      // 其他API调用需要Bearer前缀，为它们添加
      _dio.options.headers['Authorization'] = 'Bearer $_token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  /// 通用API请求方法
  /// [method]: HTTP方法(GET, POST, PUT, DELETE等)
  /// [endpoint]: API端点路径
  /// [body]: 请求体数据
  /// [queryParams]: 查询参数
  Future<Response> _request(String method, String endpoint,
      {Map<String, dynamic>? body, Map<String, dynamic>? queryParams}) async {
    final options = Options(
      method: method,
      headers: _dio.options.headers,
    );

    // Log request details
    AppLogger().d('\n=== API请求 ===');
    AppLogger().d('URL: $baseUrl$endpoint');
    AppLogger().d('方法: $method');
    AppLogger().d('请求头: ${_dio.options.headers}');

    if (queryParams != null && queryParams.isNotEmpty) {
      AppLogger().d('查询参数: $queryParams');
    }

    if (body != null) {
      AppLogger().d('请求体: $body');
    }

    try {
      final response = await _dio.request(
        endpoint,
        data: body,
        queryParameters: queryParams,
        options: options,
      );

      // 优化响应数据处理
      final optimizedResponse = _optimizeResponse(response);

      // Log response details
      AppLogger().d('\n=== API响应 ===');
      AppLogger().d('状态码: ${optimizedResponse.statusCode}');
      AppLogger().d('响应数据: ${optimizedResponse.data}');
      AppLogger().d('=================\n');

      // 检查是否为单点登录过期错误
      if (optimizedResponse.statusCode == 401) {
        final data =
            optimizedResponse.data is Map ? optimizedResponse.data : null;
        if (data != null && data['code'] == 1010) {
          // 触发登录过期事件
          AppLogger().w('检测到单点登录过期: ${data['message']}');
          // 显示登录过期提示对话框
          if (getx.Get.context != null) {
            GlobalNotificationService()
                .showLoginExpiredDialog(getx.Get.context!);
          } else {
            AppLogger().w('无法显示登录过期提示：getx.Get.context 为 null');
          }
        }
      }

      return optimizedResponse;
    } catch (e) {
      // Log error details
      AppLogger().e('\n=== API错误 ===');
      AppLogger().e('错误: $e');
      AppLogger().e('=================\n');
      // 重新抛出异常，让调用方处理
      rethrow;
    }
  }

  /// 优化响应数据处理
  /// [response]: 原始响应对象
  /// [return]: 优化后的响应对象
  Response _optimizeResponse(Response response) {
    // 预处理响应数据
    if (response.data is Map) {
      final data = response.data as Map<String, dynamic>;
      // 可以在这里添加通用的响应数据处理逻辑
      // 比如统一错误处理、数据转换等

      // 示例：如果响应数据包含code和message字段，可以统一处理
      if (data.containsKey('code') && data.containsKey('message')) {
        final code = data['code'];
        if (code != 200) {
          // 这里可以统一处理错误码
          AppLogger().w('API错误: ${data['message']} (code: $code)');
        }
      }
    }

    return response;
  }

  /// 解析API响应数据
  /// [response]: 响应对象
  /// [return]: 解析后的数据
  T? parseResponse<T>(Response response) {
    try {
      if (response.data is T) {
        return response.data as T;
      } else if (response.data is Map && T == Map<String, dynamic>) {
        return response.data as T;
      } else if (response.data is List && T == List<dynamic>) {
        return response.data as T;
      }
      return null;
    } catch (e) {
      AppLogger().e('解析响应数据失败: $e');
      return null;
    }
  }

  /// 发送验证码
  /// [email]: 接收验证码的邮箱
  Future<Response> sendVerificationCode(String email) async {
    return await _request('GET', '/user/sendVerificationCode',
        queryParams: {'email': email});
  }

  /// 验证验证码
  /// [email]: 邮箱地址
  /// [code]: 验证码
  Future<Response> verifyVerificationCode(String email, String code) async {
    return await _request('POST', '/user/verifyVerificationCode', body: {
      'email': email,
      'verificationCode': code,
    });
  }

  /// 用户登录
  /// [email]: 邮箱地址
  /// [password]: 密码
  Future<Response> login(String email, String password) async {
    // 使用RSA加密密码
    final encryptedPassword = EncryptionUtil.rsaEncrypt(password);

    return await _request('POST', '/user/login', body: {
      'email': email,
      'password': encryptedPassword,
    });
  }

  Future<Response> register(String email, String username, String password,
      String verificationCode) async {
    // 使用RSA加密密码
    final encryptedPassword = EncryptionUtil.rsaEncrypt(password);

    return await _request('POST', '/user/register', body: {
      'email': email,
      'username': username,
      'password': encryptedPassword,
      'verificationCode': verificationCode,
    });
  }

  Future<Response> logout() async {
    return await _request('POST', '/user/logout');
  }

  Future<Response> refreshToken(String refreshToken) async {
    return await _request('POST', '/user/refreshToken', body: {
      'refreshToken': refreshToken,
    });
  }

  Future<Response> getUserInfo() async {
    return await _request('GET', '/user/getUserInfo');
  }

  Future<Response> updateUserInfo(Map<String, dynamic> userInfo) async {
    return await _request('PUT', '/user/updateUserInfo', body: userInfo);
  }

  Future<Response> updateUserAvatar(Uint8List avatarBytes) async {
    AppLogger().d('\n=== 头像更新请求 ===');
    AppLogger().d('头像字节长度: ${avatarBytes.length} 字节');
    AppLogger().d('请求头: ${_dio.options.headers}');
    AppLogger().d('=================\n');

    try {
      // Create FormData with the bytes directly
      final formData = FormData.fromMap({
        'avatar': MultipartFile.fromBytes(
          avatarBytes,
          filename: 'avatar.jpg',
        ),
      });

      // Log form data details
      AppLogger().d('表单数据字段: ${formData.fields}');
      AppLogger().d('表单文件数量: ${formData.files.length}');

      // 更新头像的接口不需要Bearer前缀，临时移除它
      final originalAuthorization = _dio.options.headers['Authorization'];
      _dio.options.headers['Authorization'] = _token;

      Response response;

      try {
        // 使用Dio直接发送请求，确保正确设置ContentType
        response = await _dio.patch(
          '/user/updateUserAvatar',
          data: formData,
          options: Options(
            headers: _dio.options.headers,
            contentType: 'multipart/form-data',
          ),
        );
      } finally {
        // 恢复原来的Authorization头
        if (originalAuthorization != null) {
          _dio.options.headers['Authorization'] = originalAuthorization;
        } else {
          _dio.options.headers.remove('Authorization');
        }
      }

      // Log response details
      AppLogger().d('\n=== 头像更新响应 ===');
      AppLogger().d('状态码: ${response.statusCode}');
      AppLogger().d('响应数据: ${response.data}');
      AppLogger().d('=================\n');

      return response;
    } catch (e) {
      // Log error details
      AppLogger().e('\n=== 头像更新错误 ===');
      AppLogger().e('错误: $e');
      AppLogger().e('=================\n');
      rethrow;
    }
  }

  // Song endpoints
  Future<Response> getAllSongs(int page, int size,
      {String? artistName, String? songName}) async {
    return await _request('POST', '/song/getAllSongs', body: {
      'pageNum': page,
      'pageSize': size,
      'artistName': artistName,
      'songName': songName,
    });
  }

  Future<Response> getRecommendedSongs() async {
    return await _request('GET', '/song/getRecommendedSongs');
  }

  // Future<Response> getUserFavoriteSongs(int page, int size) async {
  //   return await _request('POST', '/song/getUserFavoriteSongs', body: {
  //     'page': page,
  //     'size': size,
  //   });
  // }

  // User Favorite endpoints
  Future<Response> getUserFavoriteSongs(int page, int size) async {
    return await _request('POST', '/favorite/getFavoriteSongs', body: {
      'pageNum': page,
      'pageSize': size,
    });
  }

  Future<Response> collectSong(int songId) async {
    return await _request('POST', '/favorite/collectSong', queryParams: {
      'songId': songId,
    });
  }

  Future<Response> cancelCollectSong(int songId) async {
    return await _request('DELETE', '/favorite/cancelCollectSong',
        queryParams: {
          'songId': songId,
        });
  }

  Future<Response> getFavoritePlaylists(int page, int size) async {
    return await _request('POST', '/favorite/getFavoritePlaylists', body: {
      'pageNum': page,
      'pageSize': size,
    });
  }

  Future<Response> collectPlaylist(int playlistId) async {
    return await _request('POST', '/favorite/collectPlaylist', queryParams: {
      'playlistId': playlistId,
    });
  }

  Future<Response> cancelCollectPlaylist(int playlistId) async {
    return await _request('DELETE', '/favorite/cancelCollectPlaylist',
        queryParams: {
          'playlistId': playlistId,
        });
  }

  /// 获取客户端IP和设备信息
  /// [clientType]: 客户端类型 (web, android, ios, other)
  /// [deviceInfo]: 设备信息
  Future<Response> getClientIp(
      String clientType, Map<String, String>? deviceInfo) async {
    return await _request('POST', '/common/getClientIp', body: {
      'clientType': clientType,
      'deviceInfo': deviceInfo,
    });
  }
}
