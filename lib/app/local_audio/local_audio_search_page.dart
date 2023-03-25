import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_card.dart';
import 'package:musicpod/app/common/audio_filter.dart';
import 'package:musicpod/app/common/audio_page_header.dart';
import 'package:musicpod/app/common/audio_tile.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/app/common/loading_tile.dart';
import 'package:musicpod/app/common/round_image_container.dart';
import 'package:musicpod/app/common/spaced_divider.dart';
import 'package:musicpod/app/local_audio/album_page.dart';
import 'package:musicpod/app/local_audio/artist_page.dart';
import 'package:musicpod/app/local_audio/local_audio_search_field.dart';
import 'package:musicpod/app/player_model.dart';
import 'package:musicpod/app/playlists/playlist_model.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import 'local_audio_model.dart';

class LocalAudioSearchPage extends StatelessWidget {
  const LocalAudioSearchPage({
    super.key,
    this.showWindowControls = true,
  });

  final bool showWindowControls;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final setSearchQuery = context.read<LocalAudioModel>().setSearchQuery;
    final searchQuery = context.select((LocalAudioModel m) => m.searchQuery);

    final body = ListView(
      shrinkWrap: true,
      children: [
        const _Titles(),
        const SizedBox(
          height: 10,
        ),
        _Albums(showWindowControls),
        const SizedBox(
          height: 10,
        ),
        _Artists(showWindowControls: showWindowControls),
      ],
    );

    return YaruDetailPage(
      backgroundColor: theme.brightness == Brightness.dark
          ? const Color.fromARGB(255, 37, 37, 37)
          : Colors.white,
      appBar: YaruWindowTitleBar(
        style: showWindowControls
            ? YaruTitleBarStyle.normal
            : YaruTitleBarStyle.undecorated,
        title: LocalAudioSearchField(
          key: ValueKey(searchQuery),
          text: searchQuery,
        ),
        leading: Navigator.canPop(context)
            ? YaruBackButton(
                style: YaruBackButtonStyle.rounded,
                onPressed: () {
                  setSearchQuery('');
                  Navigator.maybePop(context);
                },
              )
            : const SizedBox(
                width: 40,
              ),
      ),
      body: body,
    );
  }
}

class _Titles extends StatelessWidget {
  const _Titles();

  @override
  Widget build(BuildContext context) {
    final isPlaying = context.select((PlayerModel m) => m.isPlaying);
    final setAudio = context.read<PlayerModel>().setAudio;
    final currentAudio = context.select((PlayerModel m) => m.audio);
    final play = context.read<PlayerModel>().play;
    final pause = context.read<PlayerModel>().pause;
    final resume = context.read<PlayerModel>().resume;

    final Set<Audio>? titlesResult =
        context.select((LocalAudioModel m) => m.titlesSearchResult);

    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Row(
            children: [
              Text(
                '${context.l10n.titles}  •  ${titlesResult?.length ?? 0}',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w100),
              )
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 15, right: 15),
          child: AudioPageHeader(
            showTrack: false,
            audioFilter: AudioFilter.trackNumber,
          ),
        ),
        const SpacedDivider(
          top: 0,
        ),
        if (titlesResult == null)
          Column(
            children: [
              for (var i = 0; i < 5; i++)
                Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: i == 4 ? 0 : 15,
                  ),
                  child: const LoadingTile(),
                )
            ],
          )
        else
          Column(
            children: List.generate(titlesResult.take(5).length, (index) {
              final audio = titlesResult.take(5).elementAt(index);
              final audioSelected = currentAudio == audio;

              return Padding(
                padding: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                child: AudioTile(
                  showTrack: false,
                  isPlayerPlaying: isPlaying,
                  pause: pause,
                  play: () async {
                    setAudio(audio);
                    await play();
                  },
                  resume: resume,
                  key: ValueKey(audio),
                  selected: audioSelected,
                  audio: audio,
                  likeIcon: const SizedBox(width: 65),
                ),
              );
            }),
          )
      ],
    );
  }
}

class _Albums extends StatelessWidget {
  const _Albums(this.showWindowControls);

  final bool showWindowControls;

  @override
  Widget build(BuildContext context) {
    final startPlaylist = context.read<PlayerModel>().startPlaylist;
    final isPinnedAlbum = context.read<PlaylistModel>().isPinnedAlbum;
    final removePinnedAlbum = context.read<PlaylistModel>().removePinnedAlbum;
    final addPinnedAlbum = context.read<PlaylistModel>().addPinnedAlbum;
    final findAlbum = context.read<LocalAudioModel>().findAlbum;

    final Set<Audio>? similarAlbumsResult =
        context.select((LocalAudioModel m) => m.similarAlbumsSearchResult);

    final theme = Theme.of(context);

    final albumGrid = similarAlbumsResult == null || similarAlbumsResult.isEmpty
        ? const SizedBox.shrink()
        : GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: similarAlbumsResult.length,
            gridDelegate: kImageGridDelegate,
            itemBuilder: (context, index) {
              final audio = similarAlbumsResult.elementAt(index);
              final name = audio.album;
              final album = findAlbum(audio);

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
                  child: Tooltip(
                    message: audio.album == null ? '' : audio.album!,
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
                        audio.album == null ? '' : audio.album!,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: theme.colorScheme.onInverseSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                image: image,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return AlbumPage(
                        image: image,
                        name: name,
                        isPinnedAlbum: isPinnedAlbum,
                        removePinnedAlbum: removePinnedAlbum,
                        album: album,
                        addPinnedAlbum: addPinnedAlbum,
                        showWindowControls: showWindowControls,
                      );
                    },
                  ),
                ),
                onPlay: album == null || album.isEmpty || name == null
                    ? null
                    : () => startPlaylist(album, name),
              );
            },
          );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Row(
            children: [
              Text(
                '${context.l10n.albums}  •  ${similarAlbumsResult?.length ?? 0}',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w100),
              )
            ],
          ),
        ),
        const SpacedDivider(),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: albumGrid,
        )
      ],
    );
  }
}

class _Artists extends StatelessWidget {
  const _Artists({required this.showWindowControls});

  final bool showWindowControls;

  @override
  Widget build(BuildContext context) {
    final Set<Audio>? similarArtistsSearchResult =
        context.select((LocalAudioModel m) => m.similarArtistsSearchResult);
    final findArtist = context.read<LocalAudioModel>().findArtist;
    final findImages = context.read<LocalAudioModel>().findImages;

    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Row(
            children: [
              Text(
                '${context.l10n.artists}  •  ${similarArtistsSearchResult?.length ?? 0}',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w100),
              )
            ],
          ),
        ),
        const SpacedDivider(),
        if (similarArtistsSearchResult != null)
          GridView.builder(
            itemCount: similarArtistsSearchResult.length,
            padding: kGridPadding,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: kImageGridDelegate,
            itemBuilder: (context, index) {
              final artistAudios = findArtist(
                similarArtistsSearchResult.elementAt(index),
              );
              final images = findImages(artistAudios ?? {});

              var text = Text(
                similarArtistsSearchResult.elementAt(index).artist ?? 'unknown',
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
                        showWindowControls: showWindowControls,
                      );
                    },
                  ),
                ),
                borderRadius: BorderRadius.circular(300),
                child:
                    RoundImageContainer(image: images?.firstOrNull, text: text),
              );
            },
          )
      ],
    );
  }
}
