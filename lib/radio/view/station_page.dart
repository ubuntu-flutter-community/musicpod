import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/connectivity_model.dart';
import '../../app/view/routing_manager.dart';
import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/page_ids.dart';
import '../../common/view/adaptive_multi_layout_body.dart';
import '../../common/view/audio_fall_back_icon.dart';
import '../../common/view/audio_page_header.dart';
import '../../common/view/avatar_play_button.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/offline_page.dart';
import '../../common/view/progress.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/search_button.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../search/search_model.dart';
import '../../search/search_type.dart';
import '../../settings/settings_model.dart';
import '../radio_model.dart';
import 'radio_connect_mixin.dart';
import 'radio_history_list.dart';
import 'radio_page_copy_histoy_button.dart';
import 'radio_page_star_button.dart';
import 'radio_page_tag_bar.dart';

class StationPage extends StatelessWidget with WatchItMixin, RadioConnectMixin {
  const StationPage({super.key, required this.uuid});

  final String uuid;

  @override
  Widget build(BuildContext context) {
    final isOnline = watchPropertyValue((ConnectivityModel m) => m.isOnline);
    if (!isOnline) return const OfflinePage();

    registerRadioConnectHandler(context);

    callOnceAfterThisBuild(
      (_) => di<RadioManager>().getStationByUUIDCommand(uuid).run(),
    );

    final stationResult = watchValue(
      (RadioManager m) => m.getStationByUUIDCommand(uuid).results,
    );
    final station = stationResult.data;
    final error = stationResult.error;

    final useYaruTheme = watchPropertyValue(
      (SettingsModel m) => m.useYaruTheme,
    );
    final radioHistoryListPadding = getRadioHistoryListPadding(useYaruTheme);

    return Scaffold(
      appBar: HeaderBar(
        adaptive: true,
        title: station != null
            ? Text(station.title ?? station.description ?? '')
            : Text(context.l10n.station),
        actions: [
          Padding(
            padding: appBarSingleActionSpacing,
            child: SearchButton(
              onPressed: () {
                di<RoutingManager>().push(pageId: PageIDs.searchPage);
                final searchModel = di<SearchModel>();
                if (searchModel.audioType != AudioType.radio) {
                  searchModel
                    ..setAudioType(AudioType.radio)
                    ..setSearchType(SearchType.radioName)
                    ..setSearchQuery('')
                    ..search(clear: true);
                }
              },
            ),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (error != null) {
            return NoSearchResultPage(
              message: Text(context.l10n.stationNotFound),
            );
          }

          if (station == null) {
            return AdaptiveMultiLayoutBody(
              controlPanel: const SizedBox.shrink(),
              header: AudioPageHeader(
                title: '',
                image: Container(
                  width: kMaxAudioPageHeaderHeight,
                  height: kMaxAudioPageHeaderHeight,
                  color: context.theme.cardColor,
                ),
              ),
              sliverBody: (_) => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Progress()),
              ),
            );
          }

          return AdaptiveMultiLayoutBody(
            header: AudioPageHeader(
              title: station.title ?? station.description ?? '',
              subTitle: station.albumArtist == null
                  ? null
                  : station.albumArtist ?? '',
              label: '${context.l10n.station} · ${station.fileSize ?? ''} kbps',
              description: SizedBox(
                width: kAudioHeaderDescriptionWidth,
                child: RadioPageTagBar(station: station),
              ),
              image: SafeNetworkImage(
                fallBackIcon: AudioFallBackIcon(
                  iconSize: kMaxAudioPageHeaderHeight / 2,
                  audio: station,
                  color: getAlphabetColor(station.uuid ?? 'a'),
                ),
                errorIcon: AudioFallBackIcon(
                  iconSize: kMaxAudioPageHeaderHeight / 2,
                  audio: station,
                  color: getAlphabetColor(station.uuid ?? 'a'),
                ),
                url: station.imageUrl,
                fit: BoxFit.scaleDown,
              ),
            ),
            sliverBody: (constraints) => SliverRadioHistoryList(
              filter: station.title,
              padding: radioHistoryListPadding,
              allowNavigation: false,
            ),
            controlPanel: _StationPageControlPanel(station: station),
          );
        },
      ),
    );
  }
}

class _StationPageControlPanel extends StatelessWidget {
  const _StationPageControlPanel({required this.station});

  final Audio station;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: space(
        children: [
          RadioPageStarButton(station: station),
          if (station.description != null)
            AvatarPlayButton(audios: [station], pageId: station.description!),
          RadioPageCopyHistoryButton(station: station),
        ],
      ),
    );
  }
}
