import 'package:floor/floor.dart';

/// 播放历史实体类
@Entity(tableName: 'play_history')
class PlayHistory {
  @PrimaryKey(autoGenerate: true)
  final int id;
  
  @ColumnInfo(name: 'songId')
  final String songId;
  
  @ColumnInfo(name: 'songName')
  final String songName;
  
  @ColumnInfo(name: 'artistName')
  final String artistName;
  
  @ColumnInfo(name: 'coverUrl')
  final String coverUrl;
  
  @ColumnInfo(name: 'songUrl')
  final String songUrl;
  
  final String duration;
  
  @ColumnInfo(name: 'playedAt')
  final String playedAt;

  PlayHistory({
    required this.id,
    required this.songId,
    required this.songName,
    required this.artistName,
    required this.coverUrl,
    required this.songUrl,
    required this.duration,
    required this.playedAt,
  });
}