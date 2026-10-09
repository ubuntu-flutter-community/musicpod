import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/logging.dart';
import '../service/secure_bookmark_service.dart';

@lazySingleton
class SecureBookmarkManager {
  final SecureBookmarkService _service;

  SecureBookmarkManager({required SecureBookmarkService service})
    : _service = service {
    Logger.o(tag: '$SecureBookmarkManager');
  }

  late final Command<void, bool> command = Command.createAsyncNoParam(() async {
    if (command.value == true) return true;
    return _service.restoreAllSavedBookmarks();
  }, initialValue: false);
}
