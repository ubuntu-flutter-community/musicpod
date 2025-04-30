import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import 'ui_constants.dart';
import '../../player/player_model.dart';
import '../data/audio.dart';
import 'audio_page_type.dart';
import 'audio_tile.dart';

class SliverAudioTileList extends StatelessWidget with WatchItMixin {
  const SliverAudioTileList({
    super.key,
    required this.audios,
    required this.pageId,
    this.onSubTitleTab,
    required this.audioPageType,
    this.selectedColor,
  });

  final List<Audio> audios;
  final String pageId;
  final AudioPageType audioPageType;
  final void Function(String text)? onSubTitleTab;
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    final playerModel = di<PlayerModel>();
    final isPlaying = watchPropertyValue((PlayerModel m) => m.isPlaying);
    final currentAudio = watchPropertyValue((PlayerModel m) => m.audio);
    final showLeading = audios.length < kShowLeadingThreshold &&
        audioPageType != AudioPageType.allTitlesView;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: audios.length,
        (context, index) {
          final audio = audios.elementAt(index);
          final audioSelected = currentAudio == audio;
          return Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: AudioTile(
              showLeading: showLeading,
              key: ValueKey(audio.path ?? audio.url),
              audioPageType: audioPageType,
              onSubTitleTap: onSubTitleTab,
              isPlayerPlaying: isPlaying,
              onTap: () => playerModel.startPlaylist(
                audios: audios,
                listName: pageId,
                index: index,
              ),
              selected: audioSelected,
              audio: audio,
              pageId: pageId,
              selectedColor: selectedColor,
            ),
          );
        },
      ),
    );
  }
}
