import 'package:podcast_search/podcast_search.dart';

class FindEpisodesParam {
  final String feedUrl;
  final Item? item;
  final bool tryFromDbOnly;

  FindEpisodesParam({
    required this.feedUrl,
    required this.item,
    required this.tryFromDbOnly,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FindEpisodesParam &&
          runtimeType == other.runtimeType &&
          feedUrl == other.feedUrl &&
          item == other.item &&
          tryFromDbOnly == other.tryFromDbOnly;

  @override
  int get hashCode => Object.hash(feedUrl, item, tryFromDbOnly);
}
