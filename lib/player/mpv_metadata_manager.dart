import 'dart:async';

import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../common/data/audio_type.dart';
import '../expose/expose_service.dart';
import '../extensions/string_x.dart';
import '../radio/online_art_service.dart';
import 'data/mpv_meta_data.dart';
import 'observe_property.dart';
import 'player_service.dart';

@singleton
class MpvMetadataManager {
  MpvMetadataManager({
    required PlayerService playerService,
    required OnlineArtService onlineArtService,
    required ExposeService exposeService,
  }) : _playerService = playerService,
       _onlineArtService = onlineArtService,
       _exposeService = exposeService;

  final PlayerService _playerService;
  final OnlineArtService _onlineArtService;
  final ExposeService _exposeService;

  @PostConstruct(preResolve: true)
  Future<void> init() => observeProperty(
    property: 'metadata',
    player: _playerService.player,
    listener: _onMpvMetadata,
  );

  @disposeMethod
  Future<void> dispose() =>
      observeProperty(property: 'metadata', player: _playerService.player);

  final dataSafeMode = SafeValueNotifier<bool>(false);

  Future<void> _onMpvMetadata(data) async {
    if (!data.contains('icy-title')) {
      return;
    }
    final newData = MpvMetaData.fromJson(data);
    final parsedIcyTitle = newData.icyTitle.unEscapeHtml;
    if (parsedIcyTitle == null ||
        parsedIcyTitle == mpvMetaDataCommand.value?.icyTitle) {
      return;
    }

    mpvMetaDataCommand.run(newData.copyWith(icyTitle: parsedIcyTitle));
  }

  late final Command<MpvMetaData?, MpvMetaData?> mpvMetaDataCommand =
      Command.createAsync(
        (param) async => _digestMpvMetaData(param),
        initialValue: null,
      );

  Future<MpvMetaData?> _digestMpvMetaData(MpvMetaData? value) async {
    if (_isValidHistoryElement(value)) {
      _addMpvMetaDataHistoryElement(
        icyTitle: value!.icyTitle,
        mpvMetaData: value.copyWith(
          icyName: _playerService.audio?.title?.trim() ?? value.icyName,
        ),
      );

      await _processParsedIcyTitle(value.icyTitle);
      return value;
    }
    return null;
  }

  final _blockedIcyTitles = <String>{
    'Unknown',
    'Untitled',
    'No Title',
    'No Artist - No Title',
    ' - ',
    'Verbraucherinformation',
    'Werbung',
    'Advertisement',
  };

  bool _isValidHistoryElement(MpvMetaData? data) {
    final icyTitle = data?.icyTitle;
    if (icyTitle == null || icyTitle.isEmpty) {
      return false;
    }
    if (_blockedIcyTitles.any(
      (e) => e.toLowerCase().contains(icyTitle.toLowerCase()),
    )) {
      return false;
    }

    // This is often the title of the station
    final icyDescription = data?.icyDescription;
    if (icyDescription == null || icyDescription.isEmpty) {
      return true;
    }

    final sanitizedDescription = icyDescription.toLowerCase().replaceAll(
      RegExp(r'[^a-zA-Z0-9]'),
      '',
    );

    return !icyTitle.toLowerCase().contains(icyDescription) &&
        !icyTitle.toLowerCase().contains(sanitizedDescription);
  }

  Future<void> _processParsedIcyTitle(String parsedIcyTitle) async {
    final songInfo = parsedIcyTitle.splitByDash;
    String? albumArt;
    if (!dataSafeMode.value) {
      albumArt = await _onlineArtService.fetchAlbumArt(parsedIcyTitle);
    }

    final mergedAudio =
        (_playerService.audio ?? const Audio(audioType: AudioType.radio))
            .copyWith(
              imageUrl: albumArt,
              title: songInfo.songName,
              artist: songInfo.artist,
            );
    await _playerService.setMediaControlsMetaData(audio: mergedAudio);
    _playerService.setRemoteImageUrl(
      albumArt ??
          _playerService.audio?.imageUrl ??
          _playerService.audio?.albumArtUrl,
    );

    await _exposeService.exposeTitleOnline(
      title: songInfo.songName ?? '',
      artist: songInfo.artist ?? '',
      additionalInfo: _playerService.audio?.title ?? 'Internet Radio',
      imageUrl: albumArt,
    );
  }

  final mpvMetadataHistory = SafeValueNotifier<Map<String, MpvMetaData>>({});

  void _addMpvMetaDataHistoryElement({
    required String icyTitle,
    required MpvMetaData mpvMetaData,
  }) {
    if (!mpvMetadataHistory.value.containsKey(icyTitle)) {
      mpvMetadataHistory.value = {
        ...mpvMetadataHistory.value,
        icyTitle: mpvMetaData,
      };
    }
  }

  String getMpvMetaDataHistoryList({String? filter}) =>
      filteredMpvMetaDataHistory(
        filter: filter,
      ).map((e) => '${e.value.icyTitle}\n').toList().reversed.join();

  MpvMetaData? getMetadata(String? icyTitle) =>
      icyTitle == null ? null : mpvMetadataHistory.value[icyTitle];

  Iterable<MapEntry<String, MpvMetaData>> filteredMpvMetaDataHistory({
    required String? filter,
  }) => mpvMetadataHistory.value.entries.where(
    (e) => filter == null
        ? true
        : e.value.icyName.contains(filter) || filter.contains(e.value.icyName),
  );
}
