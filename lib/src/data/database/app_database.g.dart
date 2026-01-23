// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  UserDao? _userDaoInstance;

  SongDao? _songDaoInstance;

  PlaylistDao? _playlistDaoInstance;

  PlaylistSongDao? _playlistSongDaoInstance;

  PlayHistoryDao? _playHistoryDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `users` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `userId` TEXT NOT NULL, `username` TEXT NOT NULL, `email` TEXT NOT NULL, `avatar` TEXT NOT NULL, `createdAt` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `songs` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `songId` TEXT NOT NULL, `songName` TEXT NOT NULL, `artistName` TEXT NOT NULL, `coverUrl` TEXT NOT NULL, `songUrl` TEXT NOT NULL, `duration` TEXT NOT NULL, `isFavorite` INTEGER NOT NULL, `createdAt` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `playlists` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `name` TEXT NOT NULL, `createdAt` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `playlist_songs` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `playlist_id` INTEGER NOT NULL, `song_id` TEXT NOT NULL, `song_name` TEXT NOT NULL, `artist_name` TEXT NOT NULL, `cover_url` TEXT NOT NULL, `song_url` TEXT NOT NULL, `duration` TEXT NOT NULL, `position` INTEGER NOT NULL, `createdAt` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `play_history` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `songId` TEXT NOT NULL, `songName` TEXT NOT NULL, `artistName` TEXT NOT NULL, `coverUrl` TEXT NOT NULL, `songUrl` TEXT NOT NULL, `duration` TEXT NOT NULL, `playedAt` TEXT NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  UserDao get userDao {
    return _userDaoInstance ??= _$UserDao(database, changeListener);
  }

  @override
  SongDao get songDao {
    return _songDaoInstance ??= _$SongDao(database, changeListener);
  }

  @override
  PlaylistDao get playlistDao {
    return _playlistDaoInstance ??= _$PlaylistDao(database, changeListener);
  }

  @override
  PlaylistSongDao get playlistSongDao {
    return _playlistSongDaoInstance ??=
        _$PlaylistSongDao(database, changeListener);
  }

  @override
  PlayHistoryDao get playHistoryDao {
    return _playHistoryDaoInstance ??=
        _$PlayHistoryDao(database, changeListener);
  }
}

