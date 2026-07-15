import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/data/audio.dart';
import '../../common/logging.dart';
import '../service/radio_service.dart';

@lazySingleton
class RadioStarStationManager {
  RadioStarStationManager({required RadioService service}) {
    Logger.o(tag: '$RadioStarStationManager');
    command = Command.createAsync((station) async {
      if (station != null) {
        await service.toggleStarredStation(station);
      }
      return service.getStarredStations();
    }, initialValue: {});

    command.run();
  }
  late final Command<Audio?, Set<String>> command;
}
