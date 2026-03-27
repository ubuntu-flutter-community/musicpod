import 'package:injectable/injectable.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../app/app_config.dart';

@module
abstract class MediaKitModule {
  VideoController get mediaKit {
    MediaKit.ensureInitialized();
    return VideoController(
      Player(
        configuration: const PlayerConfiguration(title: AppConfig.appTitle),
      ),
    );
  }
}
