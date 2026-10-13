import '../../common/data/audio.dart';
import 'podcast_update_capsule.dart';

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
