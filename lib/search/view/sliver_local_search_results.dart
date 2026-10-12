import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/no_search_result_page.dart';
import '../../common/view/progress.dart';
import '../../extensions/build_context_x.dart';
import '../../local_audio/manager/local_audio_manager.dart';
import '../../local_audio/data/local_audio_view.dart';
import '../../local_audio/view/local_audio_body.dart';
import '../manager/search_manager.dart';
import '../data/search_type.dart';

class SliverLocalSearchResult extends ConsumerWidget {
  const SliverLocalSearchResult({super.key, required this.constraints});

  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initializing = ref.watch(
      localAudioManagerProvider.select((s) => s.isLoading),
    );

    if (initializing) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Progress()),
      );
    }

    return _Content(constraints: constraints);
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.constraints});

  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchType = ref.watch(
      searchManagerProvider.select((s) => s.searchType),
    );
    final localAudioView = switch (searchType) {
      SearchType.localAlbum => LocalAudioView.albums,
      SearchType.localArtist => LocalAudioView.artists,
      SearchType.localTitle => LocalAudioView.titles,
      SearchType.localGenreName => LocalAudioView.genres,
      _ => LocalAudioView.playlists,
    };

    final localSearchResult = ref.watch(
      searchManagerProvider.select((s) => s.localSearchResult),
    );
    final titles = localSearchResult?.titles;
    final artists = localSearchResult?.artists;
    final albums = localSearchResult?.albums;
    final genresResult = localSearchResult?.genres;
    final playlistsResult = localSearchResult?.playlists;

    final searchQuery = ref.watch(
      searchManagerProvider.select((s) => s.searchQuery),
    );

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
