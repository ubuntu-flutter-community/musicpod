import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_card.dart';
import 'package:musicpod/app/common/audio_filter.dart';
import 'package:musicpod/app/common/no_search_result_page.dart';
import 'package:musicpod/app/local_audio/album_page.dart';
import 'package:musicpod/app/local_audio/shop_recommendations.dart';
import 'package:musicpod/constants.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:musicpod/utils.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AlbumsView extends StatelessWidget {
  const AlbumsView({
    super.key,
    required this.albums,
    required this.showWindowControls,
    this.onTextTap,
    required this.startPlaylist,
    required this.isPinnedAlbum,
    required this.removePinnedAlbum,
    required this.addPinnedAlbum,
    required this.findAlbum,
  });

  final Set<Audio>? albums;
  final bool showWindowControls;
  final void Function({
    required String text,
    required AudioType audioType,
  })? onTextTap;

  final Future<void> Function(Set<Audio>, String) startPlaylist;
  final bool Function(String) isPinnedAlbum;
  final void Function(String) removePinnedAlbum;
  final void Function(String, Set<Audio>) addPinnedAlbum;
  final Set<Audio>? Function(Audio, [AudioFilter]) findAlbum;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (albums == null) {
      return const Center(
        child: YaruCircularProgressIndicator(),
      );
    }

    if (albums!.isEmpty) {
      return NoSearchResultPage(
        message: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.noLocalTitlesFound),
            const ShopRecommendations(),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(kYaruPagePadding),
      itemCount: albums!.length,
      gridDelegate: kImageGridDelegate,
      itemBuilder: (context, index) {
        final audio = albums!.elementAt(index);
        String? id = generateAlbumId(audio);
        final albumAudios = findAlbum(audio);

        final image = audio.pictureData == null
            ? Center(
                child: Icon(
                  YaruIcons.music_note,
                  size: 140,
                  color: theme.hintColor,
                ),
              )
            : Image.memory(
                audio.pictureData!,
                fit: BoxFit.fitWidth,
                filterQuality: FilterQuality.medium,
              );

        return AudioCard(
          bottom: Align(
            alignment: Alignment.bottomCenter,
            child:
                AudioCardBottom(text: audio.album == null ? '' : audio.album!),
          ),
          image: image,
          onTap: id == null
              ? null
              : () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return AlbumPage(
                          onTextTap: ({required audioType, required text}) {
                            onTextTap?.call(text: text, audioType: audioType);
                            Navigator.of(context).maybePop();
                          },
                          id: id,
                          isPinnedAlbum: isPinnedAlbum,
                          removePinnedAlbum: removePinnedAlbum,
                          album: albumAudios,
                          addPinnedAlbum: addPinnedAlbum,
                        );
                      },
                    ),
                  ),
          onPlay: albumAudios == null || albumAudios.isEmpty || id == null
              ? null
              : () => startPlaylist(albumAudios, id),
        );
      },
    );
  }
}

class AudioCardBottom extends StatelessWidget {
  const AudioCardBottom({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Tooltip(
        message: text,
        child: Container(
          width: double.infinity,
          height: 30,
          margin: const EdgeInsets.all(1),
          padding: const EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.inverseSurface,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(kYaruContainerRadius),
              bottomRight: Radius.circular(kYaruContainerRadius),
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              color: theme.colorScheme.onInverseSurface,
            ),
          ),
        ),
      ),
    );
  }
}
