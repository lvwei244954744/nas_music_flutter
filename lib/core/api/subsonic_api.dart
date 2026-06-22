import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../../data/models/models.dart';

class SubsonicApi {
  String? _baseUrl;
  String? _username;
  String? _password;

  static const _basePath = '/rest';
  static const _apiVersion = '1.16.1';
  static const _clientName = 'loml_nas_music';

  bool get isConnected => _baseUrl != null && _username != null;

  String? get baseUrl => _baseUrl;
  String? get username => _username;
  String? get password => _password;

  void setCredentials(String baseUrl, String username, String password) {
    _baseUrl = baseUrl.replaceAll(RegExp(r'\/+$'), '');
    _username = username;
    _password = password;
  }

  Future<bool> login(String baseUrl, String username, String password) async {
    try {
      setCredentials(baseUrl, username, password);
      final ok = await ping();
      if (!ok) {
        logout();
      }
      return ok;
    } catch (_) {
      logout();
      return false;
    }
  }

  void logout() {
    _baseUrl = null;
    _username = null;
    _password = null;
  }

  Map<String, String> get credentials => {
    'u': _username ?? '',
    'p': _password ?? '',
    'v': _apiVersion,
    'c': _clientName,
    'f': 'xml',
  };

  Uri _buildUri(String method, [Map<String, String>? extraParams]) {
    final params = Map<String, String>.from(credentials);
    if (extraParams != null) params.addAll(extraParams);
    return Uri.parse('$_baseUrl$_basePath/$method.view').replace(queryParameters: params);
  }

  Future<XmlDocument> _get(String method, [Map<String, String>? params]) async {
    final uri = _buildUri(method, params);
    final response = await http.get(uri);
    final body = utf8.decode(response.bodyBytes);
    return XmlDocument.parse(body);
  }

  bool _isSuccess(XmlDocument doc) {
    return doc.findAllElements('subsonic-response').first.getAttribute('status') == 'ok';
  }

  String? _errorMessage(XmlDocument doc) {
    return doc.findAllElements('error').firstOrNull?.getAttribute('message');
  }

  static Map<String, String> _parseElement(XmlElement el) {
    return {
      for (final attr in el.attributes)
        attr.localName: attr.value,
    };
  }

  Future<bool> ping() async {
    try {
      final doc = await _get('ping');
      return _isSuccess(doc);
    } catch (_) {
      return false;
    }
  }

  Future<List<Artist>> getArtists() async {
    final doc = await _get('getArtists');
    if (!_isSuccess(doc)) throw Exception(_errorMessage(doc));
    return doc.findAllElements('artist').map((e) => Artist.fromJson(_parseElement(e))).toList();
  }

  Future<List<Album>> getAlbumList({
    String type = 'newest',
    int size = 50,
    int offset = 0,
  }) async {
    final doc = await _get('getAlbumList2', {
      'type': type,
      'size': size.toString(),
      'offset': offset.toString(),
    });
    if (!_isSuccess(doc)) throw Exception(_errorMessage(doc));
    return doc.findAllElements('album').map((e) => Album.fromJson(_parseElement(e))).toList();
  }

  Future<List<Playlist>> getPlaylists() async {
    final doc = await _get('getPlaylists');
    if (!_isSuccess(doc)) throw Exception(_errorMessage(doc));
    return doc.findAllElements('playlist').map((e) => Playlist.fromJson(_parseElement(e))).toList();
  }

  Future<Album> getAlbum(String id) async {
    final doc = await _get('getAlbum', {'id': id});
    if (!_isSuccess(doc)) throw Exception(_errorMessage(doc));
    return Album.fromJson(_parseElement(doc.findAllElements('album').first));
  }

  Future<List<Song>> getAlbumSongs(String id) async {
    final doc = await _get('getAlbum', {'id': id});
    if (!_isSuccess(doc)) throw Exception(_errorMessage(doc));
    return doc.findAllElements('song').map((e) => Song.fromJson(_parseElement(e))).toList();
  }

