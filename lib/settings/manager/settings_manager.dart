import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../../common/util/family.dart';
import '../../common/view/icons.dart';
import '../../extensions/platform_x.dart';
import '../../local_audio/service/local_audio_service.dart';
import '../../lyrics/data/online_lyrics_source.dart';
import '../../player/service/player_service.dart';
import '../../podcasts/service/podcast_service.dart';
import '../../radio/service/radio_service.dart';
import '../data/shared_preferences_keys.dart';
import '../service/settings_service.dart';

// TODO: remove this in favor of SettingsTypeManager, which is a more generic and reusable solution for managing settings of different types. This class is kept for backward compatibility and will be removed in future versions.
@lazySingleton
class SettingsManager extends SafeChangeNotifier {
  SettingsManager({
    required SettingsService service,
    required PodcastService podcastService,
    required LocalAudioService localAudioService,
    required RadioService radioService,
    required PlayerService playerService,
  }) : _service = service {
    _propertiesChangedSub ??= _service.propertiesChanged.listen(
      (_) => notifyListeners(),
    );
  }

  final SettingsService _service;

  int _scrollIndex = 0;
  int get scrollIndex => _scrollIndex;
  set scrollIndex(int value) {
    _scrollIndex = value;
    notifyListeners();
  }

  StreamSubscription<bool>? _propertiesChangedSub;

  String? get directory => _service.getString(SPKeys.directory);
  Future<void> setDirectory(String value) async =>
      _service.setValue(SPKeys.directory, value);

  int get localAudioindex => _service.getInt(SPKeys.localAudioIndex) ?? 0;
  Future<void> setLocalAudioindex(int value) async =>
      _service.setValue(SPKeys.localAudioIndex, value);

  bool get neverShowFailedImports =>
      _service.getBool(SPKeys.neverShowImportFails) ?? false;
  void setNeverShowFailedImports(bool value) =>
      _service.setValue(SPKeys.neverShowImportFails, value);

  bool get groupAlbumsOnlyByAlbumName =>
      _service.getBool(SPKeys.groupAlbumsOnlyByAlbumName) ?? false;
  void setGroupAlbumsOnlyByAlbumName(bool value) =>
      _service.setValue(SPKeys.groupAlbumsOnlyByAlbumName, value);

  bool get enableLastFmScrobbling =>
      _service.getBool(SPKeys.enableLastFm) ?? false;
  String? get lastFmApiKey => _service.getString(SPKeys.lastFmApiKey);
  String? get lastFmSecret => _service.getString(SPKeys.lastFmSecret);
  String? get lastFmSessionKey => _service.getString(SPKeys.lastFmSessionKey);
  String? get lastFmUsername => _service.getString(SPKeys.lastFmUsername);
  void setEnableLastFmScrobbling(bool value) =>
      _service.setValue(SPKeys.enableLastFm, value);
  void setLastFmApiKey(String value) =>
      _service.setValue(SPKeys.lastFmApiKey, value);
  void setLastFmSecret(String value) =>
      _service.setValue(SPKeys.lastFmSecret, value);
  void setLastFmSessionKey(String value) =>
      _service.setValue(SPKeys.lastFmSessionKey, value);
  void setLastFmUsername(String value) =>
      _service.setValue(SPKeys.lastFmUsername, value);

  bool get enableListenBrainzScrobbling =>
      _service.getBool(SPKeys.enableListenBrainz) ?? false;
  String? get listenBrainzApiKey =>
      _service.getString(SPKeys.listenBrainzApiKey);
  void setEnableListenBrainzScrobbling(bool value) =>
      _service.setValue(SPKeys.enableListenBrainz, value);
  void setListenBrainzApiKey(String value) =>
      _service.setValue(SPKeys.listenBrainzApiKey, value);

  bool get useMoreAnimations =>
      _service.getBool(SPKeys.useMoreAnimations) ?? false;
  void setUseMoreAnimations(bool value) =>
      _service.setValue(SPKeys.useMoreAnimations, value);

