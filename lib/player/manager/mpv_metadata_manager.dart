import 'dart:async';

import 'package:flutter/painting.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/logging.dart';
import '../../dependencies.dart';
import '../../expose/service/expose_service.dart';
import '../../extensions/string_x.dart';
import '../../radio/service/online_art_service.dart';
import '../../settings/data/shared_preferences_keys.dart';
import '../../settings/manager/settings_manager.dart';
import '../data/mpv_meta_data.dart';
import '../data/observe_property/observe_property.dart';
import '../service/player_service.dart';
import 'blocked_icy_titles_manager.dart';
import 'mpv_metadata_history_manager.dart';

part 'mpv_metadata_manager.g.dart';

@Riverpod(keepAlive: true)
class MpvMetadataManager extends _$MpvMetadataManager {
  MpvMetadataManager({
    PlayerService? playerService,
    ExposeService? exposeService,
    OnlineArtService? onlineArtService,
  })  : _playerServiceOverride = playerService,
        _exposeServiceOverride = exposeService,
        _onlineArtServiceOverride = onlineArtService;

  final PlayerService? _playerServiceOverride;
  final ExposeService? _exposeServiceOverride;
  final OnlineArtService? _onlineArtServiceOverride;

  PlayerService get _playerService =>
      _playerServiceOverride ?? di<PlayerService>();
  ExposeService get _exposeService =>
      _exposeServiceOverride ?? di<ExposeService>();
  OnlineArtService get _onlineArtService =>
      _onlineArtServiceOverride ?? di<OnlineArtService>();

  StreamSubscription<bool>? _playingSub;
  StreamSubscription<Audio?>? _audioSub;
  Timer? _debounceTimer;

  @override
  MpvMetaData? build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
      _playingSub?.cancel();
      _audioSub?.cancel();
      observeProperty(
        property: 'metadata',
        player: _playerService.player,
        listener: null,
      );
    });

    _playingSub = _playerService.player.stream.playing.listen((playing) {
      if (_playerService.audio?.audioType != AudioType.radio) {
        observeProperty(
          property: 'metadata',
          player: _playerService.player,
          listener: null,
        );
      } else {
        _toggleObserve(playing);
      }
    });

    _audioSub = _playerService.newAudioStream.listen((audio) {
      if (audio?.audioType != AudioType.radio) {
        observeProperty(
          property: 'metadata',
          player: _playerService.player,
          listener: null,
        );
      } else if (_playerService.player.state.playing) {
        _toggleObserve(true);
      }
    });

    return null;
  }

  void _toggleObserve(bool observe) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      observeProperty(
        property: 'metadata',
        player: _playerService.player,
        listener: observe ? onMpvMetadata : null,
      );
    });
  }

  Future<void> onMpvMetadata(String data) async {
    if (!data.contains('icy-title')) {
      return;
    }
    final newData = MpvMetaData.fromJson(data);
    final parsedIcyTitle = newData.icyTitle.unEscapeHtml;
    if (parsedIcyTitle == null || parsedIcyTitle == state?.icyTitle) {
      return;
    }

    await digestMpvMetaData(newData.copyWith(icyTitle: parsedIcyTitle));
  }

  Future<void> digestMpvMetaData(MpvMetaData value) async {
    if (isValidHistoryElement(value)) {
      final finalData = value.copyWith(
        icyName: _playerService.audio?.title?.trim() ?? value.icyName,
      );

      ref.read(mpvMetadataHistoryManagerProvider.notifier).add(
        icyTitle: value.icyTitle,
        mpvMetaData: finalData,
      );

      state = finalData;

      await processParsedIcyTitle(value.icyTitle);
    }
  }

  bool isValidHistoryElement(MpvMetaData data) {
    final icyTitle = data.icyTitle;
    if (icyTitle.isEmpty) {
      return false;
    }
    final blocked = ref.read(blockedIcyTitlesManagerProvider);
    if (blocked.any(
      (b) => icyTitle.toLowerCase().contains(b.toLowerCase()),
    )) {
      Logger.i('Blocked icy-title: $icyTitle', tag: '$MpvMetadataManager');
      Logger.i(
        'Blocked because it contains: ${blocked.firstWhere((b) => icyTitle.toLowerCase().contains(b.toLowerCase()))}',
        tag: '$MpvMetadataManager',
      );
      return false;
    }

    final icyDescription = data.icyDescription;
    if (icyDescription.isEmpty) {
      return true;
    }

    final sanitizedDescription = icyDescription.toLowerCase().replaceAll(
      RegExp(r'[^a-zA-Z0-9]'),
      '',
    );

    return !icyTitle.toLowerCase().contains(icyDescription.toLowerCase()) &&
        !icyTitle.toLowerCase().contains(sanitizedDescription);
  }

  Future<void> processParsedIcyTitle(String parsedIcyTitle) async {
    final songInfo = parsedIcyTitle.splitByDash;
    String? albumArt;

    final isDataSafeMode =
        ref.read(settingsBoolManagerProvider(SPKeys.dataSafeMode)) ?? false;
    if (!isDataSafeMode) {
      albumArt = await _onlineArtService.fetchAlbumArt(
        icyTitle: parsedIcyTitle,
      );
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
}
