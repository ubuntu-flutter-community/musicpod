import 'package:collection/collection.dart';

class AudioProgressState {
  const AudioProgressState({
    this.lastPositions = const {},
    this.isToggling = false,
    this.hasMissingDuration = false,
  });

  final Map<String, Duration> lastPositions;
  final bool isToggling;
  final bool hasMissingDuration;

  AudioProgressState copyWith({
    Map<String, Duration>? lastPositions,
    bool? isToggling,
    bool? hasMissingDuration,
  }) {
    return AudioProgressState(
      lastPositions: lastPositions ?? this.lastPositions,
      isToggling: isToggling ?? this.isToggling,
      hasMissingDuration: hasMissingDuration ?? this.hasMissingDuration,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioProgressState &&
          const MapEquality<String, Duration>().equals(
            lastPositions,
            other.lastPositions,
          ) &&
          isToggling == other.isToggling &&
          hasMissingDuration == other.hasMissingDuration;

  @override
  int get hashCode => Object.hash(
    const MapEquality<String, Duration>().hash(lastPositions),
    isToggling,
    hasMissingDuration,
  );
}
