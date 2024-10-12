import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../common/data/close_btn_action.dart';
import '../constants.dart';

class SettingsService {
  SettingsService({required SharedPreferences sharedPreferences})
      : _preferences = sharedPreferences;

  final SharedPreferences _preferences;
  final _propertiesChangedController = StreamController<bool>.broadcast();
  Stream<bool> get propertiesChanged => _propertiesChangedController.stream;

  int get themeIndex => _preferences.getInt(kThemeIndex) ?? 0;
  void setThemeIndex(int value) {
    _preferences.setInt(kThemeIndex, value).then(
      (saved) {
        if (saved) _propertiesChangedController.add(true);
      },
    );
  }

  bool get neverShowFailedImports =>
      _preferences.getBool(kNeverShowImportFails) ?? false;

  void setNeverShowFailedImports(bool value) {
    _preferences.setBool(kNeverShowImportFails, value).then(
      (saved) {
        if (saved) _propertiesChangedController.add(true);
      },
    );
  }

  bool get enableDiscordRPC => _preferences.getBool(kEnableDiscordRPC) ?? false;

  void setEnableDiscordRPC(bool value) {
    _preferences.setBool(kEnableDiscordRPC, value).then(
      (saved) {
        if (saved) _propertiesChangedController.add(true);
      },
    );
  }

  bool recentPatchNotesDisposed(String version) =>
      _preferences.getString(kPatchNotesDisposed) == version;

  Future<void> disposePatchNotes(String version) async =>
      _preferences.setString(kPatchNotesDisposed, version).then(
        (saved) {
          if (saved) _propertiesChangedController.add(true);
        },
      );

  bool get usePodcastIndex => _preferences.getBool(kUsePodcastIndex) ?? false;
  Future<void> setUsePodcastIndex(bool value) async {
    return _preferences.setBool(kUsePodcastIndex, value).then((value) {
      if (value) _propertiesChangedController.add(true);
    });
  }

  String? get podcastIndexApiKey => _preferences.getString(kPodcastIndexApiKey);
  void setPodcastIndexApiKey(String value) {
    _preferences.setString(kPodcastIndexApiKey, value).then((saved) {
      if (saved) _propertiesChangedController.add(true);
    });
  }

  String? get podcastIndexApiSecret =>
      _preferences.getString(kPodcastIndexApiSecret);
  void setPodcastIndexApiSecret(String value) {
    _preferences.setString(kPodcastIndexApiSecret, value).then((saved) {
      if (saved) _propertiesChangedController.add(true);
    });
  }

  String? get directory => _preferences.getString(kDirectoryProperty);
  Future<void> setDirectory(String directory) async {
    await _preferences.setString(kDirectoryProperty, directory).then((saved) {
      if (saved) _propertiesChangedController.add(true);
    });
  }

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
        if (saved) _propertiesChangedController.add(true);
      },
    );
  }

  Future<void> dispose() async => _propertiesChangedController.close();
}
