import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../../extensions/ref_x.dart';
import '../../settings/data/shared_preferences_keys.dart';
import '../../settings/manager/settings_manager.dart';
import '../../settings/service/settings_service.dart';
import '../service/online_art_service.dart';

part 'online_art_manager.g.dart';

@riverpod
class OnlineArtManager extends _$OnlineArtManager {
  @override
  Future<String?> build(String? icyTitle) async {
    ref.cacheFor(const Duration(minutes: 10));
    final isDataSafeMode = di.isRegistered<SettingsService>()
        ? (ref.watch(settingsBoolManagerProvider(SPKeys.dataSafeMode)) ?? false)
        : false;
    if (isDataSafeMode || icyTitle == null || icyTitle.isEmpty) {
      return null;
    }
    return di<OnlineArtService>().fetchAlbumArt(icyTitle: icyTitle);
  }
}
