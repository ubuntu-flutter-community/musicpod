import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/no_search_result_page.dart';
import '../../common/view/round_image_container.dart';
import '../../common/view/sliver_fill_remaining_progress.dart';
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

  final List<String>? artists;
  final Widget? noResultMessage, noResultIcon;

  @override
  Widget build(BuildContext context) {
    if (artists == null) {
      return const SliverFillRemainingProgress();
    }

    if (artists!.isEmpty) {
      return SliverFillNoSearchResultPage(
        icon: noResultIcon,
        message: noResultMessage,
      );
    }
    final model = di<LocalAudioModel>();

    return SliverGrid.builder(
      itemCount: artists!.length,
      gridDelegate: kDiskGridDelegate,
      itemBuilder: (context, index) {
        final artistName = artists!.elementAt(index);
        final artistAudios = model.findTitlesOfArtist(artistName);
        final images = model.findImages(audios: artistAudios ?? []);

        final text = artists!.elementAt(index);

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
                builder: (_) => ArtistPage(artistAudios: artistAudios),
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
  }
}
