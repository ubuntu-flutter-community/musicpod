import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/app/common/audio_page_body.dart';
import 'package:musicpod/constants.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class LikedAudioPage extends StatelessWidget {
  const LikedAudioPage({
    super.key,
    this.onTextTap,
    this.likedLocalAudios,
    this.likedPodcasts,
  });

  static Widget createIcon({
    required BuildContext context,
    required bool selected,
  }) {
    return selected
        ? const Icon(YaruIcons.heart_filled)
        : const Icon(YaruIcons.heart);
  }

  final void Function({
    required String text,
    required AudioType audioType,
  })? onTextTap;
  final Set<Audio>? likedLocalAudios;
  final Set<Audio>? likedPodcasts;

  @override
  Widget build(BuildContext context) {
    final localFavs = AudioPageBody(
      key: ValueKey(likedLocalAudios),
      pageId: 'likedAudio',
      audios: likedLocalAudios,
      onTextTap: onTextTap,
      audioPageType: AudioPageType.likedAudio,
    );

    final podcastFavs = AudioPageBody(
      showAudioTileHeader: false,
      key: ValueKey(likedPodcasts),
      pageId: 'likedAudio',
      headerTitle: context.l10n.likedSongs,
      audios: likedPodcasts,
      onTextTap: onTextTap,
      audioPageType: AudioPageType.likedAudio,
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: YaruWindowTitleBar(
          title: SizedBox(
            width: kSearchBarWidth,
            child: TabBar(
              tabs: [
                Tab(text: context.l10n.localAudio),
                Tab(text: context.l10n.podcasts),
              ],
            ),
          ),
          border: BorderSide.none,
          backgroundColor: Colors.transparent,
        ),
        body: TabBarView(
          children: [
            localFavs,
            podcastFavs,
          ],
        ),
      ),
    );
  }
}
