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
import '../../search/search_manager.dart';
import '../../search/search_type.dart';
import '../local_audio_manager.dart';
import 'album_view.dart';

class GenrePage extends StatefulWidget {
  const GenrePage({required this.genre, super.key});

  final String genre;

  @override
  State<GenrePage> createState() => _GenrePageState();
}

class _GenrePageState extends State<GenrePage> {
  late Future<List<int>?> _albumIDsOfGenre;

  @override
  void initState() {
    super.initState();
    _albumIDsOfGenre = di<LocalAudioManager>().findAlbumsIDOfGenre(
      widget.genre,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cachedAlbumIDsOfGenre = di<LocalAudioManager>()
        .getCachedAlbumIDsOfGenre(widget.genre);

    return Scaffold(
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
                  ..setTag(
                    Tag(name: widget.genre.toLowerCase(), stationCount: 1),
                  )
                  ..setAudioType(AudioType.radio)
                  ..setSearchType(SearchType.radioTag)
                  ..search();
              },
              icon: Icon(Iconz.radio),
            ),
            const SizedBox(width: 5),
            Text(widget.genre),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: kGridPadding.copyWith(bottom: bottomPlayerPageGap),
            sliver: cachedAlbumIDsOfGenre != null
                ? AlbumsView(albumIDs: cachedAlbumIDsOfGenre)
                : FutureBuilder(
                    future: _albumIDsOfGenre,
                    builder: (context, snapshot) =>
                        AlbumsView(albumIDs: snapshot.data),
                  ),
          ),
        ],
      ),
    );
  }
}
