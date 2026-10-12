import 'dart:async';

import 'package:radio_browser_api/src/models/tag.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/data/audio.dart';
import '../../dependencies.dart';
import '../service/radio_service.dart';

part 'radio_manager.g.dart';

@Riverpod(keepAlive: true)
class RadioManager extends _$RadioManager {
  late final RadioService _radioService = di<RadioService>();

  @override
  Future<String?> build() => _radioService.connectToServer();

  Future<void> reconnect() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _radioService.connectToServer());
  }

  Future<List<Audio>?> search({
    String? country,
    String? name,
    String? state,
    String? tag,
    String? language,
    required int limit,
  }) async {
    await future;
    return _radioService.search(
      country: country,
      name: name,
      state: state,
      tag: tag,
      language: language,
      limit: limit,
    );
  }

  Future<Audio?> getAudioByUUID(String uuid) async {
    final fromDb = await _radioService.getAudioByUUID(uuid, fromDBOnly: true);
    if (fromDb != null) {
      return fromDb;
    }
    await future;
    return _radioService.getAudioByUUID(uuid, fromDBOnly: false);
  }

  Future<Audio?> getStationByUrl(String url) async {
    await future;
    return _radioService.getAudioByUrl(url);
  }

  Future<List<Tag>> loadTags() async {
    await future;
    return _radioService.loadTags();
  }

  Future<Audio?> findSimilarStation(Audio audio) async {
    await future;
    return _radioService.findSimilarStation(audio);
  }

  Future<String?> getStationNameByUUID(String uuid) =>
      _radioService.getStationNameByUUID(uuid);

  Future<String?> getStationImageByUUID(String uuid) =>
      _radioService.getStationImageByUUID(uuid);
}

@riverpod
class SimilarStationManager extends _$SimilarStationManager {
  @override
  FutureOr<Audio?> build() => null;

  Future<Audio?> findSimilarStation(Audio audio) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.watch(radioManagerProvider.future);
      return ref.watch(radioManagerProvider.notifier).findSimilarStation(audio);
    });
    return state.value;
  }
}
