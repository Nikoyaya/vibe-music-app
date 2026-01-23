import 'package:floor/floor.dart';

/// 播放列表歌曲关联实体类
@Entity(tableName: 'playlist_songs')
class PlaylistSong {
  @PrimaryKey(autoGenerate: true)
  final int id;
  
  @ColumnInfo(name: 'playlist_id')
  final int playlistId;
  
  @ColumnInfo(name: 'song_id')
  final String songId;
  
  @ColumnInfo(name: 'song_name')
  final String songName;
  
  @ColumnInfo(name: 'artist_name')
  final String artistName;
  
  @ColumnInfo(name: 'cover_url')
  final String coverUrl;
  
  @ColumnInfo(name: 'song_url')
  final String songUrl;
  
  final String duration;
  
  final int position;
  
  @ColumnInfo(name: 'createdAt')
  final String createdAt;

  PlaylistSong({
    required this.id,
    required this.playlistId,
    required this.songId,
    required this.songName,
    required this.artistName,
    required this.coverUrl,
    required this.songUrl,
    required this.duration,
    required this.position,
    required this.createdAt,
  });
}