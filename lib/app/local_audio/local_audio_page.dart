import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:musicpod/app/app_model.dart';
import 'package:musicpod/app/common/audio_filter.dart';
import 'package:musicpod/app/common/search_button.dart';
import 'package:musicpod/app/common/search_field.dart';
import 'package:musicpod/app/library_model.dart';
import 'package:musicpod/app/local_audio/album_view.dart';
import 'package:musicpod/app/local_audio/artists_view.dart';
import 'package:musicpod/app/local_audio/failed_imports_content.dart';
import 'package:musicpod/app/local_audio/local_audio_model.dart';
import 'package:musicpod/app/local_audio/local_audio_search_page.dart';
import 'package:musicpod/app/local_audio/titles_view.dart';
import 'package:musicpod/app/player/player_model.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class LocalAudioPage extends StatefulWidget {
  const LocalAudioPage({
    super.key,
    required this.selectedIndex,
    required this.onIndexSelected,
  });

  final int selectedIndex;
  final void Function(int index) onIndexSelected;

  @override
  State<LocalAudioPage> createState() => _LocalAudioPageState();
}

class _LocalAudioPageState extends State<LocalAudioPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      context.read<LocalAudioModel>().init(
            onFail: (failedImports) =>
                ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 10),
                content: FailedImportsContent(
                  failedImports: failedImports,
                ),
              ),
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = context.select((LocalAudioModel m) => m.searchQuery);
    final searchActive = context.select((LocalAudioModel m) => m.searchActive);

    final model = context.read<LocalAudioModel>();
    final audios = context.select((LocalAudioModel m) => m.audios);
    final artists = model.findAllArtists();
    final albums = model.findAllAlbums();
    final setSearchQuery = model.setSearchQuery;
    final search = model.search;
    final setSearchActive = model.setSearchActive;
    final findArtist = model.findArtist;
    final findImages = model.findImages;
    final findAlbum = model.findAlbum;

    final Set<Audio>? similarArtistsSearchResult =
        context.select((LocalAudioModel m) => m.similarArtistsSearchResult);

    final libraryModel = context.read<LibraryModel>();

    final isPinnedAlbum = libraryModel.isPinnedAlbum;
    final removePinnedAlbum = libraryModel.removePinnedAlbum;
    final addPinnedAlbum = libraryModel.addPinnedAlbum;

    final playerModel = context.read<PlayerModel>();
    final startPlaylist = playerModel.startPlaylist;

    final isPlaying = context.select((PlayerModel m) => m.isPlaying);
    final setAudio = playerModel.setAudio;
    final currentAudio = context.select((PlayerModel m) => m.audio);
    final play = playerModel.play;
    final pause = playerModel.pause;
    final resume = playerModel.resume;

    final Set<Audio>? titlesResult =
        context.select((LocalAudioModel m) => m.titlesSearchResult);

    final showWindowControls =
        context.select((AppModel a) => a.showWindowControls);

    return Navigator(
      onPopPage: (route, result) => route.didPop(result),
      pages: [
        MaterialPage(
          child: StartPage(
            showWindowControls: showWindowControls,
            selectedIndex: widget.selectedIndex,
            onIndexSelected: widget.onIndexSelected,
            audios: audios,
            artists: artists,
            albums: albums,
            addPinnedAlbum: addPinnedAlbum,
            removePinnedAlbum: removePinnedAlbum,
            findArtist: findArtist,
            findAlbum: findAlbum,
            findImages: findImages,
            isPinnedAlbum: isPinnedAlbum,
            search: search,
            searchActive: searchActive,
            setSearchActive: setSearchActive,
            setSearchQuery: setSearchQuery,
            startPlaylist: startPlaylist,
          ),
        ),
        if (searchQuery?.isNotEmpty == true && searchActive)
          MaterialPage(
            child: LocalAudioSearchPage(
              showWindowControls: showWindowControls,
              searchQuery: searchQuery,
              setSearchActive: setSearchActive,
              search: search,
              setSearchQuery: setSearchQuery,
              currentAudio: currentAudio,
              titlesResult: titlesResult,
              similarArtistsSearchResult: similarArtistsSearchResult,
              setAudio: setAudio,
              addPinnedAlbum: addPinnedAlbum,
              findAlbum: findAlbum,
              findArtist: findArtist,
              findImages: findImages,
              isPinnedAlbum: isPinnedAlbum,
              isPlaying: isPlaying,
              pause: pause,
              play: play,
              resume: resume,
              removePinnedAlbum: removePinnedAlbum,
              startPlaylist: startPlaylist,
            ),
          )
      ],
    );
  }
}

