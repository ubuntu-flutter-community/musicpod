import 'dart:async';

import 'package:safe_change_notifier/safe_change_notifier.dart';

import 'online_art_service.dart';

class OnlineArtModel extends SafeChangeNotifier {
  OnlineArtModel({
    required OnlineArtService onlineArtService,
  }) : _onlineArtService = onlineArtService;

  final OnlineArtService _onlineArtService;
  StreamSubscription<bool>? _propertiesChangedSub;
  String? getCover(String icyTitle) => _onlineArtService.get(icyTitle);

  void init() {
    _propertiesChangedSub ??=
        _onlineArtService.propertiesChanged.listen((_) => notifyListeners());
  }

  @override
  Future<void> dispose() async {
    await _propertiesChangedSub?.cancel();
    super.dispose();
  }
}
