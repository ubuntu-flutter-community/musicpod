import 'package:genius_lyrics/genius_lyrics.dart';
import 'package:injectable/injectable.dart';

import '../common/logging.dart';

@module
abstract class GeniusModule {
  @Injectable(cache: true)
  Genius genius({@factoryParam required String accessToken}) {
    printInfoInDebugMode(
      'Instance created with access token: $accessToken',
      tag: '$GeniusModule',
    );
    return Genius(accessToken: accessToken);
  }
}
