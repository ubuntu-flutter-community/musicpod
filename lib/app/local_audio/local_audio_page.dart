import 'package:flutter/material.dart';
import 'package:musicpod/app/local_audio/artists_view.dart';
import 'package:musicpod/app/local_audio/local_audio_model.dart';
import 'package:musicpod/app/local_audio/local_audio_search_field.dart';
import 'package:musicpod/app/local_audio/local_audio_search_page.dart';
import 'package:musicpod/app/local_audio/titles_view.dart';
import 'package:musicpod/app/tabbed_page.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class LocalAudioPage extends StatelessWidget {
  const LocalAudioPage({super.key, this.showWindowControls = true});

  final bool showWindowControls;

  @override
  Widget build(BuildContext context) {
    final searchQuery = context.select((LocalAudioModel m) => m.searchQuery);

    return Navigator(
      onPopPage: (route, result) => route.didPop(result),
      pages: [
        MaterialPage(
          child: StartPage(showWindowControls: showWindowControls),
        ),
        if (searchQuery?.isNotEmpty == true)
          MaterialPage(
            child: LocalAudioSearchPage(
              showWindowControls: showWindowControls,
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
  });

  final bool showWindowControls;

  @override
  Widget build(BuildContext context) {
    final audios = context.read<LocalAudioModel>().audios;
    final artists = context.read<LocalAudioModel>().findAllArtists();
    final theme = Theme.of(context);
    return YaruDetailPage(
      backgroundColor: theme.brightness == Brightness.dark
          ? const Color.fromARGB(255, 37, 37, 37)
          : Colors.white,
      appBar: YaruWindowTitleBar(
        style: showWindowControls
            ? YaruTitleBarStyle.normal
            : YaruTitleBarStyle.undecorated,
        title: const LocalAudioSearchField(),
      ),
      body: TabbedPage(
        tabTitles: [
          context.l10n.titles,
          context.l10n.artists,
          context.l10n.albums,
          context.l10n.genres,
        ],
        views: [
          TitlesView(audios: audios, showWindowControls: showWindowControls),
          ArtistsView(
            showWindowControls: showWindowControls,
            similarArtistsSearchResult: artists,
          ),
          Center(
            child: Text(context.l10n.albums),
          ),
          Center(
            child: Text(context.l10n.genres),
          )
        ],
      ),
    );
  }
}
