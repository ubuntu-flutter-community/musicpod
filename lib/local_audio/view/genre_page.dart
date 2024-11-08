import 'package:flutter/material.dart';
import 'package:radio_browser_api/radio_browser_api.dart' hide State;
import 'package:watch_it/watch_it.dart';
import 'package:yaru/theme.dart';

import '../../common/data/audio.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/icons.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../search/search_model.dart';
import '../../search/search_type.dart';
import '../local_audio_model.dart';
import 'artists_view.dart';

class GenrePage extends StatefulWidget {
  const GenrePage({required this.genre, super.key});

  final String genre;

  @override
  State<GenrePage> createState() => _GenrePageState();
}

class _GenrePageState extends State<GenrePage> {
  List<String>? artistAudiosWithGenre;

  @override
  void initState() {
    super.initState();
    final model = di<LocalAudioModel>();
    model.init().then(
      (_) {
        if (context.mounted) {
          setState(
            () =>
                artistAudiosWithGenre = model.findArtistsOfGenre(widget.genre),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: isMobile ? false : null,
      appBar: HeaderBar(
        adaptive: true,
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: context.l10n.searchForRadioStationsWithGenreName,
              onPressed: () {
                di<LibraryModel>().push(pageId: kSearchPageId);
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
            const SizedBox(
              width: 5,
            ),
            Text(widget.genre),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: getAdaptiveHorizontalPadding(constraints: constraints),
                sliver: ArtistsView(
                  artists: artistAudiosWithGenre,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
