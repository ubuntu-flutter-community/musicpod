import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/data/audio.dart';
import '../../dependencies.dart';
import '../data/podcast_update_capsule.dart';
import '../data/podcast_updates_state.dart';
import '../service/podcast_service.dart';
import 'podcast_updated_feeds_manager.dart';

part 'podcast_updates_manager.g.dart';

@Riverpod(keepAlive: true)
class PodcastUpdatesManager extends _$PodcastUpdatesManager {
  late final PodcastService _podcastService = di<PodcastService>();

  @override
  PodcastUpdatesState build() => const PodcastUpdatesState();

  Future<void> run(PodcastUpdateCapsule capsule) async {
    state = state.copyWith(
      isRunning: true,
      progress: 0.0,
      error: null,
      lastCapsule: capsule,
    );

    try {
      if (capsule.type == PodcastUpdateType.remove) {
        await _podcastService.removePodcastUpdates(
          feedUrls: capsule.feedUrls,
          updateProgress: (p) => state = state.copyWith(progress: p),
        );

        ref.invalidate(podcastUpdatedFeedsManagerProvider);

        final updatedFeeds = await _podcastService.getPodcastUpdates();
        final result = <String, Set<Audio>>{
          for (final feedUrl in updatedFeeds) feedUrl: {},
        };

        state = state.copyWith(
          isRunning: false,
          progress: 1.0,
          updates: result,
        );
        return;
      }

      final updates = await _podcastService.checkForUpdates(
        feedUrls: capsule.feedUrls,
        updateProgress: (p) => state = state.copyWith(progress: p),
      );

      ref.invalidate(podcastUpdatedFeedsManagerProvider);

      state = state.copyWith(isRunning: false, progress: 1.0, updates: updates);
    } catch (e, st) {
      state = state.copyWith(isRunning: false, error: e, stackTrace: st);
    }
  }

  void clear() {
    state = const PodcastUpdatesState();
  }
}
