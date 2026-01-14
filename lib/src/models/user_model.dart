import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';

/// 用户模型类
/// 用于表示用户信息，包括基本属性和扩展方法
@freezed
class User with _$User {
  /// 用户构造函数
  /// [参数说明]:
  /// - [id]: 用户ID
  /// - [username]: 用户名
  /// - [email]: 邮箱
  /// - [avatar]: 头像URL
  /// - [userAvatar]: 用户头像URL
  /// - [phone]: 手机号
  /// - [introduction]: 个人简介
  /// - [role]: 角色(0:普通用户, 1:管理员)
  /// - [createTime]: 创建时间
  const factory User({
    int? id,
    String? username,
    String? email,
    String? avatar,
    String? userAvatar,
    String? phone,
    String? introduction,
    int? role,
    DateTime? createTime,
  }) = _User;

  /// 从JSON字符串解析为User对象
  /// [json]: JSON格式的用户数据
  factory User.fromJson(Map<String, dynamic> json) {
    // 清理userAvatar URL中的反引号和空格
    final cleanedUserAvatar = json['userAvatar']?.toString().trim().replaceAll(RegExp(r'^`|`$'), '');

    return User(
      id: json['id'] ?? json['userId'],
      username: json['username'],
      email: json['email'],
      avatar: json['avatar'] ?? cleanedUserAvatar,
      userAvatar: cleanedUserAvatar,
      phone: json['phone'],
      introduction: json['introduction'],
      role: json['role'],
      createTime: json['createTime'] != null
          ? DateTime.parse(json['createTime'])
          : null,
    );
  }
}

/// 用户扩展类
/// 提供自定义方法
extension UserExtension on User {
  /// 将User对象转换为JSON格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar': avatar ?? userAvatar,
      'userAvatar': userAvatar,
      'phone': phone,
      'introduction': introduction,
      'role': role,
      'createTime': createTime?.toIso8601String(),
    };
  }
}

/// 登录响应模型类
/// 用于表示登录成功后的返回数据
@freezed
class LoginResponse with _$LoginResponse {
  /// 登录响应构造函数
  /// [参数说明]:
  /// - [token]: 访问Token
  /// - [refreshToken]: 刷新Token
  /// - [user]: 用户信息
  const factory LoginResponse({
    String? token,
    String? refreshToken,
    User? user,
  }) = _LoginResponse;

  /// 从JSON字符串解析为LoginResponse对象
  /// [json]: JSON格式的登录响应数据
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      refreshToken: json['refreshToken'],
      user: json['data'] != null ? User.fromJson(json['data']) : null,
    );
  }
}

/// 用户注册数据传输对象
/// 用于表示注册请求的数据
@freezed
class UserRegisterDTO with _$UserRegisterDTO {
  /// 用户注册构造函数
  /// [参数说明]:
  /// - [email]: 邮箱
  /// - [username]: 用户名
  /// - [password]: 密码
  const factory UserRegisterDTO({
    required String email,
    required String username,
    required String password,
  }) = _UserRegisterDTO;

  /// 从JSON字符串解析为UserRegisterDTO对象
  /// [json]: JSON格式的注册数据
  factory UserRegisterDTO.fromJson(Map<String, dynamic> json) {
    return UserRegisterDTO(
      email: json['email'],
      username: json['username'],
      password: json['password'],
    );
  }
}

/// 用户登录数据传输对象
/// 用于表示登录请求的数据
@freezed
class UserLoginDTO with _$UserLoginDTO {
  /// 用户登录构造函数
  /// [参数说明]:
  /// - [username]: 用户名
  /// - [password]: 密码
  const factory UserLoginDTO({
    required String username,
    required String password,
  }) = _UserLoginDTO;

  /// 从JSON字符串解析为UserLoginDTO对象
  /// [json]: JSON格式的登录数据
  factory UserLoginDTO.fromJson(Map<String, dynamic> json) {
    return UserLoginDTO(
      username: json['username'],
      password: json['password'],
    );
  }
}
