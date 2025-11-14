import 'package:flutter/material.dart';
import 'package:radio_browser_api/radio_browser_api.dart' hide State;
import 'package:flutter_it/flutter_it.dart';

import '../../app/view/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/page_ids.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../l10n/l10n.dart';
import '../../search/search_model.dart';
import '../../search/search_type.dart';
import '../local_audio_model.dart';
import 'album_view.dart';

class GenrePage extends StatefulWidget {
  const GenrePage({required this.genre, super.key});

  final String genre;

  @override
  State<GenrePage> createState() => _GenrePageState();
}

class _GenrePageState extends State<GenrePage> {
  late Future<List<String>?> _albumIDsOfGenre;

  @override
  void initState() {
    super.initState();
    _albumIDsOfGenre = di<LocalAudioModel>().findAlbumsIDOfGenre(widget.genre);
  }

  @override
  Widget build(BuildContext context) {
    final cachedAlbumIDsOfGenre = di<LocalAudioModel>()
        .getCachedAlbumIDsOfGenre(widget.genre);

    return Scaffold(
      appBar: HeaderBar(
        adaptive: true,
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: context.l10n.searchForRadioStationsWithGenreName,
              onPressed: () {
                di<RoutingManager>().push(pageId: PageIDs.searchPage);
                di<SearchModel>()
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: getAdaptiveHorizontalPadding(
                  constraints: constraints,
                ).copyWith(bottom: bottomPlayerPageGap),
                sliver: cachedAlbumIDsOfGenre != null
                    ? AlbumsView(albumIDs: cachedAlbumIDsOfGenre)
                    : FutureBuilder(
                        future: _albumIDsOfGenre,
                        builder: (context, snapshot) =>
                            AlbumsView(albumIDs: snapshot.data),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
