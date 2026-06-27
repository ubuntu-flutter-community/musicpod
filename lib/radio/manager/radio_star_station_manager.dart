import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import '../../common/data/audio.dart';
import 'radio_manager.dart';
import 'station_manager.dart';

@Injectable(cache: true)
class RadioStarStationManager {
  RadioStarStationManager({required RadioManager radioManager}) {
    command = Command.createAsync((station) async {
      if (station != null) {
        final starred = await radioManager.toggleStarStation(station);
        if (!starred) {
          StationManager.dispose(station.uuid!);
        }
      }
      return radioManager.getStarredStations();
    }, initialValue: {});

    command.run();
  }
  late final Command<Audio?, Set<String>> command;
}
