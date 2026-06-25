import '../../common/data/audio.dart';

class Queue {
  const Queue({required this.name, required this.audios});
  final String name;
  final List<Audio> audios;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Queue &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          audios == other.audios;

  @override
  int get hashCode => name.hashCode ^ audios.hashCode;

  Queue copyWith({String? name, List<Audio>? audios}) =>
      Queue(name: name ?? this.name, audios: audios ?? this.audios);

  const Queue.empty() : this(name: '', audios: const []);
}
