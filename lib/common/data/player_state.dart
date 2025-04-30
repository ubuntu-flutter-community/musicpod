import 'dart:convert';

import 'package:collection/collection.dart';

import 'audio.dart';

class PlayerState {
  final String? position;
  final String? duration;
  final Audio? audio;
  final String? queueName;
  final List<Audio>? queue;
  final String? volume;
  final String? rate;

  const PlayerState({
    this.position,
    this.duration,
    this.audio,
    this.queueName,
    this.queue,
    this.volume,
    this.rate,
  });

  PlayerState copyWith({
    String? position,
    String? duration,
    Audio? audio,
    String? queueName,
    List<Audio>? queue,
    String? volume,
    String? rate,
  }) {
    return PlayerState(
      position: position ?? this.position,
      duration: duration ?? this.duration,
      audio: audio ?? this.audio,
      queueName: queueName ?? this.queueName,
      queue: queue ?? this.queue,
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
    if (queueName != null) {
      result.addAll({'queueName': queueName});
    }
    if (queue != null) {
      result.addAll({'queue': queue!.map((x) => x.toMap()).toList()});
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
      queueName: map['queueName'],
      queue: map['queue'] != null
          ? List<Audio>.from(map['queue']?.map((x) => Audio.fromMap(x)))
          : null,
      volume: map['volume'],
      rate: map['rate'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PlayerState.fromJson(String source) =>
      PlayerState.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PlayerState(position: $position, duration: $duration, audio: $audio, queueName: $queueName, queue: $queue, volume: $volume, rate: $rate,)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is PlayerState &&
        other.position == position &&
        other.duration == duration &&
        other.audio == audio &&
        other.queueName == queueName &&
        listEquals(other.queue, queue) &&
        other.volume == volume &&
        other.rate == rate;
  }

  @override
  int get hashCode {
    return position.hashCode ^
        duration.hashCode ^
        audio.hashCode ^
        queueName.hashCode ^
        queue.hashCode ^
        volume.hashCode ^
        rate.hashCode;
  }
}
