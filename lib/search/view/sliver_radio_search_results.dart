import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/connectivity_model.dart';
import '../../common/view/audio_page_type.dart';
import '../../common/view/audio_tile.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/offline_page.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../../radio/radio_model.dart';
import '../../radio/view/radio_reconnect_button.dart';
import '../../radio/view/station_page.dart';
import '../search_model.dart';

class SliverRadioSearchResults extends StatelessWidget with WatchItMixin {
  const SliverRadioSearchResults({super.key});

  @override
  Widget build(BuildContext context) {
    if (!watchPropertyValue((ConnectivityModel m) => m.isOnline)) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: OfflineBody(),
      );
    }

    final connectedHost = watchPropertyValue((RadioModel m) => m.connectedHost);

    if (connectedHost == null) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: RadioReconnectButton()),
      );
    }

    final radioSearchResult =
        watchPropertyValue((SearchModel m) => m.radioSearchResult)
            ?.where((e) => e.uuid != null);

    final searchQuery = watchPropertyValue((SearchModel m) => m.searchQuery);
    final searchType = watchPropertyValue((SearchModel m) => m.searchType);
    final loading = watchPropertyValue((SearchModel m) => m.loading);

    if (radioSearchResult == null ||
        (searchQuery?.isEmpty == true && radioSearchResult.isEmpty == true)) {
      return SliverNoSearchResultPage(
        icon: const AnimatedEmoji(AnimatedEmojis.drum),
        message:
            Text('${context.l10n.search} ${searchType.localize(context.l10n)}'),
      );
    }
    if (radioSearchResult.isEmpty && !loading) {
      return SliverNoSearchResultPage(
        icon: const AnimatedEmoji(AnimatedEmojis.rabbit),
        message: Text(context.l10n.noStationFound),
      );
    }

    final playing = watchPropertyValue((PlayerModel m) => m.isPlaying);
    final currentAudio = watchPropertyValue((PlayerModel m) => m.audio);

    return SliverList.builder(
      itemCount: radioSearchResult.length,
      itemBuilder: (context, index) {
        final station = radioSearchResult.elementAt(index);
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: AudioTile(
            key: ValueKey(station.uuid),
            showLeading: true,
            audioPageType: AudioPageType.radioSearch,
            isPlayerPlaying: playing,
            selected: currentAudio == station,
            pageId: station.uuid!,
            audio: station,
            onTitleTap: () => di<LibraryModel>().push(
              pageId: station.uuid!,
              builder: (context) => StationPage(uuid: station.uuid!),
            ),
            onTap: () {
              di<PlayerModel>().startPlaylist(
                audios: [station],
                listName: station.uuid!,
              ).then((_) => di<RadioModel>().clickStation(station));
            },
          ),
        );
      },
    );
  }
}
