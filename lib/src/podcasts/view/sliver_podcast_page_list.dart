import 'package:flutter/material.dart';

import '../../../get.dart';
import '../../../library.dart';
import '../../../podcasts.dart';
import '../../data/audio.dart';
import '../../player/player_model.dart';

class SliverPodcastPageList extends StatelessWidget with WatchItMixin {
  const SliverPodcastPageList({
    super.key,
    required this.audios,
    required this.pageId,
  });

  final Set<Audio> audios;
  final String pageId;

  @override
  Widget build(BuildContext context) {
    final playerModel = getIt<PlayerModel>();
    final libraryModel = getIt<LibraryModel>();
    final isPlayerPlaying = watchPropertyValue((PlayerModel m) => m.isPlaying);
    final selectedAudio = watchPropertyValue((PlayerModel m) => m.audio);
    final isOnline = watchPropertyValue((PlayerModel m) => m.isOnline);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: audios.length,
        (context, index) {
          final episode = audios.elementAt(index);
          final download = libraryModel.getDownload(episode.url);

          return PodcastAudioTile(
            key: ValueKey(episode.url),
            addPodcast: episode.website == null
                ? null
                : () => libraryModel.addPodcast(
                      episode.website!,
                      audios,
                    ),
            removeUpdate: () => libraryModel.removePodcastUpdate(pageId),
            isExpanded: episode == selectedAudio,
            audio:
                download != null ? episode.copyWith(path: download) : episode,
            isPlayerPlaying: isPlayerPlaying,
            selected: episode == selectedAudio,
            pause: playerModel.pause,
            resume: playerModel.resume,
            startPlaylist: () => playerModel.startPlaylist(
              audios: audios,
              listName: pageId,
              index: index,
            ),
            lastPosition: playerModel.getLastPosition(episode.url),
            safeLastPosition: playerModel.safeLastPosition,
            isOnline: isOnline,
            insertIntoQueue: () => playerModel.insertIntoQueue(episode),
          );
        },
      ),
    );
  }
}
