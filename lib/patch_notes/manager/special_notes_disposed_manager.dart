import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../../settings/data/shared_preferences_keys.dart';
import '../../settings/service/settings_service.dart';

part 'special_notes_disposed_manager.g.dart';

@Riverpod(keepAlive: true)
class SpecialNotesDisposedManager extends _$SpecialNotesDisposedManager {
  SpecialNotesDisposedManager({
    SettingsService? settingsService,
    PackageInfo? packageInfo,
  }) : _settingsServiceOverride = settingsService,
       _packageInfoOverride = packageInfo;

  final SettingsService? _settingsServiceOverride;
  final PackageInfo? _packageInfoOverride;

  SettingsService get _settingsService =>
      _settingsServiceOverride ?? di<SettingsService>();
  PackageInfo get _packageInfo => _packageInfoOverride ?? di<PackageInfo>();

  @override
  bool build() {
    return _settingsService.getString(SPKeys.specialNotesDisposed) ==
        _packageInfo.version;
  }

  Future<void> disposeNotes() async {
    await _settingsService.setValue(
      SPKeys.specialNotesDisposed,
      _packageInfo.version,
    );
    state = true;
  }
}
