import 'package:flutter/material.dart';
import 'package:musicpod/constants.dart';
import 'package:musicpod/src/common/common_widgets.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../app.dart';
import '../../data.dart';
import '../../local_audio.dart';
import '../../player.dart';
import '../common/icons.dart';
import '../l10n/l10n.dart';
import '../library/library_model.dart';

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

class _LocalAudioPageState extends State<LocalAudioPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      context.read<LocalAudioModel>().init(
        onFail: (failedImports) {
          if (context.read<LibraryModel>().neverShowFailedImports) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 10),
              content: FailedImportsContent(
                onNeverShowFailedImports:
                    context.read<LibraryModel>().setNeverShowLocalImports,
                failedImports: failedImports,
              ),
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = context.select((LocalAudioModel m) => m.searchQuery);
    final searchActive = context.select((LocalAudioModel m) => m.searchActive);

    final model = context.read<LocalAudioModel>();
    final audios = context.select((LocalAudioModel m) => m.audios);
    final artists = model.allArtists;
    final albums = model.allAlbums;
    final setSearchQuery = model.setSearchQuery;
    final search = model.search;
    final setSearchActive = model.setSearchActive;
    final findArtist = model.findArtist;
    final findImages = model.findImages;
    final findAlbum = model.findAlbum;

    final similarArtistsSearchResult =
        context.select((LocalAudioModel m) => m.similarArtistsSearchResult);

    final similarAlbumsSearchResult =
        context.select((LocalAudioModel m) => m.similarAlbumsSearchResult);

    final libraryModel = context.read<LibraryModel>();

    final isPinnedAlbum = libraryModel.isPinnedAlbum;
    final removePinnedAlbum = libraryModel.removePinnedAlbum;
    final addPinnedAlbum = libraryModel.addPinnedAlbum;

    final playerModel = context.read<PlayerModel>();
    final startPlaylist = playerModel.startPlaylist;

    final isPlaying = context.select((PlayerModel m) => m.isPlaying);
    final currentAudio = context.select((PlayerModel m) => m.audio);
    final play = playerModel.play;
    final pause = playerModel.pause;
    final resume = playerModel.resume;

    final Set<Audio>? titlesResult =
        context.select((LocalAudioModel m) => m.titlesSearchResult);

    final showWindowControls =
        context.select((AppModel a) => a.showWindowControls);

    void onTap(text) {
      setSearchQuery(text);
      search();
      setSearchActive(true);
    }

    final tabBar = TabsBar(
      onTap: (value) {
        widget.onIndexSelected.call(value);
        setSearchActive(false);
        setSearchQuery(null);
      },
      tabs: [
        Tab(
          text: context.l10n.titles,
        ),
        Tab(
          text: context.l10n.artists,
        ),
        Tab(
          text: context.l10n.albums,
        ),
      ],
    );

    final tabBarView = TabBarView(
      children: [
        TitlesView(
          onTextTap: ({required audioType, required text}) => onTap(text),
          audios: audios,
          showWindowControls: showWindowControls,
        ),
        ArtistsView(
          showWindowControls: showWindowControls,
          artists: artists,
          onTextTap: ({required audioType, required text}) => onTap(text),
          findArtist: findArtist,
          findImages: findImages,
        ),
        AlbumsView(
          showWindowControls: showWindowControls,
          albums: albums,
          onTextTap: ({required audioType, required text}) => onTap(text),
          addPinnedAlbum: addPinnedAlbum,
          findAlbum: findAlbum,
          isPinnedAlbum: isPinnedAlbum,
          removePinnedAlbum: removePinnedAlbum,
          startPlaylist: startPlaylist,
        ),
      ],
    );

    Widget body;
    if (searchQuery?.isNotEmpty == true && searchActive) {
      body = LocalAudioSearchPage(
        similarAlbumsSearchResult: similarAlbumsSearchResult,
        showWindowControls: showWindowControls,
        searchQuery: searchQuery,
        setSearchActive: setSearchActive,
        search: search,
        setSearchQuery: setSearchQuery,
        currentAudio: currentAudio,
        titlesResult: titlesResult,
        similarArtistsSearchResult: similarArtistsSearchResult,
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
      );
    } else {
      body = tabBarView;
    }

    return DefaultTabController(
      initialIndex: widget.selectedIndex,
      length: 3,
      child: Scaffold(
        appBar: HeaderBar(
          style: showWindowControls
              ? YaruTitleBarStyle.normal
              : YaruTitleBarStyle.undecorated,
          leading: SizedBox(
            width: 120,
            child: (Navigator.of(context).canPop())
                ? const NavBackButton()
                : const SizedBox.shrink(),
          ),
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(right: 40),
            child: YaruSearchTitleField(
              searchIcon: Iconz().searchIcon,
              clearIcon: Iconz().clearIcon,
              key: ValueKey(searchQuery),
              width: kSearchBarWidth,
              searchActive: searchActive,
              title: tabBar,
              text: searchQuery,
              onSearchActive: () {
                setSearchActive(!searchActive);
                setSearchQuery('');
              },
              onSubmitted: (value) {
                setSearchActive(true);
                setSearchQuery(value);
                search();
              },
              onClear: () {
                setSearchActive(false);
                setSearchQuery('');
              },
            ),
          ),
        ),
        body: body,
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
        Iconz().play,
        color: theme.colorScheme.primary,
      );
    }
    return selected ? Icon(Iconz().localAudioFilled) : Icon(Iconz().localAudio);
  }
}
