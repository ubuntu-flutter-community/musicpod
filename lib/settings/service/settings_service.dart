import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/logging.dart';
import '../../extensions/platform_x.dart';
import '../data/shared_preferences_keys.dart';

@lazySingleton
class SettingsService {
  SettingsService({required SharedPreferences sharedPreferences})
    : _sharedPreferences = sharedPreferences;

  final SharedPreferences _sharedPreferences;
  final _propertiesChangedController = StreamController<bool>.broadcast();
  Stream<bool> get propertiesChanged => _propertiesChangedController.stream;
  bool notify(bool saved) {
    if (saved) _propertiesChangedController.add(true);
    return saved;
  }

  String? getString(String key) {
    try {
      return _sharedPreferences.getString(key);
    } on Exception catch (e, s) {
      Logger.e(e, trace: s, tag: '$SettingsService');
      return null;
    }
  }

  bool? getBool(String key) {
    try {
      return _sharedPreferences.getBool(key);
    } on Exception catch (e, s) {
      Logger.e(e, trace: s, tag: '$SettingsService');
      return null;
    }
  }

  double? getDouble(String key) {
    try {
      return _sharedPreferences.getDouble(key);
    } on Exception catch (e, s) {
      Logger.e(e, trace: s, tag: '$SettingsService');
      return null;
    }
  }

  int? getInt(String key) {
    try {
      return _sharedPreferences.getInt(key);
    } on Exception catch (e, s) {
      Logger.e(e, trace: s, tag: '$SettingsService');
      return null;
    }
  }

  List<String>? getStringList(String key) {
    try {
      return _sharedPreferences.getStringList(key);
    } on Exception catch (e, s) {
      Logger.e(e, trace: s, tag: '$SettingsService');
      return null;
    }
  }

  /// Sets a value in the shared preferences.
  /// The value can be of type bool, String, int, double, or List<String>.
  /// Returns true if the value was successfully saved, if not, it returns false. If [throwOnError] is true, it will throw an exception on error.
  Future<bool> setValue(
    String key,
    dynamic value, {
    bool throwOnError = true,
  }) async {
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
      Logger.e(e, trace: s, tag: '$SettingsService');
      return throwOnError ? Future.error(e) : false;
    }
  }

  Future<void> wipeAllSettings() => _sharedPreferences.clear();

  Future<String?> get downloadsDirOrDefault async =>
      getString(SPKeys.downloads) ?? await PlatformX.downloadsDefaultDir;

  @disposeMethod
  Future<void> dispose() async => _propertiesChangedController.close();
}
