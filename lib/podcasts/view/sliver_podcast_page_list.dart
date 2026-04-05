import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/connectivity_manager.dart';
import '../../common/data/audio.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import 'podcast_audio_tile.dart';

class SliverPodcastPageList extends StatelessWidget with WatchItMixin {
  const SliverPodcastPageList({
    super.key,
    required this.audios,
    required this.pageId,
    required this.showDownloadsOnly,
  });

  final List<Audio> audios;
  final String pageId;
  final bool showDownloadsOnly;

  @override
  Widget build(BuildContext context) {
    final playerModel = di<PlayerModel>();
    final libraryModel = di<LibraryModel>();
    final selectedAudio = watchPropertyValue((PlayerModel m) => m.audio);
    final isOnline = watchValue(
      (ConnectivityManager m) =>
          m.connectivityCommand.select((p) => p.isOnline),
    );

    return SliverList(
      delegate: SliverChildBuilderDelegate(childCount: audios.length, (
        context,
        index,
      ) {
        final episode = audios.elementAt(index);

        return PodcastAudioTile(
          key: ValueKey('${episode.path ?? episode.url}-$isOnline'),
          showDownloadsOnly: showDownloadsOnly,
          audio: episode,
          isOnline: isOnline,
          addPodcast: episode.feedUrl == null
              ? null
              : () async => libraryModel.addPodcast(
                  feedUrl: episode.feedUrl!,
                  imageUrl: episode.albumArtUrl ?? episode.imageUrl ?? '',
                  name: episode.podcastTitle ?? '',
                  artist: episode.copyright ?? '',
                ),
          isExpanded: episode == selectedAudio,
          selected: episode == selectedAudio,
          startPlaylist: () => playerModel.startPlaylist(
            audios: audios,
            listName: pageId,
            index: index,
          ),
        );
      }),
    );
  }
}
