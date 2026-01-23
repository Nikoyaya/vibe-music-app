import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'dart:async';
import 'entity/user_entity.dart';
import 'entity/song_entity.dart';
import 'entity/playlist_entity.dart';
import 'entity/playlist_song_entity.dart';
import 'entity/play_history_entity.dart';
import 'dao/user_dao.dart';
import 'dao/song_dao.dart';
import 'dao/playlist_dao.dart';
import 'dao/playlist_song_dao.dart';
import 'dao/play_history_dao.dart';

part 'app_database.g.dart';

/// 应用数据库抽象类
@Database(
  version: 1,
  entities: [
    User,
    Song,
    Playlist,
    PlaylistSong,
    PlayHistory,
  ],
)
abstract class AppDatabase extends FloorDatabase {
  /// 用户数据访问对象
  UserDao get userDao;
  
  /// 歌曲数据访问对象
  SongDao get songDao;
  
  /// 播放列表数据访问对象
  PlaylistDao get playlistDao;
  
  /// 播放列表歌曲关联数据访问对象
  PlaylistSongDao get playlistSongDao;
  
  /// 播放历史数据访问对象
  PlayHistoryDao get playHistoryDao;
}
