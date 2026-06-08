class FindEpisodesParam {
  final String feedUrl;
  final bool tryFromDbOnly;
  final String? genre;

  FindEpisodesParam({
    required this.feedUrl,
    required this.tryFromDbOnly,
    this.genre,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FindEpisodesParam &&
          runtimeType == other.runtimeType &&
          feedUrl == other.feedUrl &&
          genre == other.genre &&
          tryFromDbOnly == other.tryFromDbOnly;

  @override
  int get hashCode => Object.hash(feedUrl, tryFromDbOnly, genre);
}
