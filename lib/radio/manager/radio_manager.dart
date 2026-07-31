import 'dart:async';

import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:radio_browser_api/src/models/tag.dart';

import '../../common/data/audio.dart';
import '../../extensions/command_x.dart';
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

  Future<Audio?> getAudioByUUID(String uuid) async {
    final fromDb = await _radioService.getAudioByUUID(uuid, fromDBOnly: true);
    if (fromDb != null) {
      return fromDb;
    }
    await connectCommand.runRestrictedAsync();
    return _radioService.getAudioByUUID(uuid, fromDBOnly: false);
  }

  Future<Audio?> getStationByUrl(String url) async {
    await connectCommand.runRestrictedAsync();
    return _radioService.getAudioByUrl(url);
  }

  Future<List<Tag>> loadTags() async {
    await connectCommand.runRestrictedAsync();
    return _radioService.loadTags();
  }

  Future<String?> getStationNameByUUID(String uuid) =>
      _radioService.getStationNameByUUID(uuid);

  Future<String?> getStationImageByUUID(String uuid) =>
      _radioService.getStationImageByUUID(uuid);
}
