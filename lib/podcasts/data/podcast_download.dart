import '../../common/data/audio.dart';

class PodcastDownload {
  final PodcastDownloadStatus status;
  final Audio audio;
  final String? path;

  const PodcastDownload({
    required this.status,
    required this.audio,
    required this.path,
  });
}

enum PodcastDownloadStatus { removed, downloaded, cancelled }
