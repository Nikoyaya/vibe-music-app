import 'package:floor/floor.dart';
import '../entity/user_entity.dart';

/// 用户数据访问对象
@dao
abstract class UserDao {
  /// 获取所有用户
  @Query('SELECT * FROM users')
  Future<List<User>> getAllUsers();

  /// 根据用户ID获取用户
  @Query('SELECT * FROM users WHERE userId = :userId')
  Future<User?> getUserByUserId(String userId);

  /// 根据ID获取用户
  @Query('SELECT * FROM users WHERE id = :id')
  Future<User?> getUserById(int id);

  /// 插入用户
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertUser(User user);

  /// 更新用户
  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updateUser(User user);

  /// 根据用户ID删除用户
  @Query('DELETE FROM users WHERE userId = :userId')
  Future<void> deleteUserByUserId(String userId);

  /// 清除所有用户
  @Query('DELETE FROM users')
  Future<void> clearAllUsers();
}