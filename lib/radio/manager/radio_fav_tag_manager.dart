import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/util/family.dart';
import '../service/radio_service.dart';

@injectable
class RadioFavTagManager {
  RadioFavTagManager._({required RadioService service}) {
    command = Command.createAsync((tag) async {
      if (tag != null) {
        await service.toggleFavRadioTag(tag);
      }

      return service.getFavRadioTags();
    }, initialValue: {});

    command.run();
  }

  @factoryMethod
  static RadioFavTagManager create({required RadioService service}) =>
      Family.of(
        '$RadioFavTagManager',
        () => RadioFavTagManager._(service: service),
        shouldDispose: (m) => m.command.listenerCount == 0,
        onDispose: (m) => m.command.dispose(),
      );

  late final Command<String?, Set<String>> command;
}
