import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/no_search_result_page.dart';
import '../../l10n/l10n.dart';
import '../../local_audio/local_audio_view.dart';
import '../../local_audio/view/local_audio_body.dart';
import '../search_model.dart';
import '../search_type.dart';

class SliverLocalSearchResult extends StatelessWidget with WatchItMixin {
  const SliverLocalSearchResult({super.key, required this.constraints});

  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    final localAudioView = watchPropertyValue(
      (SearchModel m) => switch (m.searchType) {
        SearchType.localAlbum => LocalAudioView.albums,
        SearchType.localArtist => LocalAudioView.artists,
        SearchType.localTitle => LocalAudioView.titles,
        SearchType.localGenreName => LocalAudioView.genres,
        _ => LocalAudioView.playlists,
      },
    );

    final titles = watchPropertyValue(
      (SearchModel m) => m.localSearchResult?.titles,
    );
    final artists = watchPropertyValue(
      (SearchModel m) => m.localSearchResult?.artists,
    );
    final albums = watchPropertyValue(
      (SearchModel m) => m.localSearchResult?.albums,
    );
    final genresResult = watchPropertyValue(
      (SearchModel m) => m.localSearchResult?.genres,
    );
    final playlistsResult = watchPropertyValue(
      (SearchModel m) => m.localSearchResult?.playlists,
    );

    final searchQuery = watchPropertyValue((SearchModel m) => m.searchQuery);

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
