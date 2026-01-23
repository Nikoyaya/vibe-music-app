import 'package:floor/floor.dart';
import '../entity/playlist_entity.dart';

/// 播放列表数据访问对象
@dao
abstract class PlaylistDao {
  /// 获取所有播放列表
  @Query('SELECT * FROM playlists ORDER BY createdAt DESC')
  Future<List<Playlist>> getAllPlaylists();

  /// 根据ID获取播放列表
  @Query('SELECT * FROM playlists WHERE id = :id')
  Future<Playlist?> getPlaylistById(int id);

  /// 根据名称获取播放列表
  @Query('SELECT * FROM playlists WHERE name = :name')
  Future<Playlist?> getPlaylistByName(String name);

  /// 插入播放列表
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertPlaylist(Playlist playlist);

  /// 更新播放列表
  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updatePlaylist(Playlist playlist);

  /// 根据ID删除播放列表
  @Query('DELETE FROM playlists WHERE id = :id')
  Future<void> deletePlaylistById(int id);

  /// 清除所有播放列表
  @Query('DELETE FROM playlists')
  Future<void> clearAllPlaylists();
}