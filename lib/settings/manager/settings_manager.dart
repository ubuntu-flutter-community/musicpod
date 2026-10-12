import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../service/settings_service.dart';

part 'settings_manager.g.dart';

@Riverpod(keepAlive: true)
class SettingsScrollIndex extends _$SettingsScrollIndex {
  @override
  int build() => 0;

  void set(int value) => state = value;
  set index(int value) => state = value;
}

@Riverpod(keepAlive: true)
class SettingsBoolManager extends _$SettingsBoolManager {
  late final SettingsService _settingsService = di<SettingsService>();

  @override
  bool? build(String key) => _settingsService.getBool(key);

  Future<void> set(bool? value) async {
    final success = await _settingsService.setValue(key, value);
    if (!success) {
      throw SettingsException('Failed to set bool for key: $key');
    }
    state = _settingsService.getBool(key);
  }

  Future<void> call(bool? value) => set(value);

  Future<void> toggle() async {
    final current = state ?? false;
    await set(!current);
  }
}

@Riverpod(keepAlive: true)
class SettingsIntManager extends _$SettingsIntManager {
  late final SettingsService _settingsService = di<SettingsService>();

  @override
  int? build(String key) => _settingsService.getInt(key);

  Future<void> set(int? value) async {
    final success = await _settingsService.setValue(key, value);
    if (!success) {
      throw SettingsException('Failed to set int for key: $key');
    }
    state = _settingsService.getInt(key);
  }

  Future<void> call(int? value) => set(value);
}

@Riverpod(keepAlive: true)
class SettingsDoubleManager extends _$SettingsDoubleManager {
  late final SettingsService _settingsService = di<SettingsService>();

  @override
  double? build(String key) => _settingsService.getDouble(key);

  Future<void> set(double? value) async {
    final success = await _settingsService.setValue(key, value);
    if (!success) {
      throw SettingsException('Failed to set double for key: $key');
    }
    state = _settingsService.getDouble(key);
  }

  Future<void> call(double? value) => set(value);
}

@Riverpod(keepAlive: true)
class SettingsStringManager extends _$SettingsStringManager {
  late final SettingsService _settingsService = di<SettingsService>();

  @override
  String? build(String key) => _settingsService.getString(key);

  Future<void> set(String? value) async {
    final success = await _settingsService.setValue(key, value);
    if (!success) {
      throw SettingsException('Failed to set string for key: $key');
    }
    state = _settingsService.getString(key);
  }

  Future<void> call(String? value) => set(value);
}

@Riverpod(keepAlive: true)
class SettingsStringListManager extends _$SettingsStringListManager {
  late final SettingsService _settingsService = di<SettingsService>();

  @override
  List<String>? build(String key) => _settingsService.getStringList(key);

  Future<void> set(List<String>? value) async {
    final success = await _settingsService.setValue(key, value);
    if (!success) {
      throw SettingsException('Failed to set string list for key: $key');
    }
    state = _settingsService.getStringList(key);
  }

  Future<void> call(List<String>? value) => set(value);

  Future<void> add(String item) async {
    final list = List<String>.from(state ?? []);
    if (!list.contains(item)) {
      list.add(item);
      await set(list);
    }
  }

  Future<void> addToStringList(String item) => add(item);

  Future<void> remove(String item) async {
    final list = List<String>.from(state ?? []);
    if (list.contains(item)) {
      list.remove(item);
      await set(list);
    }
  }

  Future<void> removeFromStringList(String item) => remove(item);
}

class SettingsException implements Exception {
  SettingsException(this.message);

  final String message;

  @override
  String toString() => 'SettingsException: $message';
}
