import '../models/models.dart';
import '../../core/api/subsonic_api.dart';

class MusicRepository {
  final SubsonicApi _api;

  MusicRepository(this._api);

  Future<bool> ping() => _api.ping();

  Future<List<Album>> getAlbums({String type = 'newest', int size = 50, int offset = 0}) => _api.getAlbumList(type: type, size: size, offset: offset);

  Future<Album> getAlbum(String id) => _api.getAlbum(id);

  Future<List<Song>> getAlbumSongs(String id) => _api.getAlbumSongs(id);

  Future<List<Artist>> getArtists() => _api.getArtists();

  Future<Artist> getArtist(String id) => _api.getArtist(id);

  Future<List<Album>> getArtistAlbums(String id) => _api.getArtistAlbums(id);

  Future<List<Song>> getStarred() => _api.getStarred();

  Future<List<Playlist>> getPlaylists() => _api.getPlaylists();

  Future<List<Song>> getPlaylistSongs(String id) => _api.getPlaylistSongs(id);

  Future<List<Song>> searchSongs({String query = '', int count = 50, int offset = 0}) => _api.searchSongs(query: query, count: count, offset: offset);

  Future<List<Object>> search(String query, {int count = 50}) => _api.search(query, count: count);

  String getStreamUrl(String id) => _api.getStreamUrl(id);

  String getCoverArtUrl(String id, {int size = 300}) => _api.getCoverArtUrl(id, size: size);

  Future<Playlist> createPlaylist(String name, {List<String>? songIds}) => _api.createPlaylist(name, songIds: songIds);

  Future<void> updatePlaylist(String id, {String? name, List<String>? songIdsToAdd, List<String>? songIdsToRemove}) => _api.updatePlaylist(id, name: name, songIdsToAdd: songIdsToAdd, songIdsToRemove: songIdsToRemove);

  Future<void> deletePlaylist(String id) => _api.deletePlaylist(id);

  Future<void> scrobble(String id, {int? time}) => _api.scrobble(id, time: time);
}
