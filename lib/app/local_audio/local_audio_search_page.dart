import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_card.dart';
import 'package:musicpod/app/common/audio_filter.dart';
import 'package:musicpod/app/common/audio_tile.dart';
import 'package:musicpod/app/common/audio_tile_header.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/app/common/loading_tile.dart';
import 'package:musicpod/app/common/round_image_container.dart';
import 'package:musicpod/app/common/search_field.dart';
import 'package:musicpod/app/common/spaced_divider.dart';
import 'package:musicpod/app/local_audio/album_page.dart';
import 'package:musicpod/app/local_audio/artist_page.dart';
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
    required this.setAudio,
    required this.play,
    required this.pause,
    required this.resume,
    this.currentAudio,
    this.similarArtistsSearchResult,
    this.titlesResult,
    this.searchQuery,
  });

  final bool showWindowControls;
  final void Function(String?) setSearchQuery;
  final void Function() search;
  final String? searchQuery;
  final void Function(bool) setSearchActive;

  final Set<Audio>? similarArtistsSearchResult;
  final Set<Audio>? titlesResult;
  final Set<Audio>? Function(Audio, [AudioFilter]) findArtist;
  final Set<Uint8List>? Function(Set<Audio>) findImages;
  final Set<Audio>? Function(Audio, [AudioFilter]) findAlbum;
  final Future<void> Function(Set<Audio>, String) startPlaylist;
  final bool Function(String) isPinnedAlbum;
  final void Function(String) removePinnedAlbum;
  final void Function(String, Set<Audio>) addPinnedAlbum;

  final bool isPlaying;
  final void Function(Audio?) setAudio;
  final Audio? currentAudio;
  final Future<void> Function({bool bigPlay, Audio? newAudio}) play;
  final Future<void> Function() pause;
  final Future<void> Function() resume;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    void onTapWithPop(text) {
      setSearchQuery(text);
      search();
      Navigator.of(context).pop();
    }

    void onTap(text) {
      setSearchQuery(text);
      search();
    }

    final body = ListView(
      shrinkWrap: true,
      children: [
        _Titles(
          onAlbumTap: onTap,
          onArtistTap: onTap,
          isPlaying: isPlaying,
          pause: pause,
          play: play,
          setAudio: setAudio,
          resume: resume,
          currentAudio: currentAudio,
          titlesResult: titlesResult,
        ),
        const SizedBox(
          height: 10,
        ),
        _Albums(
          showWindowControls: showWindowControls,
          onArtistTap: onTapWithPop,
          onAlbumTap: onTapWithPop,
          findAlbum: findAlbum,
          addPinnedAlbum: addPinnedAlbum,
          removePinnedAlbum: removePinnedAlbum,
          isPinnedAlbum: isPinnedAlbum,
          startPlaylist: startPlaylist,
        ),
        const SizedBox(
          height: 10,
        ),
        _Artists(
          showWindowControls: showWindowControls,
          onAlbumTap: onTapWithPop,
          onArtistTap: onTapWithPop,
          findArtist: findArtist,
          findImages: findImages,
          similarArtistsSearchResult: similarArtistsSearchResult,
        ),
      ],
    );

    return YaruDetailPage(
      backgroundColor: theme.brightness == Brightness.dark
          ? const Color.fromARGB(255, 37, 37, 37)
          : Colors.white,
      appBar: YaruWindowTitleBar(
        backgroundColor: Colors.transparent,
        style: showWindowControls
            ? YaruTitleBarStyle.normal
            : YaruTitleBarStyle.undecorated,
        titleSpacing: 0,
        title: SearchField(
          key: ValueKey(searchQuery),
          text: searchQuery,
          onSubmitted: (value) {
            setSearchQuery(value);
            search();
          },
          onSearchActive: () {
            Navigator.of(context).pop();
            setSearchActive(false);
            setSearchQuery(null);
          },
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
  const _Titles({
    this.onArtistTap,
    this.onAlbumTap,
    required this.isPlaying,
    required this.setAudio,
    this.currentAudio,
    required this.play,
    required this.pause,
    required this.resume,
    this.titlesResult,
  });

  final void Function(String artist)? onArtistTap;
  final void Function(String album)? onAlbumTap;

  final bool isPlaying;
  final void Function(Audio?) setAudio;
  final Audio? currentAudio;
  final Future<void> Function({bool bigPlay, Audio? newAudio}) play;
  final Future<void> Function() pause;
  final Future<void> Function() resume;
  final Set<Audio>? titlesResult;

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
                '${context.l10n.titles}  •  ${titlesResult?.length ?? 0}',
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
        else if (titlesResult?.isEmpty == true)
          const SizedBox.shrink()
        else
          Column(
            children: List.generate(titlesResult!.take(5).length, (index) {
              final audio = titlesResult!.take(5).elementAt(index);
              final audioSelected = currentAudio == audio;

              return Padding(
                padding: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                child: AudioTile(
                  onAlbumTap: onAlbumTap,
                  onArtistTap: onArtistTap,
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
  const _Albums({
    required this.showWindowControls,
    this.onArtistTap,
    this.onAlbumTap,
    required this.findAlbum,
    required this.addPinnedAlbum,
    required this.removePinnedAlbum,
    required this.isPinnedAlbum,
    required this.startPlaylist,
  });

  final bool showWindowControls;

  final void Function(String artist)? onArtistTap;
  final void Function(String album)? onAlbumTap;

  final Set<Audio>? Function(Audio, [AudioFilter]) findAlbum;
  final void Function(String, Set<Audio>) addPinnedAlbum;
  final void Function(String) removePinnedAlbum;
  final bool Function(String) isPinnedAlbum;
  final Future<void> Function(Set<Audio>, String) startPlaylist;

  @override
  Widget build(BuildContext context) {
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
                        onAlbumTap: onAlbumTap,
                        onArtistTap: onArtistTap,
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
  const _Artists({
    required this.showWindowControls,
    this.onArtistTap,
    this.onAlbumTap,
    required this.findImages,
    required this.findArtist,
    this.similarArtistsSearchResult,
  });

  final bool showWindowControls;

  final void Function(String artist)? onArtistTap;
  final void Function(String album)? onAlbumTap;

  final Set<Uint8List>? Function(Set<Audio>) findImages;
  final Set<Audio>? Function(Audio, [AudioFilter]) findArtist;
  final Set<Audio>? similarArtistsSearchResult;

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
            itemCount: similarArtistsSearchResult!.length,
            padding: kGridPadding,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: kImageGridDelegate,
            itemBuilder: (context, index) {
              final artistAudios = findArtist(
                similarArtistsSearchResult!.elementAt(index),
              );
              final images = findImages(artistAudios ?? {});

              final artistName =
                  similarArtistsSearchResult!.elementAt(index).artist ??
                      context.l10n.unknown;

              return YaruSelectableContainer(
                selected: false,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return ArtistPage(
                        onAlbumTap: onAlbumTap,
                        onArtistTap: onArtistTap,
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
              );
            },
          )
      ],
    );
  }
}
