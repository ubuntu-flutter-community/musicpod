import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_card.dart';
import 'package:musicpod/app/common/audio_filter.dart';
import 'package:musicpod/app/common/audio_tile.dart';
import 'package:musicpod/app/common/audio_tile_header.dart';
import 'package:musicpod/app/common/no_search_result_page.dart';
import 'package:musicpod/app/common/round_image_container.dart';
import 'package:musicpod/app/common/spaced_divider.dart';
import 'package:musicpod/app/local_audio/album_page.dart';
import 'package:musicpod/app/local_audio/artist_page.dart';
import 'package:musicpod/constants.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class LocalAudioSearchPage extends StatelessWidget {
  const LocalAudioSearchPage({
    super.key,
    this.showWindowControls = true,
    required this.setSearchQuery,
    required this.search,
    required this.setSearchActive,
    required this.findArtist,
    required this.findImages,
    required this.findAlbum,
    required this.startPlaylist,
    required this.isPinnedAlbum,
    required this.removePinnedAlbum,
    required this.addPinnedAlbum,
    required this.isPlaying,
    required this.play,
    required this.pause,
    required this.resume,
    this.currentAudio,
    this.similarArtistsSearchResult,
    this.titlesResult,
    this.searchQuery,
    this.similarAlbumsSearchResult,
  });

  final bool showWindowControls;
  final void Function(String?) setSearchQuery;
  final void Function() search;
  final String? searchQuery;
  final void Function(bool) setSearchActive;

  final Set<Audio>? similarArtistsSearchResult;
  final Set<Audio>? titlesResult;
  final Set<Audio>? similarAlbumsSearchResult;
  final Set<Audio>? Function(Audio, [AudioFilter]) findArtist;
  final Set<Uint8List>? Function(Set<Audio>) findImages;
  final Set<Audio>? Function(Audio, [AudioFilter]) findAlbum;
  final Future<void> Function(Set<Audio>, String) startPlaylist;
  final bool Function(String) isPinnedAlbum;
  final void Function(String) removePinnedAlbum;
  final void Function(String, Set<Audio>) addPinnedAlbum;

  final bool isPlaying;
  final Audio? currentAudio;
  final Future<void> Function({Duration? newPosition, Audio? newAudio}) play;
  final Future<void> Function() pause;
  final Future<void> Function() resume;

  @override
  Widget build(BuildContext context) {
    void onTapWithPop(text) {
      setSearchQuery(text);
      search();
      Navigator.of(context).pop();
    }

    void onTap(text) {
      setSearchQuery(text);
      search();
    }

    if ((titlesResult?.isEmpty ?? true) &&
        (similarAlbumsSearchResult?.isEmpty ?? true) &&
        (similarArtistsSearchResult?.isEmpty ?? true)) {
      return NoSearchResultPage(message: Text(context.l10n.noLocalSearchFound));
    }

    return ListView(
      shrinkWrap: true,
      children: [
        if (titlesResult?.isNotEmpty == true)
          _Titles(
            onTextTap: ({required audioType, required text}) => onTap(text),
            isPlaying: isPlaying,
            pause: pause,
            play: play,
            resume: resume,
            currentAudio: currentAudio,
            titlesResult: titlesResult!,
          ),
        if (similarAlbumsSearchResult?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _Albums(
              similarAlbumsResult: similarAlbumsSearchResult!,
              showWindowControls: showWindowControls,
              onTextTap: ({required audioType, required text}) =>
                  onTapWithPop(text),
              findAlbum: findAlbum,
              addPinnedAlbum: addPinnedAlbum,
              removePinnedAlbum: removePinnedAlbum,
              isPinnedAlbum: isPinnedAlbum,
              startPlaylist: startPlaylist,
            ),
          ),
        if (similarArtistsSearchResult?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _Artists(
              showWindowControls: showWindowControls,
              onTextTap: ({required audioType, required text}) =>
                  onTapWithPop(text),
              findArtist: findArtist,
              findImages: findImages,
              similarArtistsSearchResult: similarArtistsSearchResult!,
            ),
          ),
      ],
    );
  }
}

class _Titles extends StatelessWidget {
  const _Titles({
    this.onTextTap,
    required this.isPlaying,
    this.currentAudio,
    required this.play,
    required this.pause,
    required this.resume,
    required this.titlesResult,
  });

  final void Function({
    required String text,
    required AudioType audioType,
  })? onTextTap;

