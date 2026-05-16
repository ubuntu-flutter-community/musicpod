import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../common/data/audio_type.dart';
import '../common/logging.dart';
import '../expose/expose_service.dart';
import '../extensions/string_x.dart';
import '../radio/online_art_service.dart';
import '../settings/settings_service.dart';
import '../settings/shared_preferences_keys.dart';
import 'data/mpv_meta_data.dart';
import 'observe_property.dart';
import 'player_service.dart';

@singleton
class MpvMetadataManager {
  MpvMetadataManager({
    required PlayerService playerService,
    required OnlineArtService onlineArtService,
    required ExposeService exposeService,
    required SettingsService settingsService,
  }) : _playerService = playerService,
       _onlineArtService = onlineArtService,
       _exposeService = exposeService,
       _settingsService = settingsService {
    editBlockedIcyTitleCommand.run((
      title: '',
      addOrRemove: EditIcyTitleInHistory.init,
    ));
  }

  final PlayerService _playerService;
  final OnlineArtService _onlineArtService;
  final ExposeService _exposeService;
  final SettingsService _settingsService;

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

  final _defaultBlockedIcyTitles = <String>{
    '.westlotto.de',
    'lidl',
    'kaufland',
    'Verbraucherinformation',
    'Werbung',
    'Advertisement',
  };

  Set<String> get blockedIcyTitles {
    final set = _settingsService
        .getStringList(SPKeys.blockedIcyTitles)
        ?.toSet();
    return set ?? {};
  }

  late final Command<
    ({String title, EditIcyTitleInHistory addOrRemove}),
    Set<String>
  >
  editBlockedIcyTitleCommand = Command.createAsync((param) async {
    final title = param.title;
    final addOrRemove = param.addOrRemove;
    if (addOrRemove == EditIcyTitleInHistory.add) {
      await _addBlockedIcyTitles([title]);
      _removeMpvMetaDataHistoryElement(title);
    } else if (addOrRemove == EditIcyTitleInHistory.remove) {
      await _removeBlockedIcyTitle(title);
    } else if (addOrRemove == EditIcyTitleInHistory.init) {
      if (_settingsService.getStringList(SPKeys.blockedIcyTitles) == null ||
          _settingsService.getStringList(SPKeys.blockedIcyTitles)!.isEmpty) {
        await _settingsService.setValue(
          SPKeys.blockedIcyTitles,
          _defaultBlockedIcyTitles.toList(),
        );
      }
    }
    return blockedIcyTitles;
  }, initialValue: blockedIcyTitles);

  Future<void> _removeBlockedIcyTitle(String title) async {
    final current = _settingsService.getStringList(SPKeys.blockedIcyTitles);
    if (current == null || !current.contains(title)) {
      return;
    }
    final newList = current.where((t) => t != title).toList();
    await _settingsService.setValue(SPKeys.blockedIcyTitles, newList);
  }

  Future<void> _addBlockedIcyTitles(List<String> blockedTitles) async {
    final current =
        _settingsService.getStringList(SPKeys.blockedIcyTitles) ?? [];
    final newList = {...current, ...blockedTitles}.toList();
    await _settingsService.setValue(SPKeys.blockedIcyTitles, newList);
  }

  bool _isValidHistoryElement(MpvMetaData? data) {
    final icyTitle = data?.icyTitle;
    if (icyTitle == null || icyTitle.isEmpty) {
      return false;
    }
    if (blockedIcyTitles.any(
      (b) => icyTitle.toLowerCase().contains(b.toLowerCase()),
    )) {
      printMessageInDebugMode('Blocked icy-title: $icyTitle');
      printMessageInDebugMode(
        'Blocked because it contains: ${blockedIcyTitles.firstWhere((b) => icyTitle.toLowerCase().contains(b.toLowerCase()))}',
      );
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
    final url2 =
        albumArt ??
        _playerService.audio?.imageUrl ??
        _playerService.audio?.albumArtUrl;
    _playerService.setRemoteImageUrl(url2);

    if (url2 != null) {
      await _playerService.setRemoteColorFromImageProvider(NetworkImage(url2));
    }

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

  void _removeMpvMetaDataHistoryElement(String icyTitle) {
    final newMap = {...mpvMetadataHistory.value}..remove(icyTitle);
    mpvMetadataHistory.value = newMap;
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

enum EditIcyTitleInHistory { add, remove, init }
