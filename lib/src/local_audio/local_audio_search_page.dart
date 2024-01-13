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
import 'local_audio_control_panel.dart';

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
    final localAudioView =
        context.select((LocalAudioModel m) => m.localAudioView);

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

    Widget body = Column(
      children: [
        const LocalAudioControlPanel(),
        if ((titlesResult?.isEmpty ?? true) &&
            (similarAlbumsSearchResult?.isEmpty ?? true) &&
            (similarArtistsSearchResult?.isEmpty ?? true))
          Expanded(
            child: NoSearchResultPage(
              message: searchQuery == ''
                  ? Text(context.l10n.search)
                  : Text(
                      context.l10n.noLocalSearchFound,
                    ),
              icons: searchQuery == ''
                  ? const AnimatedEmoji(AnimatedEmojis.drum)
                  : null,
            ),
          )
        else
          Expanded(
            child: switch (localAudioView) {
              LocalAudioView.albums => _Albums(
                  similarAlbumsResult: similarAlbumsSearchResult!,
                  findAlbum: model.findAlbum,
                  addPinnedAlbum: addPinnedAlbum,
                  removePinnedAlbum: removePinnedAlbum,
                  isPinnedAlbum: isPinnedAlbum,
                  startPlaylist: playerModel.startPlaylist,
                ),
              LocalAudioView.titles => _Titles(
                  isPlaying: isPlaying,
                  pause: pause,
                  startPlaylist: playerModel.startPlaylist,
                  resume: resume,
                  currentAudio: currentAudio,
                  titlesResult: titlesResult!,
                ),
              LocalAudioView.artists => _Artists(
                  findArtist: model.findArtist,
                  findImages: model.findImages,
                  similarArtistsSearchResult: similarArtistsSearchResult!,
                ),
            },
          ),
      ],
    );

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
            key: ValueKey(searchQuery.toString() + localAudioView.toString()),
            text: searchQuery,
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

    return ListView(
      padding: const EdgeInsets.only(
        top: 10,
      ),
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

    final albums = GridView.builder(
      cacheExtent: kSmallCardHeight,
      itemCount: similarAlbumsResult.length,
      shrinkWrap: true,
      padding: gridPadding,
      gridDelegate: imageGridDelegate,
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
            left: 25,
            right: 25,
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
        Expanded(child: albums),
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
            left: 25,
            right: 25,
            top: 20,
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
        const SpacedDivider(
          bottom: 15,
        ),
        Expanded(
          child: GridView.builder(
            padding: gridPadding,
            shrinkWrap: true,
            gridDelegate: kDiskGridDelegate,
            itemCount: similarArtistsSearchResult.length,
            itemBuilder: (context, index) {
              final artistAudios = findArtist(
                similarArtistsSearchResult.elementAt(index),
              );
              final images = findImages(artistAudios ?? {});

              final artistName =
                  similarArtistsSearchResult.elementAt(index).artist ??
                      context.l10n.unknown;

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
                child: RoundImageContainer(
                  image: images?.firstOrNull,
                  text: artistName,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
