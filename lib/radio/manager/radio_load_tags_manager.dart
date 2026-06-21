import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:radio_browser_api/radio_browser_api.dart';
import 'radio_manager.dart';

@lazySingleton
class RadioLoadTagsManager {
  RadioLoadTagsManager({required RadioManager radioManager}) {
    command = Command.createAsyncNoParam(
      radioManager.loadTags,
      initialValue: [],
    );
    command.run();
  }

  late final Command<void, List<Tag>> command;
}
