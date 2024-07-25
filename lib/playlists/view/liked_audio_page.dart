import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/audio_page_type.dart';
import '../../common/view/fall_back_header_image.dart';
import '../../common/view/icons.dart';
import '../../common/view/side_bar_fall_back_image.dart';
import '../../common/view/sliver_audio_page.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../local_audio/local_audio_model.dart';
import '../../local_audio/view/artist_page.dart';

class LikedAudioPage extends StatelessWidget with WatchItMixin {
  const LikedAudioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = di<LocalAudioModel>();
    final likedAudios = watchPropertyValue((LibraryModel m) => m.likedAudios);

    return SliverAudioPage(
      onPageLabelTab: (text) {
        final artistAudios = model.findArtist(Audio(artist: text));
        final artist = artistAudios?.firstOrNull?.artist;
        if (artist == null) return;
        final images = model.findImages(artistAudios ?? {});

        di<LibraryModel>().push(
          builder: (_) => ArtistPage(
            images: images,
            artistAudios: artistAudios,
          ),
          pageId: artist,
        );
      },
      noSearchResultMessage: Text(context.l10n.likedSongsSubtitle),
      noSearchResultIcons: const AnimatedEmoji(AnimatedEmojis.twoHearts),
      audios: likedAudios,
      audioPageType: AudioPageType.likedAudio,
      pageId: kLikedAudiosPageId,
      pageTitle: context.l10n.likedSongs,
      pageLabel: context.l10n.likedSongsSubtitle,
      pageSubTitle: '${likedAudios.length} ${context.l10n.titles}',
      image: FallBackHeaderImage(
        child: Icon(
          Iconz().heart,
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
      child: selected ? Icon(Iconz().heartFilled) : Icon(Iconz().heart),
    );
  }
}
