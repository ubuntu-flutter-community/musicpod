import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../player/player_model.dart';
import '../../settings/settings_model.dart';
import '../data/audio.dart';
import 'audio_page_type.dart';
import 'audio_tile.dart';
import 'ui_constants.dart';

class SliverAudioTileList extends StatelessWidget with WatchItMixin {
  const SliverAudioTileList({
    super.key,
    required this.audios,
    required this.pageId,
    this.onSubTitleTab,
    this.onSubSubTitleTab,
    required this.audioPageType,
    this.selectedColor,
    required this.constraints,
  });

  final List<Audio> audios;
  final String pageId;
  final AudioPageType audioPageType;
  final void Function(String text)? onSubTitleTab;
  final void Function(Audio audio)? onSubSubTitleTab;
  final Color? selectedColor;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    final mqSize = constraints.maxWidth;
    final playerToTheRight = mqSize > kSideBarThreshHold;
    final autoMovePlayer = watchPropertyValue(
      (SettingsModel m) => m.autoMovePlayer,
    );
    final width = autoMovePlayer && playerToTheRight
        ? mqSize - kSideBarPlayerWidth
        : mqSize;

    final playerModel = di<PlayerModel>();
    final isPlaying = watchPropertyValue((PlayerModel m) => m.isPlaying);

    final currentAudio = watchPropertyValue((PlayerModel m) => m.audio);
    final allowLeadingImage =
        audios.length < kShowLeadingThreshold &&
        audioPageType != AudioPageType.allTitlesView;

    return SliverList(
      delegate: SliverChildBuilderDelegate(childCount: audios.length, (
        context,
        index,
      ) {
        final audio = audios.elementAt(index);
        final audioSelected = currentAudio == audio;
        return Padding(
          padding: const EdgeInsets.only(bottom: kSmallestSpace),
          child: AudioTile(
            showSubSubTitle: width > 1200,
            showDuration: width > 700,
            showSubTitle: width > 500,
            allowLeadingImage: allowLeadingImage,
            key: ValueKey(audio.path ?? audio.url ?? index),
            audioPageType: audioPageType,
            onSubTitleTap: onSubTitleTab,
            onSubSubTitleTap: onSubSubTitleTab,
            isPlayerPlaying: isPlaying,
            onTap: () {
              if (audioSelected) {
                if (isPlaying) {
                  playerModel.pause();
                } else {
                  playerModel.resume();
                }
              } else {
                playerModel.startPlaylist(
                  audios: audios,
                  listName: pageId,
                  index: index,
                );
              }
            },
            selected: audioSelected,
            audio: audio,
            pageId: pageId,
            selectedColor: selectedColor,
          ),
        );
      }),
    );
  }
}
