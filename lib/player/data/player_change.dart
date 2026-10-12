import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import '../../common/data/audio.dart';
import 'queue.dart';

sealed class PlayerChange {
  const PlayerChange();
}

class AudioChange extends PlayerChange {
  final Audio? audio;
  const AudioChange(this.audio);
}

class BufferChange extends PlayerChange {
  final Duration? buffer;
  const BufferChange(this.buffer);
}

class ColorChange extends PlayerChange {
  final Color? color;
  const ColorChange(this.color);
}

class DurationChange extends PlayerChange {
  final Duration? duration;
  const DurationChange(this.duration);
}

class IsPlayingChange extends PlayerChange {
  final bool isPlaying;
  const IsPlayingChange(this.isPlaying);
}

class IsVideoChange extends PlayerChange {
  final bool isVideo;
  const IsVideoChange(this.isVideo);
}

class LastPositionsChange extends PlayerChange {
  final Map<String, Duration> lastPositions;
  const LastPositionsChange(this.lastPositions);
}

class NextAudioChange extends PlayerChange {
  final Audio? nextAudio;
  const NextAudioChange(this.nextAudio);
}

class PlaylistModeChange extends PlayerChange {
  final PlaylistMode playlistMode;
  const PlaylistModeChange(this.playlistMode);
}

class PositionChange extends PlayerChange {
  final Duration? position;
  const PositionChange(this.position);
}

class QueueChange extends PlayerChange {
  final Queue queue;
  const QueueChange(this.queue);
}

class RateChange extends PlayerChange {
  final double rate;
  const RateChange(this.rate);
}

class ShuffleChange extends PlayerChange {
  final bool shuffle;
  const ShuffleChange(this.shuffle);
}

class VolumeChange extends PlayerChange {
  final double? volume;
  const VolumeChange(this.volume);
}

class TimerChange extends PlayerChange {
  final bool isTimerActive;
  const TimerChange(this.isTimerActive);
}

class ResetChange extends PlayerChange {
  const ResetChange();
}

extension PlayerChangeStreamX on Stream<PlayerChange> {
  Stream<T> whereType<T extends PlayerChange>() =>
      where((e) => e is T).cast<T>();
}
