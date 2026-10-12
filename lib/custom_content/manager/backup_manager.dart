import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../../settings/data/shared_preferences_keys.dart';
import '../../settings/service/settings_service.dart';

part 'backup_manager.g.dart';

class BackupState {
  const BackupState({
    this.localAudio = false,
    this.podcast = false,
    this.radio = false,
  });

  final bool localAudio;
  final bool podcast;
  final bool radio;

  bool get confirmEnabled => localAudio && podcast && radio;

  BackupState copyWith({bool? localAudio, bool? podcast, bool? radio}) {
    return BackupState(
      localAudio: localAudio ?? this.localAudio,
      podcast: podcast ?? this.podcast,
      radio: radio ?? this.radio,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackupState &&
          runtimeType == other.runtimeType &&
          localAudio == other.localAudio &&
          podcast == other.podcast &&
          radio == other.radio;

  @override
  int get hashCode => Object.hash(localAudio, podcast, radio);
}

@riverpod
class BackupManager extends _$BackupManager {
  late final SettingsService _settingsService = di<SettingsService>();
  late final PackageInfo _packageInfo = di<PackageInfo>();

  @override
  BackupState build() => const BackupState();

  void setLocalAudio(bool value) => state = state.copyWith(localAudio: value);

  void setPodcast(bool value) => state = state.copyWith(podcast: value);

  void setRadio(bool value) => state = state.copyWith(radio: value);

  void reset() => state = const BackupState();

  Future<bool> setBackupSaved(bool value) async {
    final key = SPKeys.backupSaved + _packageInfo.version;
    await _settingsService.setValue(key, value);
    return _settingsService.getBool(key) ?? false;
  }
}
