import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/connectivity_model.dart';
import '../../app/view/routing_manager.dart';
import '../../common/data/audio.dart';
import '../../common/view/audio_tile_image.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/offline_page.dart';
import '../../common/view/stared_station_icon_button.dart';
import '../../common/view/tapable_text.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n.dart';
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
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: ListTile(
            key: ValueKey(station.uuid),
            leading: AudioTileImage(size: kAudioTrackWidth, audio: station),
            title: TapAbleText(
              text: station.title ?? context.l10n.unknown,
              onTap: () => di<RoutingManager>().push(
                pageId: station.uuid!,
                builder: (context) => StationPage(uuid: station.uuid!),
              ),
            ),
            subtitle: Text(_buildRadioSubTitle(station, context.l10n)),
            trailing: StaredStationIconButton(
              audio: station,
              color: currentAudio == station && playing
                  ? context.theme.contrastyPrimary
                  : null,
            ),
            onTap: () {
              di<PlayerModel>()
                  .startPlaylist(audios: [station], listName: station.uuid!)
                  .then((_) => di<RadioModel>().clickStation(station));
            },
          ),
        );
      },
    );
  }

  String _buildRadioSubTitle(Audio audio, AppLocalizations l10n) =>
      '${audio.albumArtist?.isNotEmpty == true ? '${audio.albumArtist}' : ''}${audio.bitRate > 0 ? ' • ${audio.fileSize} kbps' : ''}${audio.clicks > 0 ? ' • ${audio.clicks} ${l10n.clicks}' : ''}${audio.language.trim().isNotEmpty ? ' • ${audio.language.split(',').join(', ')}' : ''}';
}
