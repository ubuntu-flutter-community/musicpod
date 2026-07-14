import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/no_search_result_page.dart';
import '../../common/view/progress.dart';
import '../../extensions/build_context_x.dart';
import '../../local_audio/manager/local_audio_manager.dart';
import '../../local_audio/data/local_audio_view.dart';
import '../../local_audio/view/local_audio_body.dart';
import '../manager/search_manager.dart';
import '../data/search_type.dart';

class SliverLocalSearchResult extends StatelessWidget with WatchItMixin {
  const SliverLocalSearchResult({super.key, required this.constraints});

  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    final initialiazing = watchValue(
      (LocalAudioManager m) => m.initAudiosCommand.isRunning,
    );

    if (initialiazing) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Progress()),
      );
    }

    final searchType = watchValue((SearchManager m) => m.searchType);
    final localAudioView = switch (searchType) {
      SearchType.localAlbum => LocalAudioView.albums,
      SearchType.localArtist => LocalAudioView.artists,
      SearchType.localTitle => LocalAudioView.titles,
      SearchType.localGenreName => LocalAudioView.genres,
      _ => LocalAudioView.playlists,
    };

    final localSearchResult = watchValue(
      (SearchManager m) => m.localSearchResult,
    );
    final titles = localSearchResult?.titles;
    final artists = localSearchResult?.artists;
    final albums = localSearchResult?.albums;
    final genresResult = localSearchResult?.genres;
    final playlistsResult = localSearchResult?.playlists;

    final searchQuery = watchValue((SearchManager m) => m.searchQuery);

    if (searchQuery == null || searchQuery.isEmpty == true) {
      return SliverNoSearchResultPage(message: Text(context.l10n.search));
    }

    return LocalAudioBody(
      localAudioView: localAudioView,
      titles: titles,
      artists: artists,
      albumIDs: albums,
      genres: genresResult,
      playlists: playlistsResult,
      constraints: constraints,
      startNewPlaylistOnTap: false,
    );
  }
}
