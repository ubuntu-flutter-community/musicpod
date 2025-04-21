import 'dart:io';

import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
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

class LikedAudioPage extends StatefulWidget with WatchItStatefulWidgetMixin {
  const LikedAudioPage({super.key});

  @override
  State<LikedAudioPage> createState() => _LikedAudioPageState();
}

class _LikedAudioPageState extends State<LikedAudioPage> {
  late List<Audio> likedAudios;

  @override
  void initState() {
    super.initState();
    getFavoriteAudios();
  }

  void getFavoriteAudios() {
    likedAudios = di<LibraryModel>()
        .favoriteAudios
        .map((e) => Audio.local(File(e)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    watchPropertyValue((LibraryModel m) {
      setState(() => getFavoriteAudios());
      return m.favoriteAudios;
    });
    watchPropertyValue((LibraryModel m) {
      setState(() => getFavoriteAudios());
      return m.favoriteAudios.length;
    });

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
