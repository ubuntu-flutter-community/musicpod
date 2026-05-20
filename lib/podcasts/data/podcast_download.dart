import '../../common/data/audio.dart';

class PodcastDownload {
  final DownloadStatus status;
  final Audio audio;
  final String? path;

  const PodcastDownload({
    required this.status,
    required this.audio,
    required this.path,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PodcastDownload &&
        other.status == status &&
        other.audio.url == audio.url &&
        other.path == path;
  }

  @override
  int get hashCode => Object.hash(status, audio.url, path);
}

enum DownloadStatus { removed, completed, cancelled, inProgress }
