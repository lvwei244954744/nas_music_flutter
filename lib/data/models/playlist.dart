class Playlist {
  final String id;
  final String name;
  final int? songCount;
  final String? owner;
  final bool? isPublic;
  final String? comment;
  final String? coverArt;

  Playlist({
    required this.id,
    required this.name,
    this.songCount,
    this.owner,
    this.isPublic,
    this.comment,
    this.coverArt,
  });

  factory Playlist.fromJson(Map<String, String> map) {
    return Playlist(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      songCount: int.tryParse(map['songCount'] ?? ''),
      owner: map['owner'],
      isPublic: map['public'] == 'true',
      comment: map['comment'],
      coverArt: map['coverArt'],
    );
  }

  Map<String, String> toJson() => {
    'id': id,
    'name': name,
    if (songCount != null) 'songCount': songCount.toString(),
    if (owner != null) 'owner': ?owner,
    if (isPublic != null) 'public': isPublic.toString(),
    if (comment != null) 'comment': ?comment,
    if (coverArt != null) 'coverArt': ?coverArt,
  };
}