  bool get saveWindowSize => _service.getBool(SPKeys.saveWindowSize) ?? false;
  void setSaveWindowSize(bool value) =>
      _service.setValue(SPKeys.saveWindowSize, value);

  bool get notifyDataSafeMode =>
      _service.getBool(SPKeys.notifyDataSafeMode) ?? false;
  void setNotifyDataSafeMode(bool value) =>
      _service.setValue(SPKeys.notifyDataSafeMode, value);

  bool get usePodcastIndex => _service.getBool(SPKeys.usePodcastIndex) ?? false;
  Future<void> setUsePodcastIndex(bool value) async =>
      _service.setValue(SPKeys.usePodcastIndex, value);

  int get themeIndex => _service.getInt(SPKeys.themeIndex) ?? 0;
  void setThemeIndex(int value) => _service.setValue(SPKeys.themeIndex, value);

  bool get useYaruTheme => _service.getBool(SPKeys.useYaruTheme) ?? isLinux;
  void setUseYaruTheme(bool value) =>
      _service.setValue(SPKeys.useYaruTheme, value);

  int? get customThemeColor => _service.getInt(SPKeys.customThemeColor);
  void setCustomThemeColor(int? value) =>
      _service.setValue(SPKeys.customThemeColor, value);
  bool get useCustomThemeColor =>
      _service.getBool(SPKeys.useCustomThemeColor) ?? false;
  void setUseCustomThemeColor(bool value) =>
      _service.setValue(SPKeys.useCustomThemeColor, value);

  bool get usePlayerColor => _service.getBool(SPKeys.usePlayerColor) ?? true;
  Future<void> setUsePlayerColor(bool value) =>
      _service.setValue(SPKeys.usePlayerColor, value);

  int get iconSetIndex =>
      _service.getInt(SPKeys.iconSetIndex) ?? IconSet.platformDefaultIndex;
  void setIconSetIndex(int value) =>
      _service.setValue(SPKeys.iconSetIndex, value);

  int get playerExplorerTabIndex =>
      _service.getInt(SPKeys.playerExplorerTabIndex) ?? 0;
  void setPlayerExplorerTabIndex(int value) =>
      _service.setValue(SPKeys.playerExplorerTabIndex, value);

  String? get podcastIndexApiKey =>
      _service.getString(SPKeys.podcastIndexApiKey);
  Future<void> setPodcastIndexApiKey(String value) =>
      _service.setValue(SPKeys.podcastIndexApiKey, value);
  String? get podcastIndexApiSecret =>
      _service.getString(SPKeys.podcastIndexApiSecret);
  Future<void> setPodcastIndexApiSecret(String value) =>
      _service.setValue(SPKeys.podcastIndexApiSecret, value);

  bool get showPositionDuration =>
      _service.getBool(SPKeys.showPositionDuration) ?? true;
  Future<void> setShowPositionDuration(bool value) async =>
      _service.setValue(SPKeys.showPositionDuration, value);

  bool get hideCompletedEpisodes =>
      _service.getBool(SPKeys.hideCompletedEpisodes) ?? false;
  Future<void> setHideCompletedEpisodes(bool value) =>
      _service.setValue(SPKeys.hideCompletedEpisodes, value);
  Future<void> toggleHideCompletedEpisodes() =>
      setHideCompletedEpisodes(!hideCompletedEpisodes);

  bool get showPlayerLyrics =>
      _service.getBool(SPKeys.showPlayerLyrics) ?? false;
  Future<void> setShowPlayerLyrics(bool value) =>
      _service.setValue(SPKeys.showPlayerLyrics, value);

  bool get tryToFetchLyricsOnline =>
      _service.getBool(SPKeys.tryToFetchLyricsOnline) ?? false;
  Future<void> setTryToFetchLyricsOnline(bool value) =>
      _service.setValue(SPKeys.tryToFetchLyricsOnline, value);

  String get selectedSearchAudioType =>
      _service.getString(SPKeys.selectedSearchAudioType) ?? 'podcast';
  Future<void> setSelectedSearchAudioType(String value) =>
      _service.setValue(SPKeys.selectedSearchAudioType, value);

