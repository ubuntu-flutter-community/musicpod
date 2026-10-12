import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../player/manager/current_audio_manager.dart';
import '../../player/manager/play_pause_manager.dart';
import '../data/audio.dart';
import 'audio_page_type.dart';
import 'local_audio_tile.dart';
import 'ui_constants.dart';

class SliverLocalAudioTileList extends ConsumerWidget {
  const SliverLocalAudioTileList({
    super.key,
    required this.audios,
    required this.pageId,
    this.onSubTitleTab,
    this.onSubSubTitleTab,
    required this.audioPageType,
    this.selectedColor,
    required this.constraints,
    required this.startNewPlaylistOnTap,
  });

  final List<Audio> audios;
  final String pageId;
  final AudioPageType audioPageType;
  final void Function(String text)? onSubTitleTab;
  final void Function(Audio audio)? onSubSubTitleTab;
  final Color? selectedColor;
  final BoxConstraints constraints;
  final bool startNewPlaylistOnTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mqSize = constraints.maxWidth;

    final width = mqSize;

    final isPlaying = ref.watch(playPauseManagerProvider);
    final currentAudio = ref.watch(currentAudioManagerProvider);
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
          child: LocalAudioTile(
            showSubSubTitle: width > 1200,
            showDuration: width > 1000,
            showSubTitle: width > 500,
            style: width <= 500
                ? AudioTileStyle.normal
                : AudioTileStyle.compact,
            allowLeadingImage: allowLeadingImage,
            audioPageType: audioPageType,
            onSubTitleTap: onSubTitleTab,
            onSubSubTitleTap: onSubSubTitleTab,
            isPlayerPlaying: isPlaying,
            onTap: () {
              if (audioSelected) {
                if (isPlaying) {
                  ref.read(playPauseManagerProvider.notifier).pause();
                } else {
                  ref.read(playPauseManagerProvider.notifier).resume();
                }
              } else {
                ref.read(currentAudioManagerProvider.notifier).play(
                  audios: startNewPlaylistOnTap ? audios : [audio],
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

