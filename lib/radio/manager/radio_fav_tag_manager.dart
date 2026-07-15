import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../service/radio_service.dart';

@Injectable(cache: true)
class RadioFavTagManager {
  RadioFavTagManager({required RadioService service}) {
    command = Command.createAsync((tag) async {
      if (tag != null) {
        await service.toggleFavRadioTag(tag);
      }

      return service.getFavRadioTags();
    }, initialValue: {});

    command.run();
  }

  late final Command<String?, Set<String>> command;
}
