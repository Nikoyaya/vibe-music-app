import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:typed_data';
import 'package:vibe_music_app/src/utils/app_logger.dart';

/// API服务类
/// 提供统一的网络请求封装，支持请求日志、token管理和URL替换
class ApiService {
  /// 基础URL
  static final String baseUrl =
      dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8080';

  /// API超时时间（毫秒）
  static final int timeout =
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;

  /// 是否为手机环境
  static final bool isPhone =
      (dotenv.env['IS_PHONE'] ?? 'false').toLowerCase() == 'true';

  /// 基础IP地址
  static final String baseIp = dotenv.env['BASE_IP'] ?? 'http://192.168.31.76';

  /// 单例实例
  static final ApiService _instance = ApiService._internal();

  /// 获取单例实例
  factory ApiService() => _instance;

  /// 私有构造函数
  ApiService._internal();

  /// 递归替换响应数据中的URL
  /// [data]: 响应数据，可以是字符串、Map或List
  dynamic _replaceUrls(dynamic data) {
    if (data is String) {
      // 如果是字符串，替换URL
      return data.replaceAll('http://192.168.100.128', baseIp);
    } else if (data is Map) {
      // 如果是Map，递归处理每个值
      final newMap = <String, dynamic>{};
      for (final entry in data.entries) {
        newMap[entry.key] = _replaceUrls(entry.value);
      }
      return newMap;
    } else if (data is List) {
      // 如果是List，递归处理每个项
      return data.map((item) => _replaceUrls(item)).toList();
    }
    // 如果不是字符串、Map或List，直接返回
    return data;
  }

  /// 当前认证Token
  String? _token;

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

      // Process response data to replace URLs if isPhone is true
      if (isPhone) {
        // Recursively replace URLs in all response data
        response.data = _replaceUrls(response.data);
      }

      // Log response details
      AppLogger().d('\n=== API响应 ===');
      AppLogger().d('状态码: ${response.statusCode}');
      AppLogger().d('响应数据: ${response.data}');
      AppLogger().d('=================\n');

      return response;
    } catch (e) {
      // Log error details
      AppLogger().e('\n=== API错误 ===');
      AppLogger().e('错误: $e');
      AppLogger().e('=================\n');
      rethrow;
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
    return await _request('POST', '/user/login', body: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> adminLogin(String username, String password) async {
    return await _request('POST', '/admin/login', body: {
      'username': username,
      'password': password,
    });
  }

  Future<Response> register(String email, String username, String password,
      String verificationCode) async {
    return await _request('POST', '/user/register', body: {
      'email': email,
      'username': username,
      'password': password,
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

  Future<Response> adminLogout() async {
    return await _request('POST', '/admin/logout');
  }

  Future<Response> getAllUsersCount() async {
    return await _request('GET', '/admin/getAllUsersCount');
  }

  Future<Response> getAllUsers(int page, int size, String? keyword) async {
    return await _request('POST', '/admin/getAllUsers', body: {
      'page': page,
      'size': size,
      'keyword': keyword,
    });
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
