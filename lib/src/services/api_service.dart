import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:typed_data';

class ApiService {
  static final String baseUrl =
      dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8080';
  static final int timeout =
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;
  static final bool isPhone =
      (dotenv.env['IS_PHONE'] ?? 'false').toLowerCase() == 'true';
  static final String baseIp = dotenv.env['BASE_IP'] ?? 'http://192.168.31.76';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Helper method to recursively replace URLs in response data
  dynamic _replaceUrls(dynamic data) {
    if (data is String) {
      // If it's a string, replace the URL
      return data.replaceAll('http://192.168.100.128', baseIp);
    } else if (data is Map) {
      // If it's a map, recursively process each value
      final newMap = <String, dynamic>{};
      for (final entry in data.entries) {
        newMap[entry.key] = _replaceUrls(entry.value);
      }
      return newMap;
    } else if (data is List) {
      // If it's a list, recursively process each item
      return data.map((item) => _replaceUrls(item)).toList();
    }
    // If it's not a string, map, or list, return as is
    return data;
  }

  String? _token;
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: Duration(milliseconds: timeout),
    receiveTimeout: Duration(milliseconds: timeout),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  void setToken(String? token) {
    _token = token;
    if (_token != null && _token!.isNotEmpty) {
      // 其他API调用需要Bearer前缀，为它们添加
      _dio.options.headers['Authorization'] = 'Bearer $_token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  Future<Response> _request(String method, String endpoint,
      {Map<String, dynamic>? body, Map<String, dynamic>? queryParams}) async {
    final options = Options(
      method: method,
      headers: _dio.options.headers,
    );

    // Log request details
    print('\n=== API Request ===');
    print('URL: $baseUrl$endpoint');
    print('Method: $method');
    print('Headers: ${_dio.options.headers}');
    if (queryParams != null) {
      print('Query Params: $queryParams');
    }
    if (body != null) {
      print('Request Body: $body');
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
      print('\n=== API Response ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('=================\n');

      return response;
    } catch (e) {
      // Log error details
      print('\n=== API Error ===');
      print('Error: $e');
      print('=================\n');
      rethrow;
    }
  }

  // User endpoints
  Future<Response> sendVerificationCode(String email) async {
    return await _request('GET', '/user/sendVerificationCode',
        queryParams: {'email': email});
  }

  Future<Response> verifyVerificationCode(String email, String code) async {
    return await _request('POST', '/user/verifyVerificationCode', body: {
      'email': email,
      'verificationCode': code,
    });
  }

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

  Future<Response> register(
      String email, String username, String password) async {
    return await _request('POST', '/user/register', body: {
      'email': email,
      'username': username,
      'password': password,
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
    print('\n=== Avatar Update Request ===');
    print('Avatar Bytes Length: ${avatarBytes.length} bytes');
    print('Headers: ${_dio.options.headers}');
    print('=================\n');

    try {
      // Create FormData with the bytes directly
      final formData = FormData.fromMap({
        'avatar': MultipartFile.fromBytes(
          avatarBytes,
          filename: 'avatar.jpg',
        ),
      });

      // Log form data details
      print('Form Data Fields: ${formData.fields}');
      print('Form Files Count: ${formData.files.length}');

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
      print('\n=== Avatar Update Response ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('=================\n');

      return response;
    } catch (e) {
      // Log error details
      print('\n=== Avatar Update Error ===');
      print('Error: $e');
      print('=================\n');
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

  Future<Response> getUserFavoriteSongs(int page, int size) async {
    return await _request('POST', '/song/getUserFavoriteSongs', body: {
      'page': page,
      'size': size,
    });
  }

  Future<Response> addFavoriteSong(int songId) async {
    return await _request('POST', '/song/addFavoriteSong', body: {
      'songId': songId,
    });
  }

  Future<Response> removeFavoriteSong(int songId) async {
    return await _request('POST', '/song/removeFavoriteSong', body: {
      'songId': songId,
    });
  }
}
