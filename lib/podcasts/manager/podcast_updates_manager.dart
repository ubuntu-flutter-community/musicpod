import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/data/audio.dart';
import '../../dependencies.dart';
import '../data/podcast_update_capsule.dart';
import '../service/podcast_service.dart';
import 'podcast_updated_feeds_manager.dart';

part 'podcast_updates_manager.g.dart';

class PodcastUpdatesState {
  final bool isRunning;
  final double progress;
  final Map<String, Set<Audio>> updates;
  final Object? error;
  final StackTrace? stackTrace;
  final PodcastUpdateCapsule? lastCapsule;

  const PodcastUpdatesState({
    this.isRunning = false,
    this.progress = 0.0,
    this.updates = const {},
    this.error,
    this.stackTrace,
    this.lastCapsule,
  });

  PodcastUpdatesState copyWith({
    bool? isRunning,
    double? progress,
    Map<String, Set<Audio>>? updates,
    Object? error,
    StackTrace? stackTrace,
    PodcastUpdateCapsule? lastCapsule,
  }) => PodcastUpdatesState(
    isRunning: isRunning ?? this.isRunning,
    progress: progress ?? this.progress,
    updates: updates ?? this.updates,
    error: error,
    stackTrace: stackTrace,
    lastCapsule: lastCapsule ?? this.lastCapsule,
  );
}

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
