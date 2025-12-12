import 'dart:async';
import 'dart:io';

import 'package:github/github.dart';
import 'package:path/path.dart' as p;
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../../external_path/external_path_service.dart';
import 'shared_preferences_keys.dart';
import 'settings_service.dart';

class SettingsModel extends SafeChangeNotifier {
  SettingsModel({
    required SettingsService service,
    required ExternalPathService externalPathService,
    required GitHub gitHub,
  }) : _service = service,
       _externalPathService = externalPathService {
    _propertiesChangedSub ??= _service.propertiesChanged.listen(
      (_) => notifyListeners(),
    );
  }

  final SettingsService _service;
  final ExternalPathService _externalPathService;

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

  String? get downloadsDir => _service.getString(SPKeys.downloads);
  Future<void> setDownloadsCustomDir({
    required Function() onSuccess,
    required Function(String e) onFail,
  }) async {
    String? dirError;
    String? directoryPath;

    try {
      directoryPath = await _externalPathService.getPathOfDirectory();
      if (directoryPath == null) return;
      final maybeDir = Directory(directoryPath);
      if (!maybeDir.existsSync()) return;
      maybeDir.statSync();
      File(p.join(directoryPath, 'test'))
        ..createSync()
        ..deleteSync();
    } catch (e) {
      dirError = e.toString();
    }

    if (dirError != null) {
      onFail(dirError);
    } else {
      if (directoryPath != null) {
        await _service.setValue(SPKeys.downloads, directoryPath);
        onSuccess();
      }
    }
  }

  int get localAudioindex => _service.getInt(SPKeys.localAudioIndex) ?? 0;
  Future<void> setLocalAudioindex(int value) async =>
      _service.setValue(SPKeys.localAudioIndex, value);

  bool get neverShowFailedImports =>
      _service.getBool(SPKeys.neverShowImportFails) ?? false;
  void setNeverShowFailedImports(bool value) =>
      _service.setValue(SPKeys.neverShowImportFails, value);

  bool get enableDiscordRPC => _service.getBool(SPKeys.enableDiscord) ?? false;
  Future<bool> setEnableDiscordRPC(bool value) =>
      _service.setValue(SPKeys.enableDiscord, value);

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

  bool get blurredPlayerBackground =>
      _service.getBool(SPKeys.blurredPlayerBackground) ?? false;
  void setBlurredPlayerBackground(bool value) =>
      _service.setValue(SPKeys.blurredPlayerBackground, value);

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

  bool get useYaruTheme => _service.getBool(SPKeys.useYaruTheme) ?? false;
  void setUseYaruTheme(bool value) =>
      _service.setValue(SPKeys.useYaruTheme, value);

  int? get customThemeColor => _service.getInt(SPKeys.customThemeColor);
  void setCustomThemeColor(int? value) =>
      _service.setValue(SPKeys.customThemeColor, value);
  bool get useCustomThemeColor =>
      _service.getBool(SPKeys.useCustomThemeColor) ?? false;
  void setUseCustomThemeColor(bool value) =>
      _service.setValue(SPKeys.useCustomThemeColor, value);

  bool get usePlayerColor => _service.getBool(SPKeys.usePlayerColor) ?? false;
  Future<void> setUsePlayerColor(bool value) =>
      _service.setValue(SPKeys.usePlayerColor, value);

  int get iconSetIndex => _service.getInt(SPKeys.iconSetIndex) ?? 0;
  void setIconSetIndex(int value) =>
      _service.setValue(SPKeys.iconSetIndex, value);

  String? get podcastIndexApiKey =>
      _service.getString(SPKeys.podcastIndexApiKey);
  void setPodcastIndexApiKey(String value) =>
      _service.setValue(SPKeys.podcastIndexApiKey, value);
  String? get podcastIndexApiSecret =>
      _service.getString(SPKeys.podcastIndexApiSecret);
  void setPodcastIndexApiSecret(String value) async =>
      _service.setValue(SPKeys.podcastIndexApiSecret, value);

  bool get showPositionDuration =>
      _service.getBool(SPKeys.showPositionDuration) ?? true;
  Future<void> setShowPositionDuration(bool value) async =>
      _service.setValue(SPKeys.showPositionDuration, value);

  bool get hideCompletedEpisodes =>
      _service.getBool(SPKeys.hideCompletedEpisodes) ?? false;
  Future<void> setHideCompletedEpisodes(bool value) =>
      _service.setValue(SPKeys.hideCompletedEpisodes, value);

  bool get showPlayerLyrics =>
      _service.getBool(SPKeys.showPlayerLyrics) ?? false;
  Future<void> setShowPlayerLyrics(bool value) =>
      _service.setValue(SPKeys.showPlayerLyrics, value);

  bool get autoMovePlayer => _service.getBool(SPKeys.autoMovePlayer) ?? false;
  Future<void> setAutoMovePlayer(bool value) =>
      _service.setValue(SPKeys.autoMovePlayer, value);

  bool get enableLyricsGenius =>
      _service.getBool(SPKeys.enableLyricsGenius) ?? false;
  Future<void> setEnableLyricsGenius(bool value) =>
      _service.setValue(SPKeys.enableLyricsGenius, value);

  String? get lyricsGeniusAccessToken =>
      _service.getString(SPKeys.lyricsGeniusAccessToken);
  Future<void> setLyricsGeniusAccessToken(String value) =>
      _service.setValue(SPKeys.lyricsGeniusAccessToken, value);

  bool get neverAskAgainForGeniusToken =>
      _service.getBool(SPKeys.neverAskAgainForGeniusToken) ?? false;
  Future<void> setNeverAskAgainForGeniusToken(bool value) =>
      _service.setValue(SPKeys.neverAskAgainForGeniusToken, value);

  Future<void> wipeAllSettings() async => _service.wipeAllSettings();

  @override
  Future<void> dispose() async {
    await _propertiesChangedSub?.cancel();
    super.dispose();
  }
}
