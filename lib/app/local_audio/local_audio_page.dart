import 'package:flutter/material.dart';
import 'package:musicpod/app/common/search_field.dart';
import 'package:musicpod/app/common/tabbed_page.dart';
import 'package:musicpod/app/local_audio/album_view.dart';
import 'package:musicpod/app/local_audio/artists_view.dart';
import 'package:musicpod/app/local_audio/failed_imports_content.dart';
import 'package:musicpod/app/local_audio/local_audio_model.dart';
import 'package:musicpod/app/local_audio/local_audio_search_page.dart';
import 'package:musicpod/app/local_audio/titles_view.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class LocalAudioPage extends StatefulWidget {
  const LocalAudioPage({super.key, this.showWindowControls = true});

  final bool showWindowControls;

  @override
  State<LocalAudioPage> createState() => _LocalAudioPageState();
}

class _LocalAudioPageState extends State<LocalAudioPage> {
  int _selectedIndex = 0;

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

    return Navigator(
      onPopPage: (route, result) => route.didPop(result),
      pages: [
        MaterialPage(
          child: StartPage(
            showWindowControls: widget.showWindowControls,
            selectedIndex: _selectedIndex,
            onIndexSelected: (index) => setState(() {
              _selectedIndex = index;
            }),
          ),
        ),
        if (searchQuery?.isNotEmpty == true)
          MaterialPage(
            child: LocalAudioSearchPage(
              showWindowControls: widget.showWindowControls,
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
  });

  final bool showWindowControls;
  final int selectedIndex;
  final void Function(int index)? onIndexSelected;

  @override
  Widget build(BuildContext context) {
    final audios = context.read<LocalAudioModel>().audios;
    final artists = context.read<LocalAudioModel>().findAllArtists();
    final albums = context.read<LocalAudioModel>().findAllAlbums();
    final searchQuery = context.select((LocalAudioModel m) => m.searchQuery);
    final setSearchQuery = context.read<LocalAudioModel>().setSearchQuery;
    final search = context.read<LocalAudioModel>().search;

    final theme = Theme.of(context);

    void onTap(text) {
      setSearchQuery(text);
      search();
    }

    return YaruDetailPage(
      backgroundColor: theme.brightness == Brightness.dark
          ? const Color.fromARGB(255, 37, 37, 37)
          : Colors.white,
      appBar: YaruWindowTitleBar(
        style: showWindowControls
            ? YaruTitleBarStyle.normal
            : YaruTitleBarStyle.undecorated,
        title: SearchField(
          key: ValueKey(searchQuery),
          onSubmitted: (value) {
            setSearchQuery(value);
            search();
          },
        ),
      ),
      body: TabbedPage(
        initialIndex: selectedIndex,
        onTap: onIndexSelected,
        tabTitles: [
          context.l10n.titles,
          context.l10n.artists,
          context.l10n.albums,
        ],
        views: [
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
          ),
          AlbumsView(
            showWindowControls: showWindowControls,
            albums: albums,
            onArtistTap: onTap,
            onAlbumTap: onTap,
          ),
        ],
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
