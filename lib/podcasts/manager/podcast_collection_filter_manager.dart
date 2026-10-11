import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_collection_filter_manager.g.dart';

@Riverpod(keepAlive: true)
class PodcastUpdatesOnlyManager extends _$PodcastUpdatesOnlyManager {
  @override
  bool build() => false;

  void setUpdatesOnly(bool value) => state = value;
  void toggle() => state = !state;
}

@Riverpod(keepAlive: true)
class PodcastDownloadsOnlyManager extends _$PodcastDownloadsOnlyManager {
  @override
  bool build() => false;

  void setDownloadsOnly(bool value) => state = value;
  void toggle() => state = !state;
}
