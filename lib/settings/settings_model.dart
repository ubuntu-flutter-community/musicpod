import 'dart:async';
import 'dart:io';

import 'package:github/github.dart';
import 'package:path/path.dart' as p;
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../../external_path/external_path_service.dart';
import '../common/data/close_btn_action.dart';
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

  String? get directory => _service.directory;
  Future<void> setDirectory(String value) async => _service.setDirectory(value);

  String? get downloadsDir => _service.downloadsDir;
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
        await _service.setDownloadsCustomDir(directoryPath);
        onSuccess();
      }
    }
  }

  bool get neverShowFailedImports => _service.neverShowFailedImports;
  void setNeverShowFailedImports(bool value) =>
      _service.setNeverShowFailedImports(value);

  bool get enableDiscordRPC => _service.enableDiscordRPC;
  Future<bool> setEnableDiscordRPC(bool value) =>
      _service.setEnableDiscordRPC(value);

  bool get groupAlbumsOnlyByAlbumName => _service.groupAlbumsOnlyByAlbumName;
  void setGroupAlbumsOnlyByAlbumName(bool value) =>
      _service.setGroupAlbumsOnlyByAlbumName(value);

  bool get enableLastFmScrobbling => _service.enableLastFmScrobbling;
  String? get lastFmApiKey => _service.lastFmApiKey;
  String? get lastFmSecret => _service.lastFmSecret;
  String? get lastFmSessionKey => _service.lastFmSessionKey;
  String? get lastFmUsername => _service.lastFmUsername;
  void setEnableLastFmScrobbling(bool value) =>
      _service.setEnableLastFmScrobbling(value);
  void setLastFmApiKey(String value) => _service.setLastFmApiKey(value);
  void setLastFmSecret(String value) => _service.setLastFmSecret(value);
  void setLastFmSessionKey(String value) => _service.setLastFmSessionKey(value);
  void setLastFmUsername(String value) => _service.setLastFmUsername(value);

  bool get enableListenBrainzScrobbling =>
      _service.enableListenBrainzScrobbling;
  String? get listenBrainzApiKey => _service.listenBrainzApiKey;
  void setEnableListenBrainzScrobbling(bool value) =>
      _service.setEnableListenBrainzScrobbling(value);
  void setListenBrainzApiKey(String value) =>
      _service.setListenBrainzApiKey(value);

  bool get useMoreAnimations => _service.useMoreAnimations;
  void setUseMoreAnimations(bool value) => _service.setUseMoreAnimations(value);

  bool get blurredPlayerBackground => _service.blurredPlayerBackground;
  void setBlurredPlayerBackground(bool value) =>
      _service.setBlurredPlayerBackground(value);

  bool get saveWindowSize => _service.saveWindowSize;
  void setSaveWindowSize(bool value) => _service.setSaveWindowSize(value);

  bool get notifyDataSafeMode => _service.notifyDataSafeMode;
  void setNotifyDataSafeMode(bool value) =>
      _service.setNotifyDataSafeMode(value);

  bool get usePodcastIndex => _service.usePodcastIndex;
  Future<void> setUsePodcastIndex(bool value) async =>
      _service.setUsePodcastIndex(value);

  int get themeIndex => _service.themeIndex;
  void setThemeIndex(int value) => _service.setThemeIndex(value);

  bool get useYaruTheme => _service.useYaruTheme;
  void setUseYaruTheme(bool value) => _service.setUseYaruTheme(value);

  int? get customThemeColor => _service.customThemeColor;
  void setCustomThemeColor(int? value) => _service.setCustomThemeColor(value);

  bool get useCustomThemeColor => _service.useCustomThemeColor;
  void setUseCustomThemeColor(bool value) =>
      _service.setUseCustomThemeColor(value);

  bool get usePlayerColor => _service.usePlayerColor;
  Future<void> setUsePlayerColor(bool value) =>
      _service.setUsePlayerColor(value);

  int get iconSetIndex => _service.iconSetIndex;
  void setIconSetIndex(int value) => _service.setIconSetIndex(value);

  String? get podcastIndexApiKey => _service.podcastIndexApiKey;
  void setPodcastIndexApiKey(String value) =>
      _service.setPodcastIndexApiKey(value);

  String? get podcastIndexApiSecret => _service.podcastIndexApiSecret;
  void setPodcastIndexApiSecret(String value) async =>
      _service.setPodcastIndexApiSecret(value);

  CloseBtnAction get closeBtnActionIndex => _service.closeBtnActionIndex;
  void setCloseBtnActionIndex(CloseBtnAction value) =>
      _service.setCloseBtnActionIndex(value);

  bool get showPositionDuration => _service.showPositionDuration;
  Future<void> setShowPositionDuration(bool value) async =>
      _service.setShowPositionDuration(value);

  bool get hideCompletedEpisodes => _service.hideCompletedEpisodes;
  Future<void> setHideCompletedEpisodes(bool value) =>
      _service.setHideCompletedEpisodes(value);

  bool get showPlayerLyrics => _service.showPlayerLyrics;
  Future<void> setShowPlayerLyrics(bool value) =>
      _service.setShowPlayerLyrics(value);

  bool get autoMovePlayer => _service.autoMovePlayer;
  Future<void> setAutoMovePlayer(bool value) =>
      _service.setAutoMovePlayer(value);

  bool get enableLyricsGenius => _service.enableLyricsGenius;
  Future<void> setEnableLyricsGenius(bool value) =>
      _service.setEnableLyricsGenius(value);

  String? get lyricsGeniusAccessToken => _service.lyricsGeniusAccessToken;
  Future<void> setLyricsGeniusAccessToken(String value) =>
      _service.setLyricsGeniusAccessToken(value);

  bool get neverAskAgainForGeniusToken => _service.neverAskAgainForGeniusToken;
  Future<void> setNeverAskAgainForGeniusToken(bool value) =>
      _service.setNeverAskAgainForGeniusToken(value);

  Future<void> wipeAllSettings() async => _service.wipeAllSettings();

  @override
  Future<void> dispose() async {
    await _propertiesChangedSub?.cancel();
    super.dispose();
  }
}
