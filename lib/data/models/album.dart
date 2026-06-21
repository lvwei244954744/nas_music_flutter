class Album {
  final String id;
  final String name;
  final String? artist;
  final String? artistId;
  final String? coverArt;
  final int? year;
  final int? songCount;
  final int? duration;
  final String? type;

  Album({
    required this.id,
    required this.name,
    this.artist,
    this.artistId,
    this.coverArt,
    this.year,
    this.songCount,
    this.duration,
    this.type,
  });

  factory Album.fromJson(Map<String, String> map) {
    return Album(
      id: map['id'] ?? '',
      name: map['name'] ?? map['title'] ?? '',
      artist: map['artist'],
      artistId: map['artistId'],
      coverArt: map['coverArt'],
      year: int.tryParse(map['year'] ?? ''),
      songCount: int.tryParse(map['songCount'] ?? ''),
      duration: int.tryParse(map['duration'] ?? ''),
      type: map['type'],
    );
  }

  Map<String, String> toJson() => {
    'id': id,
    'name': name,
    if (artist != null) 'artist': ?artist,
    if (artistId != null) 'artistId': ?artistId,
    if (coverArt != null) 'coverArt': ?coverArt,
    if (year != null) 'year': year.toString(),
    if (songCount != null) 'songCount': songCount.toString(),
    if (duration != null) 'duration': duration.toString(),
    if (type != null) 'type': ?type,
  };
}
