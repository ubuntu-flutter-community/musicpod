import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/connectivity_model.dart';
import '../../app/routing_manager.dart';
import '../../common/view/audio_tile_image.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/offline_page.dart';
import '../../common/view/stared_station_icon_button.dart';
import '../../common/view/tapable_text.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import '../../radio/radio_model.dart';
import '../../radio/view/radio_page_tag_bar.dart';
import '../../radio/view/radio_reconnect_button.dart';
import '../../radio/view/station_page.dart';
import '../search_model.dart';

class SliverRadioSearchResults extends StatelessWidget with WatchItMixin {
  const SliverRadioSearchResults({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    if (!watchPropertyValue((ConnectivityModel m) => m.isOnline)) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: OfflineBody(),
      );
    }

    final theme = context.theme;

    final connectedHost = watchValue((RadioManager m) => m.connectCommand);

    if (connectedHost == null) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: RadioReconnectButton()),
      );
    }

    final radioSearchResult = watchPropertyValue(
      (SearchModel m) => m.radioSearchResult,
    )?.where((e) => e.uuid != null);

    final searchQuery = watchPropertyValue((SearchModel m) => m.searchQuery);
    final searchType = watchPropertyValue((SearchModel m) => m.searchType);
    final loading = watchPropertyValue((SearchModel m) => m.loading);

    if (radioSearchResult == null ||
        (searchQuery?.isEmpty == true && radioSearchResult.isEmpty == true)) {
      return SliverNoSearchResultPage(
        message: Text(
          '${context.l10n.search} ${searchType.localize(context.l10n)}',
        ),
      );
    }
    if (radioSearchResult.isEmpty && !loading) {
      return SliverNoSearchResultPage(
        message: Text(context.l10n.noStationFound),
      );
    }

    final playing = watchPropertyValue((PlayerModel m) => m.isPlaying);
    final currentAudio = watchPropertyValue((PlayerModel m) => m.audio);

    return SliverList.builder(
      itemCount: radioSearchResult.length,
      itemBuilder: (context, index) {
        final station = radioSearchResult.elementAt(index);
        const maxLines = 1;
        final selected = currentAudio?.uuid == station.uuid;
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: ListTile(
            key: ValueKey(station.uuid),
            leading: AudioTileImage(size: kAudioTrackWidth, audio: station),
            selected: selected,
            selectedColor: context.theme.contrastyPrimary,
            title: Row(
              spacing: kLargestSpace,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      TapAbleText(
                        text: station.title ?? context.l10n.unknown,
                        onTap: () => di<RoutingManager>().push(
                          pageId: station.uuid!,
                          builder: (context) =>
                              StationPage(uuid: station.uuid!),
                        ),
                        maxLines: maxLines,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: (station.tags?.isEmpty ?? true)
                            ? Text(context.l10n.station)
                            : RadioPageTagBar(
                                station: station,
                                tagLimit: 3,
                                style:
                                    theme.listTileTheme.subtitleTextStyle ??
                                    theme.textTheme.bodyMedium?.copyWith(
                                      color: selected
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                              ),
                      ),
                    ],
                  ),
                ),
                if (width > 500)
                  Expanded(
                    child: Text(
                      '${(station.bitRate ?? 0) > 0 ? '${station.bitRate} kbps' : context.l10n.unknown}',
                      maxLines: maxLines,
                    ),
                  ),
                if (width > 800)
                  Expanded(
                    child: Text(
                      '${station.codec?.isNotEmpty == true ? '${station.codec}' : context.l10n.unknown}',
                      maxLines: maxLines,
                    ),
                  ),

                if (width > 1100)
                  Expanded(
                    child: Text(
                      '${(station.clicks ?? 0) > 0 ? '${station.clicks} ${context.l10n.clicks}' : context.l10n.unknown}',
                      maxLines: maxLines,
                    ),
                  ),
                if (width > 1200)
                  Expanded(
                    child: Text(
                      '${(station.language ?? '').trim().isNotEmpty ? '${station.language!.split(',').join(', ')}' : context.l10n.unknown}',
                      maxLines: maxLines,
                    ),
                  ),
              ],
            ),

            trailing: StaredStationIconButton(
              audio: station,
              color: currentAudio == station && playing
                  ? theme.contrastyPrimary
                  : null,
            ),
            onTap: () {
              di<PlayerModel>()
                  .startPlaylist(audios: [station], listName: station.uuid!)
                  .then((_) => di<RadioManager>().clickStation(station));
            },
          ),
        );
      },
    );
  }
}
