import '../extensions/taget_platform_x.dart';

class AppConfig {
  static const appName = 'musicpod';
  static const appTitle = 'MusicPod';
  static const appId = 'org.feichtmeier.Musicpod';
  static const androidAppId = 'org.feichtmeier.apps.musicpod';
  static const linuxDBusName = 'org.mpris.MediaPlayer2.musicpod';
  static const androidChannelId = 'org.feichtmeier.apps.musicpod.channel.audio';
  static const sponsorLink = 'https://github.com/sponsors/Feichtmeier';
  static const gitHubShortLink = 'ubuntu-flutter-community/musicpod';
  static const fallbackThumbnailUrl =
      'https://raw.githubusercontent.com/ubuntu-flutter-community/musicpod/main/snap/gui/musicpod.png';

  static bool windowManagerImplemented = isDesktop;

  static bool allowVideoFullScreen = true;

  static const String owner = 'ubuntu-flutter-community';
  static const host = 'github.com';
  static const scheme = 'https';
  static const String repoUrl = '$scheme://$host/$owner/$appName';
  static const String repoReportIssueUrl = '$owner/$appName/issues/new';
}
