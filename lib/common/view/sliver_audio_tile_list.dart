import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../data/audio.dart';
import 'audio_page_type.dart';
import 'audio_tile.dart';

class SliverAudioTileList extends StatelessWidget with WatchItMixin {
  const SliverAudioTileList({
    super.key,
    required this.audios,
    required this.pageId,
    this.padding,
    this.onSubTitleTab,
    required this.audioPageType,
  });

  final Set<Audio> audios;
  final String pageId;
  final AudioPageType audioPageType;
  final void Function(String text)? onSubTitleTab;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final libraryModel = di<LibraryModel>();
    final playerModel = di<PlayerModel>();
    final isPlaying = watchPropertyValue((PlayerModel m) => m.isPlaying);
    final currentAudio = watchPropertyValue((PlayerModel m) => m.audio);

    return SliverPadding(
      padding: padding ?? EdgeInsets.zero,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          childCount: audios.length,
          (context, index) {
            final audio = audios.elementAt(index);
            final audioSelected = currentAudio == audio;
            return AudioTile(
              key: ValueKey(audio.path ?? audio.url),
              audioPageType: audioPageType,
              onSubTitleTap: onSubTitleTab,
              isPlayerPlaying: isPlaying,
              pause: playerModel.pause,
              startPlaylist: () => playerModel.startPlaylist(
                audios: audios,
                listName: pageId,
                index: index,
              ),
              resume: playerModel.resume,
              selected: audioSelected,
              audio: audio,
              insertIntoQueue: playerModel.insertIntoQueue,
              pageId: pageId,
              libraryModel: libraryModel,
            );
          },
        ),
      ),
    );
  }
}
