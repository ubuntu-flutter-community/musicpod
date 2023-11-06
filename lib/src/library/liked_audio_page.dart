import 'package:flutter/material.dart';
import 'package:musicpod/constants.dart';
import 'package:musicpod/src/common/common_widgets.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../app.dart';
import '../../common.dart';
import '../../data.dart';
import '../common/icons.dart';
import '../l10n/l10n.dart';

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
    return selected ? Icon(Iconz().heartFilled) : Icon(Iconz().heart);
  }

  final void Function({
    required String text,
    required AudioType audioType,
  })? onTextTap;
  final Set<Audio>? likedLocalAudios;
  final Set<Audio>? likedPodcasts;

  @override
  Widget build(BuildContext context) {
    final showWindowControls =
        context.select((AppModel a) => a.showWindowControls);
    final localFavs = AudioPageBody(
      padding: const EdgeInsets.only(top: 10),
      key: ValueKey(likedLocalAudios),
      pageId: 'likedAudio',
      headerTitle: context.l10n.likedSongs,
      audios: likedLocalAudios,
      onTextTap: onTextTap,
      audioPageType: AudioPageType.likedAudio,
    );

    final podcastFavs = AudioPageBody(
      padding: const EdgeInsets.only(top: 10),
      showAudioTileHeader: false,
      key: ValueKey(likedPodcasts),
      pageId: 'likedAudio',
      headerTitle: context.l10n.likedSongs,
      audios: likedPodcasts,
      onTextTap: onTextTap,
      audioPageType: AudioPageType.likedAudio,
    );

    final leading = (Navigator.of(context).canPop())
        ? const NavBackButton()
        : const SizedBox.shrink();
    final title = SizedBox(
      width: kSearchBarWidth,
      child: YaruTabBar(
        tabs: [
          Tab(text: context.l10n.localAudio),
          Tab(text: context.l10n.podcasts),
        ],
      ),
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: HeaderBar(
          leading: leading,
          title: title,
          style: showWindowControls
              ? YaruTitleBarStyle.normal
              : YaruTitleBarStyle.undecorated,
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
