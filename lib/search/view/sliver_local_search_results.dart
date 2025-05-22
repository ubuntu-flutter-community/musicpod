import 'package:animated_emoji/emoji.dart';
import 'package:animated_emoji/emojis.g.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/no_search_result_page.dart';
import '../../l10n/l10n.dart';
import '../../local_audio/local_audio_model.dart';
import '../../local_audio/view/failed_import_snackbar.dart';
import '../../local_audio/view/local_audio_body.dart';
import '../../local_audio/local_audio_view.dart';
import '../search_model.dart';
import '../search_type.dart';

class SliverLocalSearchResult extends StatefulWidget
    with WatchItStatefulWidgetMixin {
  const SliverLocalSearchResult({super.key});

  @override
  State<SliverLocalSearchResult> createState() =>
      _SliverLocalSearchResultState();
}

class _SliverLocalSearchResultState extends State<SliverLocalSearchResult> {
  @override
  void initState() {
    super.initState();
    final failedImports = di<LocalAudioModel>().failedImports;
    if (mounted && failedImports?.isNotEmpty == true) {
      showFailedImportsSnackBar(
        failedImports: failedImports!,
        context: context,
      );
    }
  }

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
      return SliverNoSearchResultPage(
        icon: const AnimatedEmoji(AnimatedEmojis.drum),
        message: Text(context.l10n.search),
      );
    }

    return LocalAudioBody(
      localAudioView: localAudioView,
      titles: titles,
      artists: artists,
      albumIDs: albums,
      genres: genresResult,
      playlists: playlistsResult,
    );
  }
}
