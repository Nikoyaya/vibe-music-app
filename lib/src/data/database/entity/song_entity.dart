import 'package:floor/floor.dart';

/// 歌曲实体类
@Entity(tableName: 'songs')
class Song {
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
  
  @ColumnInfo(name: 'isFavorite')
  final int isFavorite;
  
  @ColumnInfo(name: 'createdAt')
  final String createdAt;

  Song({
    required this.id,
    required this.songId,
    required this.songName,
    required this.artistName,
    required this.coverUrl,
    required this.songUrl,
    required this.duration,
    required this.isFavorite,
    required this.createdAt,
  });
}