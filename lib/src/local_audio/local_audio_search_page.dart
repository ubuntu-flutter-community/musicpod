import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../app.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../globals.dart';
import '../../library.dart';
import '../../local_audio.dart';
import '../l10n/l10n.dart';
import 'local_audio_body.dart';
import 'local_audio_control_panel.dart';
import 'local_audio_view.dart';

class LocalAudioSearchPage extends ConsumerWidget {
  const LocalAudioSearchPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showWindowControls =
        ref.watch(appModelProvider.select((v) => v.showWindowControls));

    final model = ref.read(localAudioModelProvider);
    final titlesResult =
        ref.watch(localAudioModelProvider.select((m) => m.titlesSearchResult));
    final artistsResult = ref.watch(
      localAudioModelProvider.select((m) => m.similarArtistsSearchResult),
    );
    final albumsResult =
        ref.watch(localAudioModelProvider.select((m) => m.albumSearchResult));
    final searchQuery =
        ref.watch(localAudioModelProvider.select((m) => m.searchQuery));
    final index =
        ref.watch(libraryModelProvider.select((m) => m.localAudioindex ?? 0));
    final localAudioView = LocalAudioView.values[index];

    void search({required String? text}) {
      if (text != null) {
        model.search(text);
      } else {
        navigatorKey.currentState?.maybePop();
      }
    }

    final nothing = (titlesResult?.isEmpty ?? true) &&
        (albumsResult?.isEmpty ?? true) &&
        (artistsResult?.isEmpty ?? true) &&
        searchQuery?.isNotEmpty == true;
    Widget body = Column(
      children: [
        LocalAudioControlPanel(
          titlesCount:
              searchQuery?.isNotEmpty == true ? titlesResult?.length : null,
          artistCount:
              searchQuery?.isNotEmpty == true ? artistsResult?.length : null,
          albumCount:
              searchQuery?.isNotEmpty == true ? albumsResult?.length : null,
        ),
        Expanded(
          child: LocalAudioBody(
            noResultIcon: nothing
                ? const AnimatedEmoji(AnimatedEmojis.eyes)
                : const AnimatedEmoji(AnimatedEmojis.drum),
            noResultMessage: Text(
              nothing ? context.l10n.noLocalSearchFound : context.l10n.search,
            ),
            localAudioView: localAudioView,
            titles: titlesResult,
            artists: artistsResult,
            albums: albumsResult,
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
            text: searchQuery,
            onChanged: (value) => search(text: value),
            onClear: () => search(text: ''),
          ),
        ),
      ),
      body: body,
    );
  }
}
