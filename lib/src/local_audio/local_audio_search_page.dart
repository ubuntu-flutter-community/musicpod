import 'dart:typed_data';

import 'package:animated_emoji/animated_emoji.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../app.dart';
import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../library.dart';
import '../../local_audio.dart';
import '../../player.dart';
import '../../utils.dart';
import '../l10n/l10n.dart';

class LocalAudioSearchPage extends StatelessWidget {
  const LocalAudioSearchPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final showWindowControls =
        context.select((AppModel m) => m.showWindowControls);

    final model = context.read<LocalAudioModel>();
    final libraryModel = context.read<LibraryModel>();

    final similarArtistsSearchResult =
        context.select((LocalAudioModel m) => m.similarArtistsSearchResult);

    final similarAlbumsSearchResult =
        context.select((LocalAudioModel m) => m.similarAlbumsSearchResult);

    final playerModel = context.read<PlayerModel>();
    final isPlaying = context.select((PlayerModel m) => m.isPlaying);
    final currentAudio = context.select((PlayerModel m) => m.audio);
    final pause = playerModel.pause;
    final resume = playerModel.resume;
    final searchQuery = context.select((LocalAudioModel m) => m.searchQuery);

    final Set<Audio>? titlesResult =
        context.select((LocalAudioModel m) => m.titlesSearchResult);

    void search({required String? text}) {
      if (text != null) {
        model.search(text);
      } else {
        Navigator.of(context).maybePop();
      }
    }

    final isPinnedAlbum = libraryModel.isPinnedAlbum;
    final removePinnedAlbum = libraryModel.removePinnedAlbum;
    final addPinnedAlbum = libraryModel.addPinnedAlbum;

    Widget body;
    if ((titlesResult?.isEmpty ?? true) &&
        (similarAlbumsSearchResult?.isEmpty ?? true) &&
        (similarArtistsSearchResult?.isEmpty ?? true)) {
      body = NoSearchResultPage(
        message: searchQuery == ''
            ? Text(context.l10n.search)
            : Text(
                context.l10n.noLocalSearchFound,
              ),
        icons:
            searchQuery == '' ? const AnimatedEmoji(AnimatedEmojis.drum) : null,
      );
    } else {
      body = ListView(
        shrinkWrap: true,
        children: [
          if (titlesResult?.isNotEmpty == true)
            _Titles(
              isPlaying: isPlaying,
              pause: pause,
              startPlaylist: playerModel.startPlaylist,
              resume: resume,
              currentAudio: currentAudio,
              titlesResult: titlesResult!,
            ),
          if (similarAlbumsSearchResult?.isNotEmpty == true)
            _Albums(
              similarAlbumsResult: similarAlbumsSearchResult!,
              findAlbum: model.findAlbum,
              addPinnedAlbum: addPinnedAlbum,
              removePinnedAlbum: removePinnedAlbum,
              isPinnedAlbum: isPinnedAlbum,
              startPlaylist: playerModel.startPlaylist,
            ),
          if (similarArtistsSearchResult?.isNotEmpty == true)
            _Artists(
              findArtist: model.findArtist,
              findImages: model.findImages,
              similarArtistsSearchResult: similarArtistsSearchResult!,
            ),
        ],
      );
    }

    return Scaffold(
      appBar: HeaderBar(
        style: showWindowControls
            ? YaruTitleBarStyle.normal
            : YaruTitleBarStyle.undecorated,
        leading: (Navigator.of(context).canPop())
            ? const NavBackButton()
            : const SizedBox.shrink(),
        titleSpacing: 0,
        actions: [
          Flexible(
            child: Padding(
              padding: appBarActionSpacing,
              child: SearchButton(
                active: true,
                onPressed: () => search(text: null),
              ),
            ),
          ),
        ],
        title: SizedBox(
          width: kSearchBarWidth,
          child: SearchingBar(
            key: ValueKey(model.searchQuery),
            text: model.searchQuery,
            onSubmitted: (value) => search(text: value),
            onClear: () => search(text: ''),
          ),
        ),
      ),
      body: body,
    );
  }
}

class _Titles extends StatelessWidget {
  const _Titles({
    required this.isPlaying,
    this.currentAudio,
    required this.startPlaylist,
    required this.pause,
    required this.resume,
    required this.titlesResult,
  });

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
    final model = context.read<LocalAudioModel>();
    final libraryModel = context.read<LibraryModel>();

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
                onAlbumTap: ({required audioType, required text}) {
                  final albumAudios = model.findAlbum(Audio(album: text));
                  if (albumAudios?.firstOrNull == null) return;
                  final id = generateAlbumId(albumAudios!.first);
                  if (id == null) return;

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) {
                        return AlbumPage(
                          isPinnedAlbum: libraryModel.isPinnedAlbum,
                          removePinnedAlbum: libraryModel.removePinnedAlbum,
                          addPinnedAlbum: libraryModel.addPinnedAlbum,
                          id: id,
                          album: albumAudios,
                        );
                      },
                    ),
                  );
                },
                onArtistTap: ({required audioType, required text}) {
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
                showTrack: false,
                isPlayerPlaying: isPlaying,
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
    required this.findAlbum,
    required this.addPinnedAlbum,
    required this.removePinnedAlbum,
    required this.isPinnedAlbum,
    required this.startPlaylist,
    required this.similarAlbumsResult,
  });

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
    required this.findImages,
    required this.findArtist,
    required this.similarArtistsSearchResult,
  });

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
                            images: images,
                            artistAudios: artistAudios,
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
