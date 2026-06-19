class PodcastShortInfo {
  const PodcastShortInfo({
    required this.name,
    required this.artist,
    this.imageUrl,
  });

  final String name;
  final String artist;
  final String? imageUrl;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PodcastShortInfo &&
        other.name == name &&
        other.artist == artist &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode {
    return name.hashCode ^ artist.hashCode ^ imageUrl.hashCode;
  }
}
