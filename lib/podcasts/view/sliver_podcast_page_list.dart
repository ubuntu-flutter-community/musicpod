import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/data/audio.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import 'podcast_audio_tile.dart';

class SliverPodcastPageList extends StatelessWidget with WatchItMixin {
  const SliverPodcastPageList({
    super.key,
    required this.audios,
    required this.pageId,
    required this.isOnline,
  });

  final List<Audio> audios;
  final String pageId;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final playerModel = di<PlayerModel>();
    final libraryModel = di<LibraryModel>();
    final selectedAudio = watchPropertyValue((PlayerModel m) => m.audio);

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
          addPodcast: episode.website == null
              ? null
              : () async => libraryModel.addPodcast(
                  feedUrl: episode.website!,
                  imageUrl: episode.albumArtUrl ?? episode.imageUrl ?? '',
                  name: episode.album ?? '',
                  artist: episode.artist ?? '',
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
