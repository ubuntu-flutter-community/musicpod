import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import '../app/window_size_to_settings_listener.dart';
import '../app_config.dart';
import '../common/data/close_btn_action.dart';
import '../common/file_names.dart';
import '../common/view/icons.dart';
import '../extensions/shared_preferences_x.dart';
import '../extensions/taget_platform_x.dart';
import '../local_audio/local_audio_view.dart';
import '../persistence_utils.dart';

class SettingsService {
  SettingsService({
    required String? downloadsDefaultDir,
    required SharedPreferences sharedPreferences,
    required String forcedUpdateThreshold,
    required WindowManager? windowManager,
  })  : _preferences = sharedPreferences,
        _downloadsDefaultDir = downloadsDefaultDir,
        _forcedUpdateThreshold = forcedUpdateThreshold {
    if (windowManager != null) {
      final wm = windowManager;
      final ps = _preferences;
      wm
        ..setMinimumSize(const Size(500, 700))
        ..setSize(const Size(950, 820));
      wm.addListener(
        WindowSizeToSettingsListener(
          onFullscreen: (v) => ps.setBool(SPKeys.windowFullscreen, v),
          onMaximize: (v) => ps.setBool(SPKeys.windowMaximized, v),
          onResize: (v) async {
            if (ps.getBool(SPKeys.saveWindowSize) ?? false) {
              ps.setInt(SPKeys.windowHeight, v.height.toInt()).then(
                    (_) => ps.setInt(SPKeys.windowWidth, v.width.toInt()),
                  );
            }
          },
        ),
      );

      if (ps.getBool(SPKeys.windowFullscreen) ?? false) {
        wm.setFullScreen(true);
      } else if (ps.getBool(SPKeys.windowMaximized) ?? false) {
        wm.maximize();
      } else {
        final height = ps.getInt(SPKeys.windowHeight) ?? 820;
        final width = ps.getInt(SPKeys.windowWidth) ?? 950;
        wm.setSize(
          Size(
            width.toDouble(),
            height.toDouble(),
          ),
        );
      }
    }
  }

  final String? _downloadsDefaultDir;
  final SharedPreferences _preferences;
  final _propertiesChangedController = StreamController<bool>.broadcast();
  Stream<bool> get propertiesChanged => _propertiesChangedController.stream;
  bool notify(bool saved) {
    if (saved) _propertiesChangedController.add(true);
    return saved;
  }

  int get themeIndex => _preferences.getInt(SPKeys.themeIndex) ?? 0;
  void setThemeIndex(int value) {
    _preferences.setInt(SPKeys.themeIndex, value).then(notify);
  }

  bool get useYaruTheme => _preferences.getBool(SPKeys.useYaruTheme) ?? isLinux;
  void setUseYaruTheme(bool value) =>
      _preferences.setBool(SPKeys.useYaruTheme, value).then(notify);

  bool get useCustomThemeColor =>
      _preferences.getBool(SPKeys.useCustomThemeColor) ?? false;
  void setUseCustomThemeColor(bool value) =>
      _preferences.setBool(SPKeys.useCustomThemeColor, value).then(notify);

  int? get customThemeColor => _preferences.getInt(SPKeys.customThemeColor);
  void setCustomThemeColor(int? value) {
    if (value == null) return;
    _preferences.setInt(SPKeys.customThemeColor, value).then(notify);
  }

  int get iconSetIndex =>
      _preferences.getInt(SPKeys.iconSetIndex) ?? IconSet.platformDefaultIndex;
  void setIconSetIndex(int value) =>
      _preferences.setInt(SPKeys.iconSetIndex, value).then(notify);

  int get localAudioIndex =>
      _preferences.getInt(SPKeys.localAudioIndex) ??
      LocalAudioView.albums.index;
  void setLocalAudioIndex(int value) =>
      _preferences.setInt(SPKeys.localAudioIndex, value).then(notify);

  bool get neverShowFailedImports =>
      _preferences.getBool(SPKeys.neverShowImportFails) ?? false;
  void setNeverShowFailedImports(bool value) {
    _preferences.setBool(SPKeys.neverShowImportFails, value).then(notify);
  }

  bool get groupAlbumsOnlyByAlbumName =>
      _preferences.getBool(SPKeys.groupAlbumsOnlyByAlbumName) ?? false;
  void setGroupAlbumsOnlyByAlbumName(bool value) => _preferences
      .setBool(SPKeys.groupAlbumsOnlyByAlbumName, value)
      .then(notify);

  bool get enableLastFmScrobbling =>
      _preferences.getBool(SPKeys.enableLastFm) ?? false;
  String? get lastFmApiKey => _preferences.getString(SPKeys.lastFmApiKey);
  String? get lastFmSecret => _preferences.getString(SPKeys.lastFmSecret);
  String? get lastFmSessionKey =>
      _preferences.getString(SPKeys.lastFmSessionKey);
  String? get lastFmUsername => _preferences.getString(SPKeys.lastFmUsername);
  void setEnableLastFmScrobbling(bool value) =>
      _preferences.setBool(SPKeys.enableLastFm, value).then(notify);

