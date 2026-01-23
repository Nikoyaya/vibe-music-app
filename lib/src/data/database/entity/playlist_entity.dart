import 'package:floor/floor.dart';

/// 播放列表实体类
@Entity(tableName: 'playlists')
class Playlist {
  @PrimaryKey(autoGenerate: true)
  final int id;
  
  final String name;
  
  @ColumnInfo(name: 'createdAt')
  final String createdAt;

  Playlist({
    required this.id,
    required this.name,
    required this.createdAt,
  });
}