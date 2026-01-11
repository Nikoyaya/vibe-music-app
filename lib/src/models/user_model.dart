import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';

@freezed
class User with _$User {
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

  factory User.fromJson(Map<String, dynamic> json) {
    // Clean userAvatar URL if it has backticks or whitespace
    final cleanedUserAvatar =
        json['userAvatar']?.toString().trim().replaceAll(RegExp(r'^`|`$'), '');

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

// Extension for custom methods
extension UserExtension on User {
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

@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    String? token,
    String? refreshToken,
    User? user,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      refreshToken: json['refreshToken'],
      user: json['data'] != null ? User.fromJson(json['data']) : null,
    );
  }
}

@freezed
class UserRegisterDTO with _$UserRegisterDTO {
  const factory UserRegisterDTO({
    required String email,
    required String username,
    required String password,
  }) = _UserRegisterDTO;

  factory UserRegisterDTO.fromJson(Map<String, dynamic> json) {
    return UserRegisterDTO(
      email: json['email'],
      username: json['username'],
      password: json['password'],
    );
  }
}

@freezed
class UserLoginDTO with _$UserLoginDTO {
  const factory UserLoginDTO({
    required String username,
    required String password,
  }) = _UserLoginDTO;

  factory UserLoginDTO.fromJson(Map<String, dynamic> json) {
    return UserLoginDTO(
      username: json['username'],
      password: json['password'],
    );
  }
}
