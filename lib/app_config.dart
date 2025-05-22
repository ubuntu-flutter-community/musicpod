import 'package:flutter/foundation.dart';

import 'extensions/taget_platform_x.dart';

class AppConfig {
  static const appName = 'musicpod';
  static const appTitle = 'MusicPod';
  static const appId = 'org.feichtmeier.Musicpod';
  static const androidAppId = 'org.feichtmeier.apps.musicpod';
  static const discordApplicationId = '1235321910221602837';
  static const linuxDBusName = 'org.mpris.MediaPlayer2.musicpod';
  static const androidChannelId = 'org.feichtmeier.apps.musicpod.channel.audio';
  static const repoUrl = 'http://github.com/ubuntu-flutter-community/musicpod';
  static const sponsorLink = 'https://github.com/sponsors/Feichtmeier';
  static const gitHubShortLink = 'ubuntu-flutter-community/musicpod';
  static const fallbackThumbnailUrl =
      'https://raw.githubusercontent.com/ubuntu-flutter-community/musicpod/main/snap/gui/musicpod.png';
  static bool allowDiscordRPC =
      (kDebugMode && !isMobile) ||
      isWindows ||
      const bool.fromEnvironment('ALLOW_DISCORD_RPC');
  static bool windowManagerImplemented = isDesktop;

  // TODO(#1022): fix linux video fullscreen
  static bool allowVideoFullScreen = !isLinux;
}
