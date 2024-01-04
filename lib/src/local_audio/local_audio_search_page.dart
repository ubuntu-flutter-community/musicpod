import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../local_audio.dart';
import '../../utils.dart';
import '../l10n/l10n.dart';

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
  final Future<void> Function({
    required Set<Audio> audios,
    required String listName,
    int? index,
  }) startPlaylist;
  final bool Function(String) isPinnedAlbum;
  final void Function(String) removePinnedAlbum;
  final void Function(String, Set<Audio>) addPinnedAlbum;

  final bool isPlaying;
  final Audio? currentAudio;
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
            startPlaylist: startPlaylist,
            resume: resume,
            currentAudio: currentAudio,
            titlesResult: titlesResult!,
          ),
        if (similarAlbumsSearchResult?.isNotEmpty == true)
          _Albums(
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
        if (similarArtistsSearchResult?.isNotEmpty == true)
          _Artists(
            showWindowControls: showWindowControls,
            onTextTap: ({required audioType, required text}) =>
                onTapWithPop(text),
            findArtist: findArtist,
            findImages: findImages,
            similarArtistsSearchResult: similarArtistsSearchResult!,
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
    required this.startPlaylist,
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
  final Future<void> Function({
    required Set<Audio> audios,
    required String listName,
    int? index,
  }) startPlaylist;
  final Future<void> Function() pause;
  final Future<void> Function() resume;
  final Set<Audio> titlesResult;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;

    return Column(
      children: [
        AudioTileHeader(
          textStyle: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w100),
          showTrack: false,
          audioFilter: AudioFilter.trackNumber,
          titleLabel: '${context.l10n.titles}  •  ${titlesResult.length}',
        ),
        const SpacedDivider(
          top: 0,
          bottom: 0,
        ),
        if (titlesResult.isEmpty == true)
          const SizedBox.shrink()
        else
          Column(
            children: List.generate(titlesResult.length, (index) {
              final audio = titlesResult.elementAt(index);
              final audioSelected = currentAudio == audio;

              return AudioTile(
                onTextTap: onTextTap,
                showTrack: false,
                pause: pause,
                startPlaylist: () => startPlaylist(
                  audios: titlesResult,
                  listName: '$kSearchResult${DateTime.now().toString()}',
                  index: index,
                ),
                resume: resume,
                key: ValueKey(audio),
                selected: audioSelected,
                audio: audio,
                likeIcon: const SizedBox(width: 65),
              );
            }),
          ),
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
  final Future<void> Function({
    required Set<Audio> audios,
    required String listName,
    int? index,
  }) startPlaylist;
  final Set<Audio> similarAlbumsResult;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;

    final albums = ListView.separated(
      cacheExtent: kSmallCardHeight,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: similarAlbumsResult.length,
      scrollDirection: Axis.horizontal,
      separatorBuilder: (context, index) => const SizedBox(
        width: 10,
      ),
      itemBuilder: (context, index) {
        final audio = similarAlbumsResult.elementAt(index);
        final id = generateAlbumId(audio);
        final albumAudio = findAlbum(audio);

        final image = audio.pictureData == null
            ? Center(
                child: Icon(
                  Iconz().musicNote,
                  size: 140,
                  color: theme.hintColor,
                ),
              )
            : Image.memory(
                audio.pictureData!,
                fit: BoxFit.cover,
                height: kSmallCardHeight,
                width: kSmallCardHeight,
                filterQuality: FilterQuality.medium,
              );

        return AudioCard(
          height: kSmallCardHeight,
          width: kSmallCardHeight,
          bottom: AudioCardBottom(
            text: audio.album == null ? '' : audio.album!,
            maxLines: 1,
          ),
          image: image,
          onTap: id == null
              ? null
              : () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return AlbumPage(
                          key: ValueKey(showWindowControls == false),
                          onTextTap: onTextTap,
                          id: id,
                          isPinnedAlbum: isPinnedAlbum,
                          removePinnedAlbum: removePinnedAlbum,
                          album: albumAudio,
                          addPinnedAlbum: addPinnedAlbum,
                        );
                      },
                    ),
                  ),
          onPlay: albumAudio == null || albumAudio.isEmpty || id == null
              ? null
              : () => startPlaylist(audios: albumAudio, listName: id),
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
              ),
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
        ),
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
    final theme = context.t;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          child: Row(
            children: [
              Text(
                '${context.l10n.artists}  •  ${similarArtistsSearchResult.length}',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w100),
              ),
            ],
          ),
        ),
        const SpacedDivider(),
        SizedBox(
          height: kSmallCardHeight + 20,
          child: Align(
            alignment: Alignment.centerLeft,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemExtent: kSmallCardHeight + 10,
              cacheExtent: kSmallCardHeight + 10,
              itemCount: similarArtistsSearchResult.length,
              padding: gridPadding,
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
        ),
      ],
    );
  }
}
