import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:radio_browser_api/radio_browser_api.dart' hide State;

import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../search/manager/search_manager.dart';
import '../../search/data/search_type.dart';
import '../manager/album_ids_of_genre_manager.dart';
import 'album_view.dart';

class GenrePage extends StatelessWidget with WatchItMixin {
  const GenrePage({required this.genre, super.key});

  final String genre;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: HeaderBar(
      titleSpacing: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: context.l10n.searchForRadioStationsWithGenreName,
            onPressed: () {
              di<RoutingManager>().push(pageId: PageIDs.searchPage);
              di<SearchManager>()
                ..setTag(Tag(name: genre.toLowerCase(), stationCount: 1))
                ..setAudioType(AudioType.radio)
                ..setSearchType(SearchType.radioTag)
                ..search();
            },
            icon: Icon(Iconz.radio),
          ),
          const SizedBox(width: 5),
          Text(genre),
        ],
      ),
    ),
    body: CustomScrollView(
      slivers: [
        SliverPadding(
          padding: kGridPadding.copyWith(bottom: bottomPlayerPageGap),
          sliver: AlbumsView(
            albumIDs:
                watchValue(
                  (AlbumIDsOfGenreManager m) => m.command,
                  param1: genre,
                ) ??
                [],
          ),
        ),
      ],
    ),
  );
}
