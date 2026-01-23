import 'package:floor/floor.dart';

/// 用户实体类
@Entity(tableName: 'users')
class User {
  @PrimaryKey(autoGenerate: true)
  final int id;
  
  @ColumnInfo(name: 'userId')
  final String userId;
  
  final String username;
  final String email;
  final String avatar;
  
  @ColumnInfo(name: 'createdAt')
  final String createdAt;

  User({
    required this.id,
    required this.userId,
    required this.username,
    required this.email,
    required this.avatar,
    required this.createdAt,
  });
}