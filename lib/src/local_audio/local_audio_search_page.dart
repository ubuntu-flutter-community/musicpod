import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../app.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../globals.dart';
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
    final service = getService<AppStateService>();
    final showWindowControls = service.showWindowControls;

    final localAudioService = getService<LocalAudioService>();
    final searchResult = localAudioService.searchResult;
    localAudioService.searchResultChanged.watch(context);
    final titlesResult = searchResult?.$1;
    final artistsResult = searchResult?.$3;
    final albumsResult = searchResult?.$2;
    final searchQuery = localAudioService.searchQuery.watch(context);
    final index = service.localAudioIndex;

    void search({required String? text}) {
      if (text != null) {
        localAudioService.search(text);
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
            localAudioView: LocalAudioView.values[index.watch(context)],
            titles: titlesResult,
            artists: artistsResult,
            albums: albumsResult,
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: HeaderBar(
        style: showWindowControls.watch(context)
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
