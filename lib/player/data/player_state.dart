import 'dart:convert';

import '../../common/data/audio.dart';

class PlayerState {
  final String? position;
  final String? duration;
  final Audio? audio;
  final String? volume;
  final String? rate;

  const PlayerState({
    this.position,
    this.duration,
    this.audio,
    this.volume,
    this.rate,
  });

  PlayerState copyWith({
    String? position,
    String? duration,
    Audio? audio,
    String? volume,
    String? rate,
  }) {
    return PlayerState(
      position: position ?? this.position,
      duration: duration ?? this.duration,
      audio: audio ?? this.audio,
      volume: volume ?? this.volume,
      rate: rate ?? this.rate,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    if (position != null) {
      result.addAll({'position': position});
    }
    if (duration != null) {
      result.addAll({'duration': duration});
    }
    if (audio != null) {
      result.addAll({'audio': audio!.toMap()});
    }
    if (volume != null) {
      result.addAll({'volume': volume});
    }
    if (rate != null) {
      result.addAll({'rate': rate});
    }

    return result;
  }

  factory PlayerState.fromMap(Map<String, dynamic> map) {
    return PlayerState(
      position: map['position'],
      duration: map['duration'],
      audio: map['audio'] != null ? Audio.fromMap(map['audio']) : null,
      volume: map['volume'],
      rate: map['rate'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PlayerState.fromJson(String source) =>
      PlayerState.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PlayerState(position: $position, duration: $duration, audio: $audio, volume: $volume, rate: $rate,)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PlayerState &&
        other.position == position &&
        other.duration == duration &&
        other.audio == audio &&
        other.volume == volume &&
        other.rate == rate;
  }

  @override
  int get hashCode {
    return position.hashCode ^
        duration.hashCode ^
        audio.hashCode ^
        volume.hashCode ^
        rate.hashCode;
  }
}