class StartPage extends StatelessWidget {
  const StartPage({
    super.key,
    required this.showWindowControls,
    required this.selectedIndex,
    this.onIndexSelected,
    this.audios,
    required this.artists,
    required this.albums,
    required this.setSearchQuery,
    this.searchQuery,
    required this.search,
    required this.searchActive,
    required this.setSearchActive,
    required this.findArtist,
    required this.findImages,
    required this.startPlaylist,
    required this.isPinnedAlbum,
    required this.removePinnedAlbum,
    required this.addPinnedAlbum,
    required this.findAlbum,
  });

  final bool showWindowControls;
  final int selectedIndex;
  final void Function(int index)? onIndexSelected;
  final Set<Audio>? audios;
  final Set<Audio> artists;
  final Set<Audio> albums;
  final void Function(String?) setSearchQuery;
  final String? searchQuery;
  final void Function() search;
  final bool searchActive;
  final void Function(bool) setSearchActive;
  final Set<Audio>? Function(Audio, [AudioFilter]) findArtist;
  final Set<Audio>? Function(Audio, [AudioFilter]) findAlbum;
  final Set<Uint8List>? Function(Set<Audio>) findImages;
  final Future<void> Function(Set<Audio>, String) startPlaylist;
  final bool Function(String) isPinnedAlbum;
  final void Function(String) removePinnedAlbum;
  final void Function(String, Set<Audio>) addPinnedAlbum;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    void onTap(text) {
      setSearchQuery(text);
      search();
      setSearchActive(true);
    }

    return DefaultTabController(
      initialIndex: selectedIndex,
      length: 3,
      child: Scaffold(
        backgroundColor: theme.brightness == Brightness.dark
            ? const Color.fromARGB(255, 37, 37, 37)
            : Colors.white,
        appBar: YaruWindowTitleBar(
          backgroundColor: Colors.transparent,
          style: showWindowControls
              ? YaruTitleBarStyle.normal
              : YaruTitleBarStyle.undecorated,
          leading: SearchButton(
            searchActive: searchActive,
            setSearchActive: setSearchActive,
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              if (searchActive)
                Expanded(
                  child: SearchField(
                    key: ValueKey(searchQuery),
                    onSubmitted: (value) {
                      setSearchQuery(value);
                      search();
                    },
                    onClear: () {
                      setSearchActive(false);
                    },
                  ),
                )
              else
                Expanded(
                  child: TabBar(
                    labelStyle: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                    // indicatorColor: Colors.transparent,
                    dividerColor: Colors.transparent,

                    onTap: (value) {
                      onIndexSelected?.call(value);
                      setSearchActive(false);
                      setSearchQuery(null);
                    },
                    tabs: [
                      Tab(
                        child: Text(context.l10n.titles),
                      ),
                      Tab(
                        child: Text(context.l10n.artists),
                      ),
                      Tab(
                        child: Text(context.l10n.albums),
                      ),
                    ],
                  ),
                )
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TitlesView(
              onArtistTap: onTap,
              onAlbumTap: onTap,
              audios: audios,
              showWindowControls: showWindowControls,
            ),
            ArtistsView(
              showWindowControls: showWindowControls,
              similarArtistsSearchResult: artists,
              onArtistTap: onTap,
              onAlbumTap: onTap,
              findArtist: findArtist,
              findImages: findImages,
            ),
            AlbumsView(
              showWindowControls: showWindowControls,
              albums: albums,
              onArtistTap: onTap,
              onAlbumTap: onTap,
              addPinnedAlbum: addPinnedAlbum,
              findAlbum: findAlbum,
              isPinnedAlbum: isPinnedAlbum,
              removePinnedAlbum: removePinnedAlbum,
              startPlaylist: startPlaylist,
            ),
          ],
        ),
      ),
    );
  }
}

class LocalAudioPageIcon extends StatelessWidget {
  const LocalAudioPageIcon({
    super.key,
    required this.selected,
    required this.isPlaying,
  });

  final bool selected;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isPlaying) {
      return Icon(
        YaruIcons.media_play,
        color: theme.primaryColor,
      );
    }
    return Stack(
      children: [
        selected
            ? const Icon(YaruIcons.drive_harddisk_filled)
            : const Icon(YaruIcons.drive_harddisk),
        Positioned(
          left: 5,
          top: 1,
          child: Icon(
            YaruIcons.music_note,
            size: 10,
            color: selected
                ? theme.colorScheme.surface
                : theme.colorScheme.onSurface,
          ),
        )
      ],
    );
  }
}
