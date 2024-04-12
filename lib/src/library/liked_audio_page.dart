import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../get.dart';
import '../../local_audio.dart';
import '../../utils.dart';
import '../common/fall_back_header_image.dart';
import '../l10n/l10n.dart';

class LikedAudioPage extends StatelessWidget {
  const LikedAudioPage({
    super.key,
    this.likedLocalAudios,
  });

  static Widget createIcon({
    required BuildContext context,
    required bool selected,
  }) {
    return SideBarFallBackImage(
      child: selected ? Icon(Iconz().heartFilled) : Icon(Iconz().heart),
    );
  }

  final Set<Audio>? likedLocalAudios;

  @override
  Widget build(BuildContext context) {
    final model = getIt<LocalAudioModel>();

    return AudioPage(
      classicTiles: false,
      onAlbumTap: (text) {
        final albumAudios = model.findAlbum(Audio(album: text));
        if (albumAudios?.firstOrNull == null) return;
        final id = generateAlbumId(albumAudios!.first);
        if (id == null) return;

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) {
              return AlbumPage(
                id: id,
                album: albumAudios,
              );
            },
          ),
        );
      },
      onArtistTap: (text) {
        final artistAudios = model.findArtist(Audio(artist: text));
        final images = model.findImages(artistAudios ?? {});

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) {
              return ArtistPage(
                images: images,
                artistAudios: artistAudios,
              );
            },
          ),
        );
      },
      controlPanelButton: Padding(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: Text(
          '${likedLocalAudios?.length} ${context.l10n.titles}',
          style: getControlPanelStyle(context.t.textTheme),
        ),
      ),
      noResultMessage: Text(context.l10n.likedSongsSubtitle),
      noResultIcon: const AnimatedEmoji(AnimatedEmojis.twoHearts),
      audios: likedLocalAudios ?? {},
      audioPageType: AudioPageType.likedAudio,
      pageId: kLikedAudiosPageId,
      title: Text(context.l10n.likedSongs),
      headerTitle: context.l10n.likedSongs,
      headerSubtile: context.l10n.likedSongsSubtitle,
      headerLabel: context.l10n.playlist,
      image: FallBackHeaderImage(
        child: Icon(
          Iconz().heart,
          size: 65,
        ),
      ),
    );
  }
}
