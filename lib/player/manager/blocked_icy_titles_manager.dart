import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../../settings/data/shared_preferences_keys.dart';
import '../../settings/service/settings_service.dart';
import 'mpv_metadata_history_manager.dart';

part 'blocked_icy_titles_manager.g.dart';

const defaultBlockedIcyTitles = <String>{
  '.westlotto.de',
  'lidl',
  'kaufland',
  'Verbraucherinformation',
  'Werbung',
  'Advertisement',
};

@Riverpod(keepAlive: true)
class BlockedIcyTitlesManager extends _$BlockedIcyTitlesManager {
  BlockedIcyTitlesManager({SettingsService? settingsService})
      : _settingsServiceOverride = settingsService;

  final SettingsService? _settingsServiceOverride;
  SettingsService get _settingsService =>
      _settingsServiceOverride ?? di<SettingsService>();

  @override
  Set<String> build() {
    final list = _settingsService.getStringList(SPKeys.blockedIcyTitles);
    if (list == null || list.isEmpty) {
      _settingsService.setValue(
        SPKeys.blockedIcyTitles,
        defaultBlockedIcyTitles.toList(),
      );
      return defaultBlockedIcyTitles;
    }
    return list.toSet();
  }

  Future<void> add(String title) async {
    final newSet = {...state, title};
    state = newSet;
    await _settingsService.setValue(SPKeys.blockedIcyTitles, newSet.toList());
    ref.read(mpvMetadataHistoryManagerProvider.notifier).remove(title);
  }

  Future<void> remove(String title) async {
    final newSet = {...state}..remove(title);
    state = newSet;
    await _settingsService.setValue(SPKeys.blockedIcyTitles, newSet.toList());
  }
}