  void setLastFmApiKey(String value) =>
      _preferences.setString(SPKeys.lastFmApiKey, value).then(notify);

  void setLastFmSecret(String value) =>
      _preferences.setString(SPKeys.lastFmSecret, value).then(notify);

  void setLastFmSessionKey(String value) =>
      _preferences.setString(SPKeys.lastFmSessionKey, value).then(notify);

  void setLastFmUsername(String value) =>
      _preferences.setString(SPKeys.lastFmUsername, value).then(notify);

  bool get enableListenBrainzScrobbling =>
      _preferences.getBool(SPKeys.enableListenBrainz) ?? false;
  String? get listenBrainzApiKey =>
      _preferences.getString(SPKeys.listenBrainzApiKey);
  void setEnableListenBrainzScrobbling(bool value) =>
      _preferences.setBool(SPKeys.enableListenBrainz, value).then(notify);
  void setListenBrainzApiKey(String value) =>
      _preferences.setString(SPKeys.listenBrainzApiKey, value).then(notify);

  bool get enableDiscordRPC =>
      AppConfig.allowDiscordRPC &&
      (_preferences.getBool(SPKeys.enableDiscord) ?? false);
  Future<bool> setEnableDiscordRPC(bool value) async =>
      notify(await _preferences.setBool(SPKeys.enableDiscord, value));

  bool get useMoreAnimations =>
      _preferences.getBool(SPKeys.useMoreAnimations) ?? !isLinux;
  void setUseMoreAnimations(bool value) =>
      _preferences.setBool(SPKeys.useMoreAnimations, value).then(notify);

  bool get saveWindowSize =>
      _preferences.getBool(SPKeys.saveWindowSize) ??
      AppConfig.windowManagerImplemented;
  void setSaveWindowSize(bool value) =>
      _preferences.setBool(SPKeys.saveWindowSize, value).then(notify);

  bool get notifyDataSafeMode =>
      _preferences.getBool(SPKeys.notifyDataSafeMode) ?? true;
  void setNotifyDataSafeMode(bool value) =>
      _preferences.setBool(SPKeys.notifyDataSafeMode, value).then(notify);

  bool recentPatchNotesDisposed(String version) =>
      _preferences.getString(SPKeys.patchNotesDisposed) == version;

  Future<void> disposePatchNotes(String version) async =>
      _preferences.setString(SPKeys.patchNotesDisposed, version).then(notify);

  bool get usePodcastIndex =>
      _preferences.getBool(SPKeys.usePodcastIndex) ?? false;
  Future<void> setUsePodcastIndex(bool value) async =>
      _preferences.setBool(SPKeys.usePodcastIndex, value).then(notify);

  String? get podcastIndexApiKey =>
      _preferences.getString(SPKeys.podcastIndexApiKey);
  void setPodcastIndexApiKey(String value) =>
      _preferences.setString(SPKeys.podcastIndexApiKey, value).then(notify);

  String? get podcastIndexApiSecret =>
      _preferences.getString(SPKeys.podcastIndexApiSecret);
  void setPodcastIndexApiSecret(String value) =>
      _preferences.setString(SPKeys.podcastIndexApiSecret, value).then(notify);

  String? get directory =>
      _preferences.getString(SPKeys.directory) ?? getMusicDefaultDir();
  Future<void> setDirectory(String directory) async =>
      _preferences.setString(SPKeys.directory, directory).then(notify);

  String? get downloadsDir =>
      _preferences.getString(SPKeys.downloads) ?? _downloadsDefaultDir;
  Future<void> setDownloadsCustomDir(String directory) async =>
      _preferences.setString(SPKeys.downloads, directory).then(notify);

  final String _forcedUpdateThreshold;
  String get forcedUpdateThreshold => _forcedUpdateThreshold;

  bool getBackupSaved(String version) =>
      _preferences.getBool(SPKeys.backupSaved + version) ?? false;

  Future<void> setBackupSaved(String version, bool value) async =>
      _preferences.setBool(SPKeys.backupSaved + version, value).then(notify);

  bool get showPositionDuration =>
      _preferences.getBool(SPKeys.showPositionDuration) ?? false;
  Future<void> setShowPositionDuration(bool value) async =>
      _preferences.setBool(SPKeys.showPositionDuration, value).then(notify);

  CloseBtnAction get closeBtnActionIndex =>
      _preferences.getString(SPKeys.closeBtnAction) == null
          ? CloseBtnAction.alwaysAsk
          : CloseBtnAction.values.firstWhere(
              (element) =>
                  element.toString() ==
                  _preferences.getString(SPKeys.closeBtnAction),
              orElse: () => CloseBtnAction.alwaysAsk,
            );
  void setCloseBtnActionIndex(CloseBtnAction value) {
    _preferences
        .setString(SPKeys.closeBtnAction, value.toString())
        .then(notify);
  }

  Future<void> wipeAllSettings() async {
    await Future.wait([
      for (final name in FileNames.all) wipeCustomSettings(filename: name),
      _preferences.clear(),
    ]);
    exit(0);
  }

  Future<void> dispose() async => _propertiesChangedController.close();
}
