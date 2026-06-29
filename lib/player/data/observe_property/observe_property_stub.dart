import 'package:media_kit/media_kit.dart';

/// This file is a stub implementation for platforms that do not support the `media_kit` package.
/// we use this for the icytitle information, since this is not a stream included
/// in the normal player.stream
///
Future<void> observeProperty({
  required String property,
  required Player player,
  Future<void> Function(String)? listener,
}) async => throw UnimplementedError();
