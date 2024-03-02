import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../l10n/l10n.dart';
import 'artist_page.dart';
import 'local_audio_model.dart';

class ArtistsView extends ConsumerWidget {
  const ArtistsView({
    super.key,
    this.artists,
    this.noResultMessage,
    this.noResultIcon,
  });

  final Set<Audio>? artists;
  final Widget? noResultMessage, noResultIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final model = ref.read(localAudioModelProvider);
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: GridView.builder(
        itemCount: artists!.length,
        padding: gridPadding,
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
