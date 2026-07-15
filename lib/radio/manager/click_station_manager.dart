import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../service/radio_service.dart';

@lazySingleton
class ClickStationManager {
  ClickStationManager({required RadioService radioService}) {
    command = Command.createAsyncNoResult(radioService.clickStation);
  }

  late final Command<String?, void> command;
}
