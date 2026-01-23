import 'package:floor/floor.dart';
import '../entity/song_entity.dart';

/// 歌曲数据访问对象
@dao
abstract class SongDao {
  /// 获取所有歌曲
  @Query('SELECT * FROM songs')
  Future<List<Song>> getAllSongs();

  /// 根据歌曲ID获取歌曲
  @Query('SELECT * FROM songs WHERE songId = :songId')
  Future<Song?> getSongBySongId(String songId);

  /// 根据ID获取歌曲
  @Query('SELECT * FROM songs WHERE id = :id')
  Future<Song?> getSongById(int id);

  /// 获取收藏的歌曲
  @Query('SELECT * FROM songs WHERE isFavorite = 1')
  Future<List<Song>> getFavoriteSongs();

  /// 插入歌曲
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertSong(Song song);

  /// 批量插入歌曲
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertSongs(List<Song> songs);

  /// 更新歌曲
  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updateSong(Song song);

  /// 根据歌曲ID删除歌曲
  @Query('DELETE FROM songs WHERE songId = :songId')
  Future<void> deleteSongBySongId(String songId);

  /// 清除所有歌曲
  @Query('DELETE FROM songs')
  Future<void> clearAllSongs();

  /// 更新歌曲收藏状态
  @Query('UPDATE songs SET isFavorite = :isFavorite WHERE songId = :songId')
  Future<void> updateSongFavoriteStatus(String songId, int isFavorite);
}