# Retrofit 迁移计划

## 1. 迁移目的

将当前项目中的直接 Dio 调用迁移到 Retrofit 注解方式，以提高代码的可维护性、类型安全性和可读性。

## 2. 预期优势

- ✅ **类型安全**：自动生成类型安全的 API 客户端
- ✅ **代码简洁**：通过注解定义 API，减少样板代码
- ✅ **易于维护**：API 定义集中管理，便于修改和扩展
- ✅ **支持多种请求类型**：GET、POST、PUT、DELETE 等
- ✅ **支持各种参数类型**：路径参数、查询参数、请求体等

## 3. 所需依赖

在 `pubspec.yaml` 中添加以下依赖：

```yaml
dependencies:
  retrofit: ^4.0.0
dio: ^5.0.0  # Retrofit 基于 Dio
json_annotation: ^4.8.0

  dev_dependencies:
    retrofit_generator: ^7.0.0
    build_runner: ^2.4.0
    json_serializable: ^6.7.0
```

## 4. 迁移步骤

### 4.1 定义 API 模型类

为所有 API 响应定义模型类，并添加 `@JsonSerializable()` 注解：

```dart
import 'package:json_annotation/json_annotation.dart';

part 'song.g.dart';

@JsonSerializable()
class Song {
  final String id;
  final String songName;
  final String artistName;
  final String coverUrl;
  final String songUrl;
  final int duration;
  final bool isFavorite;
  final String createdAt;

  Song({
    required this.id,
    required this.songName,
    required this.artistName,
    required this.coverUrl,
    required this.songUrl,
    required this.duration,
    required this.isFavorite,
    required this.createdAt,
  });

  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);
  Map<String, dynamic> toJson() => _$SongToJson(this);
}
```

### 4.2 创建 API 接口

创建 `api_service.dart` 文件，定义 API 接口：

```dart
import 'package:retrofit/http.dart';
import 'package:dio/dio.dart';
import '../models/song.dart';

part 'api_service.g.dart';

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // 认证相关
  @POST("/auth/login")
  Future<HttpResponse<Map<String, dynamic>>> login(@Body() Map<String, dynamic> data);

  @POST("/auth/register")
  Future<HttpResponse<Map<String, dynamic>>> register(@Body() Map<String, dynamic> data);

  // 歌曲相关
  @GET("/songs")
  Future<HttpResponse<List<Song>>> getSongs();

  @GET("/songs/{id}")
  Future<HttpResponse<Song>> getSong(@Path("id") String id);

  // 收藏相关
  @POST("/songs/{id}/collect")
  Future<HttpResponse<void>> collectSong(@Path("id") String id);

  @DELETE("/songs/{id}/collect")
  Future<HttpResponse<void>> cancelCollectSong(@Path("id") String id);

  @GET("/user/favorites")
  Future<HttpResponse<List<Song>>> getUserFavoriteSongs(
    @Query("page") int page,
    @Query("size") int size,
  );

  // 搜索相关
  @GET("/search")
  Future<HttpResponse<List<Song>>> searchSongs(@Query("keyword") String keyword);

  // 播放历史相关
  @POST("/play-history")
  Future<HttpResponse<void>> savePlayHistory(@Body() Map<String, dynamic> data);
}
```

### 4.3 生成代码

运行代码生成命令：

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4.4 初始化 API 服务

在 `dependency_injection.dart` 中初始化 API 服务：

```dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../data/network/api_service.dart';

// 初始化 Dio
final dio = Dio(BaseOptions(
  baseUrl: dotenv.env['BASE_URL'] ?? '',
  connectTimeout: Duration(milliseconds: int.parse(dotenv.env['API_TIMEOUT'] ?? '30000')),
  receiveTimeout: Duration(milliseconds: int.parse(dotenv.env['API_TIMEOUT'] ?? '30000')),
));

// 添加拦截器
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    // 添加认证 token
    final token = SpUtil.get<String>('token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  },
  onResponse: (response, handler) {
    return handler.next(response);
  },
  onError: (DioError e, handler) {
    return handler.next(e);
  },
));

// 初始化 API 服务
final apiService = ApiService(dio);

// 添加到依赖注入
Get.put(apiService);
```

### 4.5 替换现有 Dio 调用

将项目中所有直接的 Dio 调用替换为 Retrofit API 服务调用：

#### 旧代码：
```dart
Future<List<Song>> loadUserFavoriteSongs({int page = 1, int size = 20}) async {
  try {
    final response = await ApiService().getUserFavoriteSongs(page, size);
    if (response.statusCode == 200) {
      final data = response.data is Map ? response.data : jsonDecode(response.data);
      if (data['code'] == 200 && data['data'] != null) {
        final List<dynamic> items = data['data']['items'] ?? [];
        return items.map((item) => Song.fromJson(item)).toList();
      }
    }
  } catch (e) {
    AppLogger().e('加载用户收藏歌曲失败: $e');
  }
  return [];
}
```

#### 新代码：
```dart
Future<List<Song>> loadUserFavoriteSongs({int page = 1, int size = 20}) async {
  try {
    final response = await _apiService.getUserFavoriteSongs(page, size);
    return response.data;
  } catch (e) {
    AppLogger().e('加载用户收藏歌曲失败: $e');
    return [];
  }
}
```

## 5. 测试和验证

1. **运行代码生成命令，确保没有错误**
2. **运行应用，测试所有 API 功能**
3. **检查是否有编译错误**
4. **测试各种场景，包括成功和失败情况**

## 6. 预期迁移工作量

- 定义模型类：约 2-3 小时
- 创建 API 接口：约 2-3 小时
- 替换现有 Dio 调用：约 4-6 小时
- 测试和验证：约 2-3 小时

**总计：约 10-15 小时**

## 7. 风险评估

1. **代码生成失败**：确保依赖版本兼容，特别是 Retrofit 和 Dio 的版本
2. **API 模型不匹配**：仔细检查 API 响应结构，确保模型定义正确
3. **现有功能破坏**：迁移后需全面测试所有 API 相关功能

## 8. 后续维护

- 新增 API 时，只需在 API 接口中添加对应的方法
- 修改 API 时，只需修改 API 接口定义，然后重新生成代码
- 保持依赖版本更新，特别是 Retrofit 和相关库

## 9. 结论

通过将当前项目迁移到 Retrofit，我们可以提高代码的可维护性、类型安全性和可读性，同时减少样板代码，便于后续的扩展和维护。迁移过程虽然需要一定的工作量，但长期来看是值得的。

---

**计划创建日期**：2026-01-24
**计划执行人**：开发者团队
**预期完成日期**：待定
