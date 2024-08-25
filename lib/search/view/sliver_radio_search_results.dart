import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/connectivity_model.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/offline_page.dart';
import '../../common/view/snackbars.dart';
import '../../common/view/theme.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import '../../radio/radio_model.dart';
import '../../radio/view/station_card.dart';
import '../search_model.dart';

class SliverRadioSearchResults extends StatefulWidget
    with WatchItStatefulWidgetMixin {
  const SliverRadioSearchResults({super.key});

  @override
  State<SliverRadioSearchResults> createState() =>
      _SliverRadioSearchResultsState();
}

class _SliverRadioSearchResultsState extends State<SliverRadioSearchResults> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final model = di<RadioModel>();
      final connectivityModel = di<ConnectivityModel>();
      model.init().then(
        (connectedHost) {
          if (!connectivityModel.isOnline) {
            return;
          }
          if (mounted && model.showConnectSnackBar) {
            showSnackBar(
              context: context,
              snackBar: buildConnectSnackBar(
                connectedHost: connectedHost,
                context: context,
              ),
            );
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!watchPropertyValue((ConnectivityModel m) => m.isOnline)) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: OfflineBody(),
      );
    }

    if (watchPropertyValue((RadioModel m) => m.connectedHost) == null) {
      return const SliverFillRemaining(
        hasScrollBody: false,
      );
    }

    final radioSearchResult =
        watchPropertyValue((SearchModel m) => m.radioSearchResult);
    final searchQuery = watchPropertyValue((SearchModel m) => m.searchQuery);
    final searchType = watchPropertyValue((SearchModel m) => m.searchType);
    final loading = watchPropertyValue((SearchModel m) => m.loading);

    if (radioSearchResult == null ||
        (searchQuery?.isEmpty == true && radioSearchResult.isEmpty == true)) {
      return SliverFillNoSearchResultPage(
        icon: const AnimatedEmoji(AnimatedEmojis.drum),
        message:
            Text('${context.l10n.search} ${searchType.localize(context.l10n)}'),
      );
    }
    if (radioSearchResult.isEmpty && !loading) {
      return SliverFillNoSearchResultPage(
        icon: const AnimatedEmoji(AnimatedEmojis.rabbit),
        message: Text(context.l10n.noStationFound),
      );
    }

    return SliverGrid.builder(
      gridDelegate: audioCardGridDelegate,
      itemCount: radioSearchResult.length,
      itemBuilder: (context, index) {
        final station = radioSearchResult.elementAt(index);
        return StationCard(
          station: station,
          startPlaylist: ({
            required audios,
            index,
            required listName,
          }) {
            return di<PlayerModel>()
                .startPlaylist(
                  audios: audios,
                  listName: listName,
                )
                .then((_) => di<RadioModel>().clickStation(station));
          },
        );
      },
    );
  }
}
