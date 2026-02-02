import 'package:floor/floor.dart';
import '../entity/play_history_entity.dart';

/// 播放历史数据访问对象
@dao
abstract class PlayHistoryDao {
  /// 获取所有播放历史
  @Query('SELECT * FROM play_history ORDER BY playedAt DESC')
  Future<List<PlayHistory>> getAllPlayHistory();

  /// 根据歌曲ID获取播放历史
  @Query(
      'SELECT * FROM play_history WHERE songId = :songId ORDER BY playedAt DESC')
  Future<List<PlayHistory>> getPlayHistoryBySongId(String songId);

  /// 根据ID获取播放历史
  @Query('SELECT * FROM play_history WHERE id = :id')
  Future<PlayHistory?> getPlayHistoryById(int id);

  /// 获取最近的播放历史
  @Query('SELECT * FROM play_history ORDER BY playedAt DESC LIMIT :limit')
  Future<List<PlayHistory>> getRecentPlayHistory(int limit);

  /// 插入播放历史
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertPlayHistory(PlayHistory playHistory);

  /// 批量插入播放历史
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertPlayHistories(List<PlayHistory> playHistories);

  /// 更新播放历史
  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updatePlayHistory(PlayHistory playHistory);

  /// 根据ID删除播放历史
  @Query('DELETE FROM play_history WHERE id = :id')
  Future<void> deletePlayHistoryById(int id);

  /// 清除所有播放历史
  @Query('DELETE FROM play_history')
  Future<void> clearAllPlayHistory();

  /// 清除旧的播放历史（保留最近的N条）
  @Query(
      'DELETE FROM play_history WHERE id NOT IN (SELECT id FROM play_history ORDER BY playedAt DESC LIMIT :keepCount)')
  Future<void> clearOldPlayHistory(int keepCount);
}
