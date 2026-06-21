import 'package:flutter_test/flutter_test.dart';
import 'package:loml_nas_music/data/models/models.dart';

void main() {
  group('Song', () {
    test('fromJson creates Song with all fields', () {
      final json = {
        'id': '123',
        'title': 'Test Song',
        'artist': 'Test Artist',
        'artistId': '456',
        'album': 'Test Album',
        'albumId': '789',
        'coverArt': 'cover-123',
        'duration': '240',
        'track': '3',
        'type': 'song',
      };
      final song = Song.fromJson(json);
      expect(song.id, '123');
      expect(song.title, 'Test Song');
      expect(song.artist, 'Test Artist');
      expect(song.artistId, '456');
      expect(song.album, 'Test Album');
      expect(song.albumId, '789');
      expect(song.coverArt, 'cover-123');
      expect(song.duration, 240);
      expect(song.track, 3);
      expect(song.type, 'song');
    });

    test('fromJson handles missing fields', () {
      final song = Song.fromJson({'id': '1', 'title': 'Song'});
      expect(song.id, '1');
      expect(song.title, 'Song');
      expect(song.artist, isNull);
      expect(song.duration, isNull);
      expect(song.track, isNull);
    });

    test('toJson returns all non-null fields', () {
      final song = Song(
        id: '1',
        title: 'Title',
        artist: 'Artist',
        duration: 180,
      );
      final json = song.toJson();
      expect(json['id'], '1');
      expect(json['title'], 'Title');
      expect(json['artist'], 'Artist');
      expect(json['duration'], '180');
      expect(json.containsKey('album'), isFalse);
    });
  });

  group('Album', () {
    test('fromJson creates Album', () {
      final json = {
        'id': '1',
        'name': 'Album Name',
        'artist': 'Artist',
        'coverArt': 'ca-1',
        'year': '2024',
        'songCount': '12',
        'duration': '3600',
      };
      final album = Album.fromJson(json);
      expect(album.id, '1');
      expect(album.name, 'Album Name');
      expect(album.artist, 'Artist');
      expect(album.year, 2024);
      expect(album.songCount, 12);
      expect(album.duration, 3600);
    });

    test('fromJson falls back to title for name', () {
      final album = Album.fromJson({'id': '1', 'title': 'Title Fallback'});
      expect(album.name, 'Title Fallback');
    });
  });

  group('Artist', () {
    test('fromJson creates Artist', () {
      final json = {'id': '1', 'name': 'Artist Name', 'albumCount': '5'};
      final artist = Artist.fromJson(json);
      expect(artist.id, '1');
      expect(artist.name, 'Artist Name');
      expect(artist.albumCount, 5);
    });
  });

  group('Playlist', () {
    test('fromJson creates Playlist', () {
      final json = {'id': '1', 'name': 'My Playlist', 'songCount': '20', 'public': 'true'};
      final pl = Playlist.fromJson(json);
      expect(pl.id, '1');
      expect(pl.name, 'My Playlist');
      expect(pl.songCount, 20);
      expect(pl.isPublic, isTrue);
    });
  });
}
