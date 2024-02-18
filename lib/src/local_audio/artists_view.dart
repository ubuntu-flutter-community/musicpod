import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../l10n/l10n.dart';
import 'artist_page.dart';
import 'local_audio_model.dart';

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
        icons: noResultIcon,
        message: noResultMessage,
      );
    }
    final model = context.read<LocalAudioModel>();

    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: GridView.builder(
        itemCount: artists!.length,
        padding: gridPadding,
        shrinkWrap: true,
        gridDelegate: kDiskGridDelegate,
        itemBuilder: (context, index) {
          final artistAudios = model.findArtist(
            artists!.elementAt(index),
          );
          final images = model.findImages(artistAudios ?? {});

          final text = artists!.elementAt(index).artist ?? context.l10n.unknown;

          return YaruSelectableContainer(
            selected: false,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return ArtistPage(
                    images: images,
                    artistAudios: artistAudios,
                  );
                },
              ),
            ),
            borderRadius: BorderRadius.circular(300),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: ArtistImage(
                    images: images,
                  ),
                ),
                ArtistVignette(text: text),
              ],
            ),
          );
        },
      ),
    );
  }
}