class _$UserDao extends UserDao {
  _$UserDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _userInsertionAdapter = InsertionAdapter(
            database,
            'users',
            (User item) => <String, Object?>{
                  'id': item.id,
                  'userId': item.userId,
                  'username': item.username,
                  'email': item.email,
                  'avatar': item.avatar,
                  'createdAt': item.createdAt
                }),
        _userUpdateAdapter = UpdateAdapter(
            database,
            'users',
            ['id'],
            (User item) => <String, Object?>{
                  'id': item.id,
                  'userId': item.userId,
                  'username': item.username,
                  'email': item.email,
                  'avatar': item.avatar,
                  'createdAt': item.createdAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<User> _userInsertionAdapter;

  final UpdateAdapter<User> _userUpdateAdapter;

  @override
  Future<List<User>> getAllUsers() async {
    return _queryAdapter.queryList('SELECT * FROM users',
        mapper: (Map<String, Object?> row) => User(
            id: row['id'] as int,
            userId: row['userId'] as String,
            username: row['username'] as String,
            email: row['email'] as String,
            avatar: row['avatar'] as String,
            createdAt: row['createdAt'] as String));
  }

  @override
  Future<User?> getUserByUserId(String userId) async {
    return _queryAdapter.query('SELECT * FROM users WHERE userId = ?1',
        mapper: (Map<String, Object?> row) => User(
            id: row['id'] as int,
            userId: row['userId'] as String,
            username: row['username'] as String,
            email: row['email'] as String,
            avatar: row['avatar'] as String,
            createdAt: row['createdAt'] as String),
        arguments: [userId]);
  }

  @override
  Future<User?> getUserById(int id) async {
    return _queryAdapter.query('SELECT * FROM users WHERE id = ?1',
        mapper: (Map<String, Object?> row) => User(
            id: row['id'] as int,
            userId: row['userId'] as String,
            username: row['username'] as String,
            email: row['email'] as String,
            avatar: row['avatar'] as String,
            createdAt: row['createdAt'] as String),
        arguments: [id]);
  }

  @override
  Future<void> deleteUserByUserId(String userId) async {
    await _queryAdapter.queryNoReturn('DELETE FROM users WHERE userId = ?1',
        arguments: [userId]);
  }

  @override
  Future<void> clearAllUsers() async {
    await _queryAdapter.queryNoReturn('DELETE FROM users');
  }

  @override
  Future<void> insertUser(User user) async {
    await _userInsertionAdapter.insert(user, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateUser(User user) async {
    await _userUpdateAdapter.update(user, OnConflictStrategy.replace);
  }
}

class _$SongDao extends SongDao {
  _$SongDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _songInsertionAdapter = InsertionAdapter(
            database,
            'songs',
            (Song item) => <String, Object?>{
                  'id': item.id,
                  'songId': item.songId,
                  'songName': item.songName,
                  'artistName': item.artistName,
                  'coverUrl': item.coverUrl,
                  'songUrl': item.songUrl,
                  'duration': item.duration,
                  'isFavorite': item.isFavorite,
                  'createdAt': item.createdAt
                }),
        _songUpdateAdapter = UpdateAdapter(
            database,
            'songs',
            ['id'],
            (Song item) => <String, Object?>{
                  'id': item.id,
                  'songId': item.songId,
                  'songName': item.songName,
                  'artistName': item.artistName,
                  'coverUrl': item.coverUrl,
                  'songUrl': item.songUrl,
                  'duration': item.duration,
                  'isFavorite': item.isFavorite,
                  'createdAt': item.createdAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Song> _songInsertionAdapter;

  final UpdateAdapter<Song> _songUpdateAdapter;

  @override
  Future<List<Song>> getAllSongs() async {
    return _queryAdapter.queryList('SELECT * FROM songs',
        mapper: (Map<String, Object?> row) => Song(
            id: row['id'] as int,
            songId: row['songId'] as String,
            songName: row['songName'] as String,
            artistName: row['artistName'] as String,
            coverUrl: row['coverUrl'] as String,
            songUrl: row['songUrl'] as String,
            duration: row['duration'] as String,
            isFavorite: row['isFavorite'] as int,
            createdAt: row['createdAt'] as String));
  }

  @override
  Future<Song?> getSongBySongId(String songId) async {
    return _queryAdapter.query('SELECT * FROM songs WHERE songId = ?1',
        mapper: (Map<String, Object?> row) => Song(
            id: row['id'] as int,
            songId: row['songId'] as String,
            songName: row['songName'] as String,
            artistName: row['artistName'] as String,
            coverUrl: row['coverUrl'] as String,
            songUrl: row['songUrl'] as String,
            duration: row['duration'] as String,
            isFavorite: row['isFavorite'] as int,
            createdAt: row['createdAt'] as String),
        arguments: [songId]);
  }

  @override
  Future<Song?> getSongById(int id) async {
    return _queryAdapter.query('SELECT * FROM songs WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Song(
            id: row['id'] as int,
            songId: row['songId'] as String,
            songName: row['songName'] as String,
            artistName: row['artistName'] as String,
            coverUrl: row['coverUrl'] as String,
            songUrl: row['songUrl'] as String,
            duration: row['duration'] as String,
            isFavorite: row['isFavorite'] as int,
            createdAt: row['createdAt'] as String),
        arguments: [id]);
  }

  @override
  Future<List<Song>> getFavoriteSongs() async {
    return _queryAdapter.queryList('SELECT * FROM songs WHERE isFavorite = 1',
        mapper: (Map<String, Object?> row) => Song(
            id: row['id'] as int,
            songId: row['songId'] as String,
            songName: row['songName'] as String,
            artistName: row['artistName'] as String,
            coverUrl: row['coverUrl'] as String,
            songUrl: row['songUrl'] as String,
            duration: row['duration'] as String,
            isFavorite: row['isFavorite'] as int,
            createdAt: row['createdAt'] as String));
  }

  @override
  Future<void> deleteSongBySongId(String songId) async {
    await _queryAdapter.queryNoReturn('DELETE FROM songs WHERE songId = ?1',
        arguments: [songId]);
  }

  @override
  Future<void> clearAllSongs() async {
    await _queryAdapter.queryNoReturn('DELETE FROM songs');
  }

  @override
  Future<void> updateSongFavoriteStatus(
    String songId,
    int isFavorite,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE songs SET isFavorite = ?2 WHERE songId = ?1',
        arguments: [songId, isFavorite]);
  }

  @override
  Future<void> insertSong(Song song) async {
    await _songInsertionAdapter.insert(song, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertSongs(List<Song> songs) {
    return _songInsertionAdapter.insertListAndReturnIds(
        songs, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateSong(Song song) async {
    await _songUpdateAdapter.update(song, OnConflictStrategy.replace);
  }
}

class _$PlaylistDao extends PlaylistDao {
  _$PlaylistDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _playlistInsertionAdapter = InsertionAdapter(
            database,
            'playlists',
            (Playlist item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'createdAt': item.createdAt
                }),
        _playlistUpdateAdapter = UpdateAdapter(
            database,
            'playlists',
            ['id'],
            (Playlist item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'createdAt': item.createdAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Playlist> _playlistInsertionAdapter;

  final UpdateAdapter<Playlist> _playlistUpdateAdapter;

  @override
  Future<List<Playlist>> getAllPlaylists() async {
    return _queryAdapter.queryList(
        'SELECT * FROM playlists ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => Playlist(
            id: row['id'] as int,
            name: row['name'] as String,
            createdAt: row['createdAt'] as String));
  }

  @override
  Future<Playlist?> getPlaylistById(int id) async {
    return _queryAdapter.query('SELECT * FROM playlists WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Playlist(
            id: row['id'] as int,
            name: row['name'] as String,
            createdAt: row['createdAt'] as String),
        arguments: [id]);
  }

  @override
  Future<Playlist?> getPlaylistByName(String name) async {
    return _queryAdapter.query('SELECT * FROM playlists WHERE name = ?1',
        mapper: (Map<String, Object?> row) => Playlist(
            id: row['id'] as int,
            name: row['name'] as String,
            createdAt: row['createdAt'] as String),
        arguments: [name]);
  }

  @override
  Future<void> deletePlaylistById(int id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM playlists WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> clearAllPlaylists() async {
    await _queryAdapter.queryNoReturn('DELETE FROM playlists');
  }

  @override
  Future<int> insertPlaylist(Playlist playlist) {
    return _playlistInsertionAdapter.insertAndReturnId(
        playlist, OnConflictStrategy.replace);
  }

  @override
  Future<void> updatePlaylist(Playlist playlist) async {
    await _playlistUpdateAdapter.update(playlist, OnConflictStrategy.replace);
  }
}

class _$PlaylistSongDao extends PlaylistSongDao {
  _$PlaylistSongDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _playlistSongInsertionAdapter = InsertionAdapter(
            database,
            'playlist_songs',
            (PlaylistSong item) => <String, Object?>{
                  'id': item.id,
                  'playlist_id': item.playlistId,
                  'song_id': item.songId,
                  'song_name': item.songName,
                  'artist_name': item.artistName,
                  'cover_url': item.coverUrl,
                  'song_url': item.songUrl,
                  'duration': item.duration,
                  'position': item.position,
                  'createdAt': item.createdAt
                }),
        _playlistSongUpdateAdapter = UpdateAdapter(
            database,
            'playlist_songs',
            ['id'],
            (PlaylistSong item) => <String, Object?>{
                  'id': item.id,
                  'playlist_id': item.playlistId,
                  'song_id': item.songId,
                  'song_name': item.songName,
                  'artist_name': item.artistName,
                  'cover_url': item.coverUrl,
                  'song_url': item.songUrl,
                  'duration': item.duration,
                  'position': item.position,
                  'createdAt': item.createdAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<PlaylistSong> _playlistSongInsertionAdapter;

  final UpdateAdapter<PlaylistSong> _playlistSongUpdateAdapter;

  @override
  Future<List<PlaylistSong>> getAllPlaylistSongs() async {
    return _queryAdapter.queryList('SELECT * FROM playlist_songs',
        mapper: (Map<String, Object?> row) => PlaylistSong(
            id: row['id'] as int,
            playlistId: row['playlist_id'] as int,
            songId: row['song_id'] as String,
            songName: row['song_name'] as String,
            artistName: row['artist_name'] as String,
            coverUrl: row['cover_url'] as String,
            songUrl: row['song_url'] as String,
            duration: row['duration'] as String,
            position: row['position'] as int,
            createdAt: row['createdAt'] as String));
  }

  @override
  Future<List<PlaylistSong>> getSongsByPlaylistId(int playlistId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM playlist_songs WHERE playlist_id = ?1 ORDER BY position ASC',
        mapper: (Map<String, Object?> row) => PlaylistSong(id: row['id'] as int, playlistId: row['playlist_id'] as int, songId: row['song_id'] as String, songName: row['song_name'] as String, artistName: row['artist_name'] as String, coverUrl: row['cover_url'] as String, songUrl: row['song_url'] as String, duration: row['duration'] as String, position: row['position'] as int, createdAt: row['createdAt'] as String),
        arguments: [playlistId]);
  }

  @override
  Future<PlaylistSong?> getPlaylistSongById(int id) async {
    return _queryAdapter.query('SELECT * FROM playlist_songs WHERE id = ?1',
        mapper: (Map<String, Object?> row) => PlaylistSong(
            id: row['id'] as int,
            playlistId: row['playlist_id'] as int,
            songId: row['song_id'] as String,
            songName: row['song_name'] as String,
            artistName: row['artist_name'] as String,
            coverUrl: row['cover_url'] as String,
            songUrl: row['song_url'] as String,
            duration: row['duration'] as String,
            position: row['position'] as int,
            createdAt: row['createdAt'] as String),
        arguments: [id]);
  }

  @override
  Future<void> deletePlaylistSongById(int id) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM playlist_songs WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> deleteSongsByPlaylistId(int playlistId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM playlist_songs WHERE playlist_id = ?1',
        arguments: [playlistId]);
  }

  @override
  Future<void> clearAllPlaylistSongs() async {
    await _queryAdapter.queryNoReturn('DELETE FROM playlist_songs');
  }

  @override
  Future<void> updateSongPosition(
    int id,
    int position,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE playlist_songs SET position = ?2 WHERE id = ?1',
        arguments: [id, position]);
  }

  @override
  Future<void> insertPlaylistSong(PlaylistSong playlistSong) async {
    await _playlistSongInsertionAdapter.insert(
        playlistSong, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertPlaylistSongs(List<PlaylistSong> playlistSongs) {
    return _playlistSongInsertionAdapter.insertListAndReturnIds(
        playlistSongs, OnConflictStrategy.replace);
  }

  @override
  Future<void> updatePlaylistSong(PlaylistSong playlistSong) async {
    await _playlistSongUpdateAdapter.update(
        playlistSong, OnConflictStrategy.replace);
  }
}

class _$PlayHistoryDao extends PlayHistoryDao {
  _$PlayHistoryDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _playHistoryInsertionAdapter = InsertionAdapter(
            database,
            'play_history',
            (PlayHistory item) => <String, Object?>{
                  'id': item.id,
                  'songId': item.songId,
                  'songName': item.songName,
                  'artistName': item.artistName,
                  'coverUrl': item.coverUrl,
                  'songUrl': item.songUrl,
                  'duration': item.duration,
                  'playedAt': item.playedAt
                }),
        _playHistoryUpdateAdapter = UpdateAdapter(
            database,
            'play_history',
            ['id'],
            (PlayHistory item) => <String, Object?>{
                  'id': item.id,
                  'songId': item.songId,
                  'songName': item.songName,
                  'artistName': item.artistName,
                  'coverUrl': item.coverUrl,
                  'songUrl': item.songUrl,
                  'duration': item.duration,
                  'playedAt': item.playedAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<PlayHistory> _playHistoryInsertionAdapter;

  final UpdateAdapter<PlayHistory> _playHistoryUpdateAdapter;

  @override
  Future<List<PlayHistory>> getAllPlayHistory() async {
    return _queryAdapter.queryList(
        'SELECT * FROM play_history ORDER BY playedAt DESC',
        mapper: (Map<String, Object?> row) => PlayHistory(
            id: row['id'] as int,
            songId: row['songId'] as String,
            songName: row['songName'] as String,
            artistName: row['artistName'] as String,
            coverUrl: row['coverUrl'] as String,
            songUrl: row['songUrl'] as String,
            duration: row['duration'] as String,
            playedAt: row['playedAt'] as String));
  }

  @override
  Future<List<PlayHistory>> getPlayHistoryBySongId(String songId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM play_history WHERE songId = ?1 ORDER BY playedAt DESC',
        mapper: (Map<String, Object?> row) => PlayHistory(
            id: row['id'] as int,
            songId: row['songId'] as String,
            songName: row['songName'] as String,
            artistName: row['artistName'] as String,
            coverUrl: row['coverUrl'] as String,
            songUrl: row['songUrl'] as String,
            duration: row['duration'] as String,
            playedAt: row['playedAt'] as String),
        arguments: [songId]);
  }

  @override
  Future<PlayHistory?> getPlayHistoryById(int id) async {
    return _queryAdapter.query('SELECT * FROM play_history WHERE id = ?1',
        mapper: (Map<String, Object?> row) => PlayHistory(
            id: row['id'] as int,
            songId: row['songId'] as String,
            songName: row['songName'] as String,
            artistName: row['artistName'] as String,
            coverUrl: row['coverUrl'] as String,
            songUrl: row['songUrl'] as String,
            duration: row['duration'] as String,
            playedAt: row['playedAt'] as String),
        arguments: [id]);
  }

  @override
  Future<List<PlayHistory>> getRecentPlayHistory(int limit) async {
    return _queryAdapter.queryList(
        'SELECT * FROM play_history ORDER BY playedAt DESC LIMIT ?1',
        mapper: (Map<String, Object?> row) => PlayHistory(
            id: row['id'] as int,
            songId: row['songId'] as String,
            songName: row['songName'] as String,
            artistName: row['artistName'] as String,
            coverUrl: row['coverUrl'] as String,
            songUrl: row['songUrl'] as String,
            duration: row['duration'] as String,
            playedAt: row['playedAt'] as String),
        arguments: [limit]);
  }

  @override
  Future<void> deletePlayHistoryById(int id) async {
    await _queryAdapter.queryNoReturn('DELETE FROM play_history WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> clearAllPlayHistory() async {
    await _queryAdapter.queryNoReturn('DELETE FROM play_history');
  }

  @override
  Future<void> clearOldPlayHistory(int keepCount) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM play_history WHERE id NOT IN (SELECT id FROM play_history ORDER BY playedAt DESC LIMIT ?1)',
        arguments: [keepCount]);
  }

  @override
  Future<void> insertPlayHistory(PlayHistory playHistory) async {
    await _playHistoryInsertionAdapter.insert(
        playHistory, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertPlayHistories(List<PlayHistory> playHistories) {
    return _playHistoryInsertionAdapter.insertListAndReturnIds(
        playHistories, OnConflictStrategy.replace);
  }

  @override
  Future<void> updatePlayHistory(PlayHistory playHistory) async {
    await _playHistoryUpdateAdapter.update(
        playHistory, OnConflictStrategy.replace);
  }
}
