import '../../common/data/audio.dart';
import 'play_anywhere_param.dart';

class PlayAnywhereResult {
  final List<Audio> audios;
  final PlayAnywhereParam param;

  const PlayAnywhereResult({required this.audios, required this.param});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayAnywhereResult &&
          runtimeType == other.runtimeType &&
          audios == other.audios &&
          param == other.param;

  @override
  int get hashCode => audios.hashCode ^ param.hashCode;
}
