import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import 'online_art_service.dart';

@lazySingleton
class OnlineArtModel extends SafeChangeNotifier {
  OnlineArtModel({required OnlineArtService onlineArtService})
    : _onlineArtService = onlineArtService {
    _propertiesChangedSub ??= _onlineArtService.propertiesChanged.listen(
      (_) => notifyListeners(),
    );
  }

  final OnlineArtService _onlineArtService;
  StreamSubscription<bool>? _propertiesChangedSub;
  String? getCover(String icyTitle) => _onlineArtService.get(icyTitle);

  @disposeMethod
  @override
  Future<void> dispose() async {
    await _propertiesChangedSub?.cancel();
    super.dispose();
  }
}
