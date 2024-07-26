import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/icons.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../radio/radio_model.dart';
import '../../radio/view/radio_search.dart';
import '../../radio/view/radio_search_page.dart';
import '../local_audio_model.dart';
import 'artists_view.dart';

class GenrePage extends StatelessWidget {
  const GenrePage({required this.genre, super.key});

  final String genre;

  @override
  Widget build(BuildContext context) {
    final model = di<LocalAudioModel>();
    final radioModel = di<RadioModel>();

    final artistAudiosWithGenre = model.findArtistsOfGenre(Audio(genre: genre));

    return Scaffold(
      appBar: HeaderBar(
        adaptive: true,
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: context.l10n.searchForRadioStationsWithGenreName,
              onPressed: () => radioModel.init().then(
                    (_) => di<LibraryModel>().push(
                      builder: (_) => RadioSearchPage(
                        radioSearch: RadioSearch.tag,
                        searchQuery: genre.toLowerCase(),
                      ),
                      pageId: genre.toLowerCase(),
                    ),
                  ),
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
