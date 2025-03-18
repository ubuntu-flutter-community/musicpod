import 'local_cover_service.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class LocalCoverModel extends SafeChangeNotifier {
  LocalCoverModel({
    required LocalCoverService localCoverService,
  }) : _localCoverService = localCoverService {
    _propertiesChangedSub ??=
        _localCoverService.propertiesChanged.listen((_) => notifyListeners());
  }

  final LocalCoverService _localCoverService;
  StreamSubscription<bool>? _propertiesChangedSub;

  int get storeLength => _localCoverService.storeLength;
  Uint8List? get(String? albumId) => _localCoverService.get(albumId);

  Future<Uint8List?> getCover({
    required String albumId,
    required String path,
  }) async =>
      _localCoverService.getCover(albumId: albumId, path: path);

  @override
  Future<void> dispose() async {
    await _propertiesChangedSub?.cancel();
    super.dispose();
  }
}
