import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import '../../common/data/audio.dart';
import '../../common/util/family.dart';
import 'radio_manager.dart';
import 'station_manager.dart';

@lazySingleton
class RadioStarStationManager {
  RadioStarStationManager({required RadioManager radioManager}) {
    command = Command.createAsync((station) async {
      if (station != null) {
        final starred = await radioManager.toggleStarStation(station);
        if (!starred) {
          Family.dispose<StationManager>(station.uuid!);
        }
      }
      return radioManager.getStarredStations();
    }, initialValue: {});

    command.run();
  }
  late final Command<Audio?, Set<String>> command;
}