  final bool isPlaying;
  final Audio? currentAudio;
  final Future<void> Function({Duration? newPosition, Audio? newAudio}) play;
  final Future<void> Function() pause;
  final Future<void> Function() resume;
  final Set<Audio> titlesResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Row(
            children: [
              Text(
                '${context.l10n.titles}  •  ${titlesResult.length}',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w100),
              )
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 15, right: 15),
          child: AudioTileHeader(
            showTrack: false,
            audioFilter: AudioFilter.trackNumber,
          ),
        ),
        const SpacedDivider(
          top: 0,
          bottom: 0,
        ),
        if (titlesResult.isEmpty == true)
          const SizedBox.shrink()
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
                  onTextTap: onTextTap,
                  showTrack: false,
                  isPlayerPlaying: isPlaying,
                  pause: pause,
                  play: play,
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
  const _Albums({
    required this.showWindowControls,
    this.onTextTap,
    required this.findAlbum,
    required this.addPinnedAlbum,
    required this.removePinnedAlbum,
    required this.isPinnedAlbum,
    required this.startPlaylist,
    required this.similarAlbumsResult,
  });

  final bool showWindowControls;

  final void Function({
    required String text,
    required AudioType audioType,
  })? onTextTap;

  final Set<Audio>? Function(Audio, [AudioFilter]) findAlbum;
  final void Function(String, Set<Audio>) addPinnedAlbum;
  final void Function(String) removePinnedAlbum;
  final bool Function(String) isPinnedAlbum;
  final Future<void> Function(Set<Audio>, String) startPlaylist;
  final Set<Audio> similarAlbumsResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final albums = ListView.builder(
      itemExtent: kCardHeight + 10,
      cacheExtent: kCardHeight + 10,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: similarAlbumsResult.length,
      scrollDirection: Axis.horizontal,
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

        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: AudioCard(
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
                    key: ValueKey(showWindowControls == false),
                    onTextTap: onTextTap,
                    name: name,
                    isPinnedAlbum: isPinnedAlbum,
                    removePinnedAlbum: removePinnedAlbum,
                    album: album,
                    addPinnedAlbum: addPinnedAlbum,
                  );
                },
              ),
            ),
            onPlay: album == null || album.isEmpty || name == null
                ? null
                : () => startPlaylist(album, name),
          ),
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
                '${context.l10n.albums}  •  ${similarAlbumsResult.length}',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w100),
              )
            ],
          ),
        ),
        const SpacedDivider(),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: SizedBox(
            height: kCardHeight,
            child: Align(
              alignment: Alignment.centerLeft,
              child: albums,
            ),
          ),
        )
      ],
    );
  }
}

class _Artists extends StatelessWidget {
  const _Artists({
    required this.showWindowControls,
    this.onTextTap,
    required this.findImages,
    required this.findArtist,
    required this.similarArtistsSearchResult,
  });

  final bool showWindowControls;

  final void Function({
    required String text,
    required AudioType audioType,
  })? onTextTap;

  final Set<Uint8List>? Function(Set<Audio>) findImages;
  final Set<Audio>? Function(Audio, [AudioFilter]) findArtist;
  final Set<Audio> similarArtistsSearchResult;

  @override
  Widget build(BuildContext context) {
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
                '${context.l10n.artists}  •  ${similarArtistsSearchResult.length}',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w100),
              )
            ],
          ),
        ),
        const SpacedDivider(),
        SizedBox(
          height: kCardHeight + 10,
          child: Align(
            alignment: Alignment.centerLeft,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemExtent: kCardHeight,
              cacheExtent: kCardHeight,
              itemCount: similarArtistsSearchResult.length,
              padding: kGridPadding,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final artistAudios = findArtist(
                  similarArtistsSearchResult.elementAt(index),
                );
                final images = findImages(artistAudios ?? {});

                final artistName =
                    similarArtistsSearchResult.elementAt(index).artist ??
                        context.l10n.unknown;

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: YaruSelectableContainer(
                    selected: false,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return ArtistPage(
                            onTextTap: onTextTap,
                            images: images,
                            artistAudios: artistAudios,
                            showWindowControls: showWindowControls,
                          );
                        },
                      ),
                    ),
                    borderRadius: BorderRadius.circular(300),
                    child: RoundImageContainer(
                      image: images?.firstOrNull,
                      text: artistName,
                    ),
                  ),
                );
              },
            ),
          ),
        )
      ],
    );
  }
}
