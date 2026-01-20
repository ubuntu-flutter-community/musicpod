import 'package:media_kit/media_kit.dart';

import '../common/logging.dart';

Future<void> observeProperty({
  required String property,
  required Player player,
  Future<void> Function(String)? listener,
}) async {
  NativePlayer? nativePlayer;
  try {
    nativePlayer = player.platform as NativePlayer;
  } on Exception catch (e) {
    printMessageInDebugMode(e);
  }

  if (nativePlayer == null) {
    return Future.value();
  }

  if (listener == null) {
    if (nativePlayer.observed.containsKey(property)) {
      return nativePlayer.unobserveProperty(property);
    }
  } else if (!nativePlayer.observed.containsKey(property)) {
    return nativePlayer.observeProperty(property, listener);
  }
}
