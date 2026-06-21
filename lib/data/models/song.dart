class Song {
  final String id;
  final String title;
  final String? artist;
  final String? artistId;
  final String? album;
  final String? albumId;
  final String? coverArt;
  final int? duration;
  final int? track;
  final String? type;

  Song({
    required this.id,
    required this.title,
    this.artist,
    this.artistId,
    this.album,
    this.albumId,
    this.coverArt,
    this.duration,
    this.track,
    this.type,
  });

  factory Song.fromJson(Map<String, String> map) {
    return Song(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      artist: map['artist'],
      artistId: map['artistId'],
      album: map['album'],
      albumId: map['albumId'],
      coverArt: map['coverArt'],
      duration: int.tryParse(map['duration'] ?? ''),
      track: int.tryParse(map['track'] ?? ''),
      type: map['type'],
    );
  }

  Map<String, String> toJson() => {
    'id': id,
    'title': title,
    if (artist != null) 'artist': ?artist,
    if (artistId != null) 'artistId': ?artistId,
    if (album != null) 'album': ?album,
    if (albumId != null) 'albumId': ?albumId,
    if (coverArt != null) 'coverArt': ?coverArt,
    if (duration != null) 'duration': duration.toString(),
    if (track != null) 'track': track.toString(),
    if (type != null) 'type': ?type,
  };
}
