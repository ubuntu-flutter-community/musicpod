import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/connectivity_model.dart';
import '../../common/data/audio.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import 'podcast_audio_tile.dart';

class SliverPodcastPageList extends StatelessWidget with WatchItMixin {
  const SliverPodcastPageList({
    super.key,
    required this.audios,
    required this.pageId,
  });

  final List<Audio> audios;
  final String pageId;

  @override
  Widget build(BuildContext context) {
    final playerModel = di<PlayerModel>();
    final libraryModel = di<LibraryModel>();
    final isPlayerPlaying = watchPropertyValue((PlayerModel m) => m.isPlaying);
    final selectedAudio = watchPropertyValue((PlayerModel m) => m.audio);
    final isOnline = watchPropertyValue((ConnectivityModel m) => m.isOnline);

    return SliverList(
      delegate: SliverChildBuilderDelegate(childCount: audios.length, (
        context,
        index,
      ) {
        final episode = audios.elementAt(index);

        return PodcastAudioTile(
          key: ValueKey(episode.path ?? episode.url),
          audio: episode,
          isOnline: isOnline,
          isPlayerPlaying: isPlayerPlaying,
          addPodcast: episode.website == null
              ? null
              : () async => libraryModel.addPodcast(
                  feedUrl: episode.website!,
                  imageUrl: episode.albumArtUrl ?? episode.imageUrl ?? '',
                  name: episode.album ?? '',
                  artist: episode.artist ?? '',
                ),
          removeUpdate: () => libraryModel.removePodcastUpdate(pageId),
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
