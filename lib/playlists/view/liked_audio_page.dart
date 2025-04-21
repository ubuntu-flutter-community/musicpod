import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/page_ids.dart';
import '../../common/view/audio_page_type.dart';
import '../../common/view/fall_back_header_image.dart';
import '../../common/view/icons.dart';
import '../../common/view/side_bar_fall_back_image.dart';
import '../../common/view/sliver_audio_page.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../local_audio/view/artist_page.dart';

class LikedAudioPage extends StatelessWidget with WatchItMixin {
  const LikedAudioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final likedAudios =
        watchPropertyValue((LibraryModel m) => m.favoriteAudios);
    watchPropertyValue((LibraryModel m) => m.favoriteAudios.length);

    return SliverAudioPage(
      onPageLabelTab: (artist) {
        di<LibraryModel>().push(
          builder: (_) => ArtistPage(pageId: artist),
          pageId: artist,
        );
      },
      noSearchResultMessage: Text(context.l10n.likedSongsSubtitle),
      noSearchResultIcons: const AnimatedEmoji(AnimatedEmojis.twoHearts),
      audios: likedAudios,
      audioPageType: AudioPageType.likedAudio,
      pageId: PageIDs.likedAudios,
      pageTitle: context.l10n.likedSongs,
      pageLabel: context.l10n.playlist,
      pageSubTitle: '${likedAudios.length} ${context.l10n.titles}',
      description: Text(
        context.l10n.likedSongsSubtitle,
        style: context.theme.pageHeaderDescription,
      ),
      image: FallBackHeaderImage(
        child: Icon(
          Iconz.heart,
          size: 65,
        ),
      ),
    );
  }
}

class LikedAudioPageIcon extends StatelessWidget {
  const LikedAudioPageIcon({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SideBarFallBackImage(
      child: selected ? Icon(Iconz.heartFilled) : Icon(Iconz.heart),
    );
  }
}
