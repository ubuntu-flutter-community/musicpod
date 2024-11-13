import 'local_cover_service.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class LocalCoverModel extends SafeChangeNotifier {
  LocalCoverModel({
    required LocalCoverService localCoverService,
  }) : _localCoverService = localCoverService;

  final LocalCoverService _localCoverService;
  StreamSubscription<bool>? _propertiesChangedSub;

  Map<String, Uint8List?> get store => _localCoverService.store;
  Uint8List? get(String? albumId) => _localCoverService.get(albumId);

  Future<Uint8List?> getCover({
    required String albumId,
    required String path,
  }) async =>
      _localCoverService.getCover(albumId: albumId, path: path);

  void init() => _propertiesChangedSub ??=
      _localCoverService.propertiesChanged.listen((_) => notifyListeners());

  @override
  Future<void> dispose() async {
    await _propertiesChangedSub?.cancel();
    super.dispose();
  }
}
