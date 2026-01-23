import 'package:floor/floor.dart';
import '../entity/playlist_song_entity.dart';

/// 播放列表歌曲关联数据访问对象
@dao
abstract class PlaylistSongDao {
  /// 获取所有播放列表歌曲关联
  @Query('SELECT * FROM playlist_songs')
  Future<List<PlaylistSong>> getAllPlaylistSongs();

  /// 根据播放列表ID获取歌曲
  @Query('SELECT * FROM playlist_songs WHERE playlist_id = :playlistId ORDER BY position ASC')
  Future<List<PlaylistSong>> getSongsByPlaylistId(int playlistId);

  /// 根据ID获取播放列表歌曲关联
  @Query('SELECT * FROM playlist_songs WHERE id = :id')
  Future<PlaylistSong?> getPlaylistSongById(int id);

  /// 插入播放列表歌曲关联
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertPlaylistSong(PlaylistSong playlistSong);

  /// 批量插入播放列表歌曲关联
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertPlaylistSongs(List<PlaylistSong> playlistSongs);

  /// 更新播放列表歌曲关联
  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updatePlaylistSong(PlaylistSong playlistSong);

  /// 根据ID删除播放列表歌曲关联
  @Query('DELETE FROM playlist_songs WHERE id = :id')
  Future<void> deletePlaylistSongById(int id);

  /// 根据播放列表ID删除所有关联歌曲
  @Query('DELETE FROM playlist_songs WHERE playlist_id = :playlistId')
  Future<void> deleteSongsByPlaylistId(int playlistId);

  /// 清除所有播放列表歌曲关联
  @Query('DELETE FROM playlist_songs')
  Future<void> clearAllPlaylistSongs();

  /// 更新播放列表歌曲的位置
  @Query('UPDATE playlist_songs SET position = :position WHERE id = :id')
  Future<void> updateSongPosition(int id, int position);
}