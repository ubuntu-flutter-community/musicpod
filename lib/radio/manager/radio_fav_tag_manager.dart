import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'radio_manager.dart';

@Injectable(cache: true)
class RadioFavTagManager {
  RadioFavTagManager({required RadioManager radioManager}) {
    command = Command.createAsync((tag) async {
      if (tag != null) {
        await radioManager.toggleFavRadioTag(tag);
      }

      return radioManager.getFavRadioTags();
    }, initialValue: {});

    command.run();
  }

  late final Command<String?, Set<String>> command;
}
