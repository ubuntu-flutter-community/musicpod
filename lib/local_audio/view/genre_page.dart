import 'package:flutter/material.dart';
import 'package:radio_browser_api/radio_browser_api.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/theme.dart';

import '../../common/data/audio.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/icons.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../radio/radio_model.dart';
import '../../search/search_model.dart';
import '../../search/search_type.dart';
import '../local_audio_model.dart';
import 'artists_view.dart';

class GenrePage extends StatelessWidget {
  const GenrePage({required this.genre, super.key});

  final String genre;

  @override
  Widget build(BuildContext context) {
    final model = di<LocalAudioModel>();
    final radioModel = di<RadioModel>();

    final artistAudiosWithGenre = model.findArtistsOfGenre(genre);

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
              onPressed: () => radioModel.init().then((value) {
                di<LibraryModel>().pushNamed(pageId: kSearchPageId);
                di<SearchModel>()
                  ..setTag(Tag(name: genre.toLowerCase(), stationCount: 1))
                  ..setAudioType(AudioType.radio)
                  ..setSearchType(SearchType.radioTag)
                  ..search();
              }),
              icon: Icon(Iconz().radio),
            ),
            const SizedBox(
              width: 5,
            ),
            Text(genre),
          ],
        ),
      ),
      body: ArtistsView(
        artists: artistAudiosWithGenre,
      ),
    );
  }
}
