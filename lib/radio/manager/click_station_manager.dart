import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../service/radio_service.dart';

part 'click_station_manager.g.dart';

@Riverpod(keepAlive: true)
class ClickStationManager extends _$ClickStationManager {
  @override
  void build() {}

  Future<void> clickStation(String? uuid) async {
    if (uuid != null) {
      await di<RadioService>().clickStation(uuid);
    }
  }
}
