import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../app.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../globals.dart';
import '../../library.dart';
import '../../local_audio.dart';
import '../l10n/l10n.dart';
import 'local_audio_body.dart';
import 'local_audio_control_panel.dart';
import 'local_audio_view.dart';

class LocalAudioSearchPage extends StatelessWidget {
  const LocalAudioSearchPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final showWindowControls =
        context.select((AppModel m) => m.showWindowControls);

    final model = context.read<LocalAudioModel>();

    final similarArtistsSearchResult =
        context.select((LocalAudioModel m) => m.similarArtistsSearchResult);

    final similarAlbumsSearchResult =
        context.select((LocalAudioModel m) => m.albumSearchResult);

    final searchQuery = context.select((LocalAudioModel m) => m.searchQuery);
    final index = context.select((LibraryModel m) => m.localAudioindex) ?? 0;

    final localAudioView = LocalAudioView.values[index];

    final Set<Audio>? titlesResult =
        context.select((LocalAudioModel m) => m.titlesSearchResult);

    void search({required String? text}) {
      if (text != null) {
        model.search(text);
      } else {
        navigatorKey.currentState?.maybePop();
      }
    }

    Widget body = Column(
      children: [
        const LocalAudioControlPanel(),
        if ((titlesResult?.isEmpty ?? true) &&
            (similarAlbumsSearchResult?.isEmpty ?? true) &&
            (similarArtistsSearchResult?.isEmpty ?? true))
          Expanded(
            child: NoSearchResultPage(
              message: searchQuery == ''
                  ? Text(context.l10n.search)
                  : Text(
                      context.l10n.noLocalSearchFound,
                    ),
              icons: searchQuery == ''
                  ? const AnimatedEmoji(AnimatedEmojis.drum)
                  : null,
            ),
          )
        else
          Expanded(
            child: LocalAudioBody(
              noResultMessage: Text(context.l10n.nothingFound),
              localAudioView: localAudioView,
              titles: titlesResult,
              artists: similarArtistsSearchResult,
              albums: similarAlbumsSearchResult,
            ),
          ),
      ],
    );

    return Scaffold(
      appBar: HeaderBar(
        style: showWindowControls
            ? YaruTitleBarStyle.normal
            : YaruTitleBarStyle.undecorated,
        leading: (Navigator.of(context).canPop())
            ? const NavBackButton()
            : const SizedBox.shrink(),
        titleSpacing: 0,
        actions: [
          Flexible(
            child: Padding(
              padding: appBarActionSpacing,
              child: SearchButton(
                active: true,
                onPressed: () => search(text: null),
              ),
            ),
          ),
        ],
        title: SizedBox(
          width: kSearchBarWidth,
          child: SearchingBar(
            key: ValueKey(searchQuery.toString() + localAudioView.toString()),
            text: searchQuery,
            onSubmitted: (value) => search(text: value),
            onClear: () => search(text: ''),
          ),
        ),
      ),
      body: body,
    );
  }
}
