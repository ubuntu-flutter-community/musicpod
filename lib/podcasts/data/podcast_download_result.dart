import '../../common/data/audio.dart';

class PodcastDownloadResult {
  final PodcastDownloadStatus status;
  final Audio audio;
  final String? path;

  const PodcastDownloadResult({
    required this.status,
    required this.audio,
    required this.path,
  });
}

enum PodcastDownloadStatus { removed, downloaded, cancelled }
