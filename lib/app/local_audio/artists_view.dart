import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/app/common/round_image_container.dart';
import 'package:musicpod/app/local_audio/artist_page.dart';
import 'package:musicpod/app/local_audio/local_audio_model.dart';
import 'package:musicpod/data/audio.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class ArtistsView extends StatefulWidget {
  const ArtistsView({
    super.key,
    required this.similarArtistsSearchResult,
    required this.showWindowControls,
  });

  final Set<Audio> similarArtistsSearchResult;
  final bool showWindowControls;

  @override
  State<ArtistsView> createState() => _ArtistsViewState();
}

class _ArtistsViewState extends State<ArtistsView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final findArtist = context.read<LocalAudioModel>().findArtist;
    final findImages = context.read<LocalAudioModel>().findImages;

    return GridView.builder(
      itemCount: widget.similarArtistsSearchResult.length,
      padding: kGridPadding,
      shrinkWrap: true,
      gridDelegate: kImageGridDelegate,
      itemBuilder: (context, index) {
        final artistAudios = findArtist(
          widget.similarArtistsSearchResult.elementAt(index),
        );
        final images = findImages(artistAudios ?? {});

        var text = Text(
          widget.similarArtistsSearchResult.elementAt(index).artist ??
              'unknown',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w100,
            fontSize: 20,
            color: theme.colorScheme.onInverseSurface,
          ),
          textAlign: TextAlign.center,
        );

        return YaruSelectableContainer(
          selected: false,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return ArtistPage(
                  images: images,
                  artistAudios: artistAudios,
                  showWindowControls: widget.showWindowControls,
                );
              },
            ),
          ),
          borderRadius: BorderRadius.circular(300),
          child: RoundImageContainer(image: images?.firstOrNull, text: text),
        );
      },
    );
  }
}
