class PodcastToggleCapsule {
  final String feedUrl;
  final String? imageUrl;
  final String? name;
  final String? artist;

  PodcastToggleCapsule({
    required this.feedUrl,
    this.imageUrl,
    this.name,
    this.artist,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PodcastToggleCapsule &&
        other.feedUrl == feedUrl &&
        other.imageUrl == imageUrl &&
        other.name == name &&
        other.artist == artist;
  }

  @override
  int get hashCode => Object.hash(feedUrl, imageUrl, name, artist);
}
