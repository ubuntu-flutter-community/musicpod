import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

import '../../app.dart';
import '../../common.dart';
import '../../data.dart';
import '../../globals.dart';
import '../../l10n.dart';
import '../../local_audio.dart';
import '../../radio.dart';

class GenrePage extends ConsumerWidget {
  const GenrePage({required this.genre, super.key});

  final String genre;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showWindowControls =
        ref.watch(appModelProvider.select((a) => a.showWindowControls));
    final model = ref.read(localAudioModelProvider);
    final radioModel = ref.read(radioModelProvider);

    final artistAudiosWithGenre = model.findArtistsOfGenre(Audio(genre: genre));

    return YaruDetailPage(
      appBar: HeaderBar(
        style: showWindowControls
            ? YaruTitleBarStyle.normal
            : YaruTitleBarStyle.undecorated,
        leading: (navigatorKey.currentState?.canPop() == true)
            ? const NavBackButton()
            : const SizedBox.shrink(),
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: context.l10n.searchForRadioStationsWithGenreName,
              onPressed: () {
                radioModel.init().then(
                      (_) => navigatorKey.currentState?.push(
                        MaterialPageRoute(
                          builder: (context) {
                            return RadioSearchPage(
                              radioSearch: RadioSearch.tag,
                              searchQuery: genre.toLowerCase(),
                            );
                          },
                        ),
                      ),
                    );
              },
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
