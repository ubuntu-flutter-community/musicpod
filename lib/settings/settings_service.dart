import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../common/data/close_btn_action.dart';
import '../constants.dart';

class SettingsService {
  SettingsService({required SharedPreferences sharedPreferences})
      : _preferences = sharedPreferences;

  final SharedPreferences _preferences;

  final _themeIndexController = StreamController<bool>.broadcast();
  Stream<bool> get themeIndexChanged => _themeIndexController.stream;
  int get themeIndex => _preferences.getInt(kThemeIndex) ?? 0;
  void setThemeIndex(int value) {
    _preferences.setInt(kThemeIndex, value).then(
      (saved) {
        if (saved) _themeIndexController.add(true);
      },
    );
  }

  bool get neverShowFailedImports =>
      _preferences.getBool(kNeverShowImportFails) ?? false;
  final _neverShowFailedImportsController = StreamController<bool>.broadcast();
  Stream<bool> get neverShowFailedImportsChanged =>
      _neverShowFailedImportsController.stream;
  void setNeverShowFailedImports(bool value) {
    _preferences.setBool(kNeverShowImportFails, value).then(
      (saved) {
        if (saved) _neverShowFailedImportsController.add(true);
      },
    );
  }

  final _recentPatchNotesDisposedController =
      StreamController<bool>.broadcast();
  Stream<bool> get recentPatchNotesDisposedChanged =>
      _recentPatchNotesDisposedController.stream;
  bool recentPatchNotesDisposed(String version) =>
      _preferences.getString(kPatchNotesDisposed) == version;

  Future<void> disposePatchNotes(String version) async =>
      _preferences.setString(kPatchNotesDisposed, version).then(
        (saved) {
          if (saved) _recentPatchNotesDisposedController.add(true);
        },
      );

  final _usePodcastIndexController = StreamController<bool>.broadcast();
  Stream<bool> get usePodcastIndexChanged => _usePodcastIndexController.stream;
  bool get usePodcastIndex => _preferences.getBool(kUsePodcastIndex) ?? false;
  Future<void> setUsePodcastIndex(bool value) async {
    return _preferences.setBool(kUsePodcastIndex, value).then((value) {
      if (value) _usePodcastIndexController.add(true);
    });
  }

  final _podcastIndexApiKeyController = StreamController<bool>.broadcast();
  Stream<bool> get podcastIndexApiKeyChanged =>
      _podcastIndexApiKeyController.stream;
  String? get podcastIndexApiKey => _preferences.getString(kPodcastIndexApiKey);
  void setPodcastIndexApiKey(String value) {
    _preferences.setString(kPodcastIndexApiKey, value).then((saved) {
      if (saved) _podcastIndexApiKeyController.add(true);
    });
  }

  final _podcastIndexApiSecretController = StreamController<bool>.broadcast();
  Stream<bool> get podcastIndexApiSecretChanged =>
      _podcastIndexApiSecretController.stream;
  String? get podcastIndexApiSecret =>
      _preferences.getString(kPodcastIndexApiSecret);
  void setPodcastIndexApiSecret(String value) {
    _preferences.setString(kPodcastIndexApiSecret, value).then((saved) {
      if (saved) _podcastIndexApiSecretController.add(true);
    });
  }

  final _directoryController = StreamController<bool>.broadcast();
  Stream<bool> get directoryChanged => _directoryController.stream;
  String? get directory => _preferences.getString(kDirectoryProperty);
  Future<void> setDirectory(String directory) async {
    await _preferences.setString(kDirectoryProperty, directory).then((saved) {
      if (saved) _directoryController.add(true);
    });
  }

  final _closeBtnActionIndexController = StreamController<bool>.broadcast();
  Stream<bool> get closeBtnActionChanged =>
      _closeBtnActionIndexController.stream;
  CloseBtnAction get closeBtnActionIndex =>
      _preferences.getString(kCloseBtnAction) == null
          ? CloseBtnAction.alwaysAsk
          : CloseBtnAction.values.firstWhere(
              (element) =>
                  element.toString() == _preferences.getString(kCloseBtnAction),
              orElse: () => CloseBtnAction.alwaysAsk,
            );
  void setCloseBtnActionIndex(CloseBtnAction value) {
    _preferences.setString(kCloseBtnAction, value.toString()).then(
      (saved) {
        if (saved) _closeBtnActionIndexController.add(true);
      },
    );
  }

  Future<void> dispose() async {
    await _themeIndexController.close();
    await _recentPatchNotesDisposedController.close();
    await _neverShowFailedImportsController.close();
    await _directoryController.close();
    await _podcastIndexApiSecretController.close();
    await _usePodcastIndexController.close();
    await _podcastIndexApiKeyController.close();
    await _closeBtnActionIndexController.close();
  }
}
