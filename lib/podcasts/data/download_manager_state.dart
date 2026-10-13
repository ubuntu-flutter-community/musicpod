import '../../common/data/audio.dart';
import 'podcast_download.dart';

class DownloadManagerState {
  final String? downloadsDirectory;
  final Set<Audio> activeDownloads;
  final List<Audio> recentDownloads;
  final PodcastDownload? lastEvent;

  const DownloadManagerState({
    this.downloadsDirectory,
    this.activeDownloads = const {},
    this.recentDownloads = const [],
    this.lastEvent,
  });

  bool get hasActiveDownloads => activeDownloads.isNotEmpty;
  bool get hasRecentDownloads => recentDownloads.isNotEmpty;

  DownloadManagerState copyWith({
    String? downloadsDirectory,
    Set<Audio>? activeDownloads,
    List<Audio>? recentDownloads,
    PodcastDownload? lastEvent,
  }) => DownloadManagerState(
    downloadsDirectory: downloadsDirectory ?? this.downloadsDirectory,
    activeDownloads: activeDownloads ?? this.activeDownloads,
    recentDownloads: recentDownloads ?? this.recentDownloads,
    lastEvent: lastEvent ?? this.lastEvent,
  );
}
