class Artist {
  final String id;
  final String name;
  final int? albumCount;
  final String? coverArt;
  final String? type;

  Artist({
    required this.id,
    required this.name,
    this.albumCount,
    this.coverArt,
    this.type,
  });

  factory Artist.fromJson(Map<String, String> map) {
    return Artist(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      albumCount: int.tryParse(map['albumCount'] ?? ''),
      coverArt: map['coverArt'],
      type: map['type'],
    );
  }

  Map<String, String> toJson() => {
    'id': id,
    'name': name,
    if (albumCount != null) 'albumCount': albumCount.toString(),
    if (coverArt != null) 'coverArt': ?coverArt,
    if (type != null) 'type': ?type,
  };
}
