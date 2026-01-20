import 'dart:async';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../common/file_names.dart';
import '../common/logging.dart';
import 'shared_preferences_keys.dart';
import '../persistence_utils.dart';

class SettingsService {
  SettingsService({
    required SharedPreferences sharedPreferences,
    required String forcedUpdateThreshold,
    required String? downloadsDefaultDir,
  }) : _sharedPreferences = sharedPreferences,
       _forcedUpdateThreshold = forcedUpdateThreshold,
       _downloadsDefaultDir = downloadsDefaultDir;

  final SharedPreferences _sharedPreferences;
  final _propertiesChangedController = StreamController<bool>.broadcast();
  Stream<bool> get propertiesChanged => _propertiesChangedController.stream;
  bool notify(bool saved) {
    if (saved) _propertiesChangedController.add(true);
    return saved;
  }

  final String _forcedUpdateThreshold;
  String get forcedUpdateThreshold => _forcedUpdateThreshold;
  final String? _downloadsDefaultDir;
  String? get downloadsDir =>
      _downloadsDefaultDir ?? getString(SPKeys.downloads);

  String? getString(String key) {
    try {
      return _sharedPreferences.getString(key);
    } on Exception catch (e, s) {
      printMessageInDebugMode(e, trace: s);
      return null;
    }
  }

  bool? getBool(String key) {
    try {
      return _sharedPreferences.getBool(key);
    } on Exception catch (e, s) {
      printMessageInDebugMode(e, trace: s);
      return null;
    }
  }

  double? getDouble(String key) {
    try {
      return _sharedPreferences.getDouble(key);
    } on Exception catch (e, s) {
      printMessageInDebugMode(e, trace: s);
      return null;
    }
  }

  int? getInt(String key) {
    try {
      return _sharedPreferences.getInt(key);
    } on Exception catch (e, s) {
      printMessageInDebugMode(e, trace: s);
      return null;
    }
  }

  List<String>? getStringList(String key) {
    try {
      return _sharedPreferences.getStringList(key);
    } on Exception catch (e, s) {
      printMessageInDebugMode(e, trace: s);
      return null;
    }
  }

  Future<bool> setValue(String key, dynamic value) async {
    try {
      return notify(await switch (value) {
        (bool _) => _sharedPreferences.setBool(key, value),
        (String _) => _sharedPreferences.setString(key, value),
        (int _) => _sharedPreferences.setInt(key, value),
        (double _) => _sharedPreferences.setDouble(key, value),
        (List<String> _) => _sharedPreferences.setStringList(key, value),
        _ => Future.error('Unsupported value type: ${value.runtimeType}'),
      });
    } on Exception catch (e, s) {
      printMessageInDebugMode(e, trace: s);
      return Future.error(e, s);
    }
  }

  Future<void> wipeAllSettings() async {
    await Future.wait([
      for (final name in FileNames.all) wipeCustomSettings(filename: name),
      _sharedPreferences.clear(),
    ]);
    exit(0);
  }

  Future<void> dispose() async => _propertiesChangedController.close();
}
