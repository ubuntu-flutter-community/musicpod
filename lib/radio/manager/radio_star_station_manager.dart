import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/data/audio.dart';
import '../../dependencies.dart';
import '../service/radio_service.dart';

part 'radio_star_station_manager.g.dart';

@Riverpod(keepAlive: true)
class RadioStarStationManager extends _$RadioStarStationManager {
  @override
  Future<Set<String>> build() => di<RadioService>().getStarredStations();

  Future<void> toggleStarredStation(Audio? station) async {
    if (station != null) {
      await di<RadioService>().toggleStarredStation(station);
    }
    state = AsyncData(await di<RadioService>().getStarredStations());
  }
}