  String? get lastCountryCode => _service.getString(SPKeys.lastCountryCode);
  void setLastCountryCode(String value) {
    _service.setValue(SPKeys.lastCountryCode, value);
  }

  String? get lastLanguageCode => _service.getString(SPKeys.lastLanguageCode);
  void setLastLanguageCode(String value) {
    _service.setValue(SPKeys.lastLanguageCode, value);
  }

  Set<String> get favoriteLanguageCode =>
      _service.getStringList(SPKeys.favLanguageCodes)?.toSet() ?? {};
  int get favoriteLanguageCodeLength => favoriteLanguageCode.length;
  bool isFavCountryCode(String value) => favoriteCountryCode.contains(value);
  void addFavoriteLanguageCode(String value) {
    final current = favoriteLanguageCode;
    if (!current.contains(value)) {
      current.add(value);
      _service.setValue(SPKeys.favLanguageCodes, current.toList());
    }
  }

  void removeFavoriteLanguageCode(String value) {
    final current = favoriteLanguageCode;
    if (current.contains(value)) {
      current.remove(value);
      _service.setValue(SPKeys.favLanguageCodes, current.toList());
    }
  }

  Set<String> get favoriteCountryCode =>
      _service.getStringList(SPKeys.favCountryCodes)?.toSet() ?? {};
  int get favoriteCountryCodeLength => favoriteCountryCode.length;
  bool isFavLanguageCode(String value) => favoriteLanguageCode.contains(value);
  void addFavoriteCountryCode(String value) {
    final current = favoriteCountryCode;
    if (!current.contains(value)) {
      current.add(value);
      _service.setValue(SPKeys.favCountryCodes, current.toList());
    }
  }

  void removeFavoriteCountryCode(String value) {
    final current = favoriteCountryCode;
    if (current.contains(value)) {
      current.remove(value);
      _service.setValue(SPKeys.favCountryCodes, current.toList());
    }
  }

  late final Command<void, void> wipeAllSettingsCommand =
      Command.createAsyncNoParamNoResult(_service.wipeAllSettings);

  OnlineLyricsSource get onlineLyricsSource {
    final value = _service.getString(SPKeys.onlineLyricsSource);
    if (value == null) return OnlineLyricsSource.lrcLib;
    return OnlineLyricsSource.values.firstWhereOrNull((e) => e.name == value) ??
        OnlineLyricsSource.lrcLib;
  }

  void setOnlineLyricsSource(OnlineLyricsSource? value) {
    _service.setValue(SPKeys.onlineLyricsSource, value?.name);
  }

  @override
  Future<void> dispose() async {
    await _propertiesChangedSub?.cancel();
    super.dispose();
  }
}

@injectable
class SettingsTypeManager {
  SettingsTypeManager._({
    required String key,
    required dynamic type,
    required SettingsService settingsService,
  }) {
    command = Command.createAsync((value) async {
      if (value != null) {
        final success = await settingsService.setValue(key, value);
        if (!success) {
          throw SettingsException('Failed to set value for key: $key');
        }
      }

      return switch (type) {
        bool => settingsService.getBool(key),
        int => settingsService.getInt(key),
        String => settingsService.getString(key),
        List<String> _ => settingsService.getStringList(key),
        double => settingsService.getDouble(key),
        _ => throw SettingsException('Unsupported type: $type'),
      };
    }, initialValue: null);

    command.run();
  }

  late final Command<dynamic, dynamic> command;

  @factoryMethod
  static SettingsTypeManager create({
    @factoryParam required String key,
    @factoryParam required dynamic type,
    required SettingsService settingsService,
  }) => Family.of(
    key,
    () => SettingsTypeManager._(
      key: key,
      type: type,
      settingsService: settingsService,
    ),
    shouldDispose: (t) => t.command.listenerCount == 0,
    onDispose: (t) => t.command.dispose(),
  );
}

class SettingsException implements Exception {
  SettingsException(this.message);

  final String message;

  @override
  String toString() => 'SettingsException: $message';
}

enum SettingsType { bool, int, String, listString, double }