  Future<Artist> getArtist(String id) async {
    final doc = await _get('getArtist', {'id': id});
    if (!_isSuccess(doc)) throw Exception(_errorMessage(doc));
    return Artist.fromJson(_parseElement(doc.findAllElements('artist').first));
  }

  Future<List<Album>> getArtistAlbums(String id) async {
    final doc = await _get('getArtist', {'id': id});
    if (!_isSuccess(doc)) throw Exception(_errorMessage(doc));
    return doc.findAllElements('album').map((e) => Album.fromJson(_parseElement(e))).toList();
  }

  Future<List<Song>> getPlaylistSongs(String id) async {
    final doc = await _get('getPlaylist', {'id': id});
    if (!_isSuccess(doc)) throw Exception(_errorMessage(doc));
    return doc.findAllElements('entry').map((e) => Song.fromJson(_parseElement(e))).toList();
  }

  Future<List<Song>> searchSongs({
    String query = '',
    int count = 50,
    int offset = 0,
  }) async {
    final doc = await _get('search3', {
      'query': query,
      'songCount': count.toString(),
      'songOffset': offset.toString(),
      'artistCount': '0',
      'albumCount': '0',
    });
    if (!_isSuccess(doc)) throw Exception(_errorMessage(doc));
    return doc.findAllElements('song').map((e) => Song.fromJson(_parseElement(e))).toList();
  }

  Future<List<Object>> search(String query, {int count = 50}) async {
    final doc = await _get('search3', {
      'query': query,
      'albumCount': count.toString(),
      'artistCount': count.toString(),
      'songCount': count.toString(),
    });
    if (!_isSuccess(doc)) throw Exception(_errorMessage(doc));

    final results = <Object>[];
    for (final a in doc.findAllElements('artist')) {
      results.add(Artist.fromJson(_parseElement(a)));
    }
    for (final a in doc.findAllElements('album')) {
      results.add(Album.fromJson(_parseElement(a)));
    }
    for (final s in doc.findAllElements('song')) {
      results.add(Song.fromJson(_parseElement(s)));
    }
    return results;
  }

  String getStreamUrl(String id) {
    final params = Map<String, String>.from(credentials)..remove('f');
    final uri = Uri.parse('$_baseUrl$_basePath/stream.view').replace(queryParameters: {
      ...params,
      'id': id,
    });
    return uri.toString();
  }
  String getCoverArtUrl(String id, {int size = 300}) =>
      _buildUri('getCoverArt', {'id': id, 'size': size.toString()}).toString();

  Future<Playlist> createPlaylist(String name, {List<String>? songIds}) async {
    final params = <String, String>{'name': name};
    if (songIds != null && songIds.isNotEmpty) {
      for (int i = 0; i < songIds.length; i++) {
        params['songId[$i]'] = songIds[i];
      }
    }
    final doc = await _get('createPlaylist', params);
    if (!_isSuccess(doc)) throw Exception(_errorMessage(doc));
    return Playlist.fromJson(_parseElement(doc.findAllElements('playlist').first));
  }

  Future<void> updatePlaylist(String id, {String? name, List<String>? songIdsToAdd, List<String>? songIdsToRemove}) async {
    final params = <String, String>{};
    if (name != null) params['name'] = name;
    if (songIdsToAdd != null) {
      for (int i = 0; i < songIdsToAdd.length; i++) {
        params['songIdToAdd[$i]'] = songIdsToAdd[i];
      }
    }
    if (songIdsToRemove != null) {
      for (int i = 0; i < songIdsToRemove.length; i++) {
        params['songIndexToRemove[$i]'] = songIdsToRemove[i];
      }
    }
    final doc = await _get('updatePlaylist', params);
    if (!_isSuccess(doc)) throw Exception(_errorMessage(doc));
  }

  Future<void> deletePlaylist(String id) async {
    final doc = await _get('deletePlaylist', {'id': id});
    if (!_isSuccess(doc)) throw Exception(_errorMessage(doc));
  }

  Future<void> scrobble(String id, {int? time}) async {
    final params = <String, String>{'id': id, 'submission': 'true'};
    if (time != null) params['time'] = time.toString();
    await _get('scrobble', params);
  }
}
