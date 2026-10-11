import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/data/audio.dart';
import 'radio_manager.dart';

part 'station_manager.g.dart';

@riverpod
class StationManager extends _$StationManager {
  @override
  Future<Audio?> build(String uuid) async {
    await ref.watch(radioManagerProvider.future);
    return ref.watch(radioManagerProvider.notifier).getAudioByUUID(uuid);
  }
}

@riverpod
class StationNameManager extends _$StationNameManager {
  @override
  Future<String?> build(String uuid) async {
    await ref.watch(radioManagerProvider.future);
    return ref.watch(radioManagerProvider.notifier).getStationNameByUUID(uuid);
  }
}

@riverpod
class StationImageManager extends _$StationImageManager {
  @override
  Future<String?> build(String uuid) async {
    await ref.watch(radioManagerProvider.future);
    return ref.watch(radioManagerProvider.notifier).getStationImageByUUID(uuid);
  }
}
