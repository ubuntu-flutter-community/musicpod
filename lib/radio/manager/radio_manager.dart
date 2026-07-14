import 'dart:async';

import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:radio_browser_api/src/models/tag.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../../common/data/audio.dart';
import '../../common/util/family.dart';
import '../../extensions/command_x.dart';
import '../data/radio_collection_view.dart';
import '../service/radio_service.dart';

@Injectable(cache: true)
class RadioManager {
  final RadioService _radioService;

  RadioManager({required RadioService radioService})
    : _radioService = radioService;

  late final Command<void, String?> connectCommand = Command.createAsyncNoParam(
    _radioService.connectToServer,
    initialValue: null,
  );

  Future<Audio?> getAudioByUUID(
    String uuid, {
    bool tryFromDbFirst = true,
  }) async {
    await connectCommand.runRestrictedAsync();
    return _radioService.getAudioByUUID(uuid, tryFromDbFirst: tryFromDbFirst);
  }

  late final Command<Audio, Audio?> findSimilarStationCommand =
      Command.createAsync((audio) async {
        await connectCommand.runRestrictedAsync();
        return _radioService.findSimilarStation(audio);
      }, initialValue: null);

  Future<List<Audio>?> search({
    String? country,
    String? name,
    String? state,
    String? tag,
    String? language,
    required int limit,
  }) async {
    await connectCommand.runRestrictedAsync();
    return _radioService.search(
      country: country,
      name: name,
      state: state,
      tag: tag,
      language: language,
      limit: limit,
    );
  }

  Future<Audio?> getStationByUrl(String url) async {
    await connectCommand.runRestrictedAsync();
    return _radioService.getAudioByUrl(url);
  }

  final radioCollectionView = SafeValueNotifier<RadioCollectionView>(
    RadioCollectionView.stations,
  );
  void setRadioCollectionView(RadioCollectionView value) {
    if (value == radioCollectionView.value) return;
    radioCollectionView.value = value;
  }

  late final Command<void, void> wipeCommand =
      Command.createAsyncNoParamNoResult(
        () => _radioService.wipeRadioLibrary(),
      );

  Future<Set<String>> getStarredStations() =>
      _radioService.getStarredStations();
  Future<bool> toggleStarStation(Audio station) =>
      _radioService.toggleStarredStation(station);

  Future<Set<String>> getFavRadioTags() => _radioService.getFavRadioTags();
  Future<void> toggleFavRadioTag(String name) =>
      _radioService.toggleFavRadioTag(name);

  Future<List<Tag>> loadTags() async {
    await connectCommand.runRestrictedAsync();
    return _radioService.loadTags();
  }
}

@injectable
class ClickStationManager {
  ClickStationManager._({
    @factoryParam required String uuid,
    required RadioService radioService,
  }) {
    command = Command.createAsyncNoParamNoResult(() async {
      await radioService.clickStation(uuid);
    });
    command.run();
  }

  @factoryMethod
  static ClickStationManager create({
    @factoryParam required String uuid,
    required RadioService radioService,
  }) => Family.of(
    uuid,
    () => ClickStationManager._(uuid: uuid, radioService: radioService),
    shouldDispose: (t) => t.command.listenerCount == 0,
    autoDisposeAfter: const Duration(hours: 5),
  );

  late final Command<void, void> command;
}
