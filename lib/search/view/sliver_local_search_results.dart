import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/no_search_result_page.dart';
import '../../common/view/progress.dart';
import '../../extensions/build_context_x.dart';
import '../../local_audio/local_audio_manager.dart';
import '../../local_audio/local_audio_view.dart';
import '../../local_audio/view/local_audio_body.dart';
import '../search_manager.dart';
import '../search_type.dart';

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

    final localAudioView = watchValue(
      (SearchManager m) => m.searchType.select(
        (audioType) => switch (audioType) {
          SearchType.localAlbum => LocalAudioView.albums,
          SearchType.localArtist => LocalAudioView.artists,
          SearchType.localTitle => LocalAudioView.titles,
          SearchType.localGenreName => LocalAudioView.genres,
          _ => LocalAudioView.playlists,
        },
      ),
    );

    final titles = watchValue(
      (SearchManager m) => m.localSearchResult.select((v) => v?.titles),
    );
    final artists = watchValue(
      (SearchManager m) => m.localSearchResult.select((v) => v?.artists),
    );
    final albums = watchValue(
      (SearchManager m) => m.localSearchResult.select((v) => v?.albums),
    );
    final genresResult = watchValue(
      (SearchManager m) => m.localSearchResult.select((v) => v?.genres),
    );
    final playlistsResult = watchValue(
      (SearchManager m) => m.localSearchResult.select((v) => v?.playlists),
    );

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
    );
  }
}
