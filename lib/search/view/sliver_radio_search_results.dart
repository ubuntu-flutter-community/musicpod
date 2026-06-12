import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/routing_manager.dart';
import '../../common/view/audio_tile_image.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/stared_station_icon_button.dart';
import '../../common/view/tapable_text.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/command_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../player/player_manager.dart';
import '../../radio/radio_manager.dart';
import '../../common/view/error_retry_body.dart';
import '../../radio/view/radio_page_tag_bar.dart';
import '../../radio/view/station_page.dart';
import '../search_manager.dart';

class SliverRadioSearchResults extends StatelessWidget with WatchItMixin {
  const SliverRadioSearchResults({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final connectedHostResults = watchValue(
      (RadioManager m) => m.connectCommand.results,
    );

    if (!connectedHostResults.isRunning && connectedHostResults.hasError) {
      return ErrorRetryBody(
        sliver: true,
        error: connectedHostResults.error!,
        onRetry: () => di<RadioManager>().connectCommand.runRestricted(
          immediatelyClearErrors: true,
        ),
      );
    }

    final radioSearchResult = watchValue(
      (SearchManager m) => m.radioSearchResult,
    )?.where((e) => e.uuid != null);

    final searchQuery = watchValue((SearchManager m) => m.searchQuery);
    final searchType = watchValue((SearchManager m) => m.searchType);
    final loading = watchValue((SearchManager m) => m.searchCommand.isRunning);

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

    final playing = watchPropertyValue((PlayerManager m) => m.isPlaying);
    final currentAudio = watchPropertyValue((PlayerManager m) => m.audio);

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
                                tagLimit: 2,
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
              di<PlayerManager>()
                  .startPlaylist(audios: [station], listName: station.uuid!)
                  .then((_) => di<RadioManager>().clickStation(station));
            },
          ),
        );
      },
    );
  }
}
