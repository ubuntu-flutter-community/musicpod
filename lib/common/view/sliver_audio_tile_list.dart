import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../extensions/build_context_x.dart';
import '../../player/player_model.dart';
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
    required this.audioPageType,
    this.selectedColor,
    this.constraints,
  });

  final List<Audio> audios;
  final String pageId;
  final AudioPageType audioPageType;
  final void Function(String text)? onSubTitleTab;
  final Color? selectedColor;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    final mqSize = constraints?.maxWidth ?? context.mediaQuerySize.width;
    final playerToTheRight = mqSize > kSideBarThreshHold;
    final width = playerToTheRight ? mqSize - kSideBarPlayerWidth : mqSize;

    final playerModel = di<PlayerModel>();
    final isPlaying = watchPropertyValue((PlayerModel m) => m.isPlaying);

    final currentAudio = watchPropertyValue((PlayerModel m) => m.audio);
    final allowLeadingImage =
        audios.length < kShowLeadingThreshold &&
        audioPageType != AudioPageType.allTitlesView;

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: kMediumSpace),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(childCount: audios.length, (
          context,
          index,
        ) {
          final audio = audios.elementAt(index);
          final audioSelected = currentAudio == audio;
          return Padding(
            padding: const EdgeInsets.only(bottom: kSmallestSpace),
            child: AudioTile(
              showDuration: width > 1200,
              showSlimTileSubtitle: width >= 900,
              showSecondLineSubTitle: width < 900,
              allowLeadingImage: allowLeadingImage,
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
        }),
      ),
    );
  }
}
