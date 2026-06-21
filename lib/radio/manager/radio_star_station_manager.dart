import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import '../../common/data/audio.dart';
import 'radio_manager.dart';

@Injectable(cache: true)
class RadioStarStationManager {
  RadioStarStationManager({required RadioManager radioManager}) {
    command = Command.createAsync((station) async {
      if (station != null) {
        await radioManager.toggleStarStation(station);
      }
      return radioManager.getStarredStations();
    }, initialValue: {});

    radioManager.wipeCommand.listen((result, sub) {
      command.run();
      sub.cancel();
    });

    command.run();
  }
  late final Command<Audio?, Set<String>> command;
}
