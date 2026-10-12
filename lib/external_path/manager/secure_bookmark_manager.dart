import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../service/secure_bookmark_service.dart';

part 'secure_bookmark_manager.g.dart';

@Riverpod(keepAlive: true)
class SecureBookmarkManager extends _$SecureBookmarkManager {
  @override
  bool build() => false;

  Future<bool> restore() async {
    if (state) return true;
    final success = await di<SecureBookmarkService>()
        .restoreAllSavedBookmarks();
    state = success;
    return success;
  }
}
