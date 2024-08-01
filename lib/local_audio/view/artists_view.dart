import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/data/audio.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/progress.dart';
import '../../common/view/round_image_container.dart';
import '../../common/view/snackbars.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../local_audio_model.dart';
import 'artist_page.dart';

class ArtistsView extends StatelessWidget {
  const ArtistsView({
    super.key,
    this.artists,
    this.noResultMessage,
    this.noResultIcon,
  });

  final Set<Audio>? artists;
  final Widget? noResultMessage, noResultIcon;

  @override
  Widget build(BuildContext context) {
    if (artists == null) {
      return const Center(
        child: Progress(),
      );
    }

    if (artists!.isEmpty) {
      return NoSearchResultPage(
        icon: noResultIcon,
        message: noResultMessage,
      );
    }
    final model = di<LocalAudioModel>();

    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GridView.builder(
            itemCount: artists!.length,
            padding: getAdaptiveHorizontalPadding(constraints: constraints),
            gridDelegate: kDiskGridDelegate,
            itemBuilder: (context, index) {
              final artistName = artists!.elementAt(index).artist;
              if (artistName == null) {
                return SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: RoundImageContainer(
                    fallBackText: context.l10n.unknown,
                  ),
                );
              }
              final artistAudios = model.findTitlesOfArtist(artistName);
              final images = model.findImages(artistAudios ?? {});

              final text =
                  artists!.elementAt(index).artist ?? context.l10n.unknown;

              return YaruSelectableContainer(
                selected: false,
                onTap: () {
                  final artist = artistAudios?.firstOrNull?.artist;
                  if (artist == null) {
                    showSnackBar(
                      context: context,
                      content: Text(context.l10n.unknown),
                    );
                  } else {
                    di<LibraryModel>().push(
                      builder: (_) => ArtistPage(
                        images: images,
                        artistAudios: artistAudios,
                      ),
                      pageId: artist,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(300),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: RoundImageContainer(
                        images: images,
                        fallBackText: text,
                      ),
                    ),
                    ArtistVignette(text: text),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
