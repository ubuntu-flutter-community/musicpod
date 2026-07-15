import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/adaptive_multi_layout_body.dart';
import '../../common/view/audio_fall_back_icon.dart';
import '../../common/view/audio_page_header.dart';
import '../../common/view/audio_page_type.dart';
import '../../common/view/avatar_play_button.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/progress.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/search_button.dart';
import '../../common/view/stared_station_icon_button.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/platform_x.dart';
import '../../search/data/search_type.dart';
import '../../search/manager/search_manager.dart';
import '../manager/station_manager.dart';
import 'radio_history_list.dart';
import 'radio_page_copy_histoy_button.dart';
import 'radio_page_tag_bar.dart';
import 'station_error_page.dart';

class StationPage extends StatelessWidget {
  const StationPage({super.key, required this.uuid});

  final String uuid;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: HeaderBar(
      title: isMobile ? null : _StationPageTitle(uuid: uuid),
      actions: [
        Padding(
          padding: appBarSingleActionSpacing,
          child: SearchButton(
            onPressed: () {
              di<RoutingManager>().push(pageId: PageIDs.searchPage);
              di<SearchManager>()
                ..setAudioType(AudioType.radio)
                ..setSearchType(SearchType.radioName)
                ..setSearchQuery('')
                ..search(clear: true);
            },
          ),
        ),
      ],
    ),
    body: _StationPageBody(uuid: uuid),
  );
}

class _StationPageBody extends StatelessWidget with WatchItMixin {
  const _StationPageBody({required this.uuid});

  final String uuid;

  @override
  Widget build(BuildContext context) =>
      watchValue(
        (StationManager m) => m.command.results,
        param1: uuid,
      ).toWidget(
        whileRunning: (lastResult, param) => const Center(child: Progress()),
        onError: (error, lastResult, param) =>
            StationErrorPage(uuid: uuid, error: error),
        onNullData: (param) =>
            NoSearchResultPage(message: Text(context.l10n.stationNotFound)),
        onData: (result, param) {
          final station = result!;
          return AdaptiveMultiLayoutBody(
            header: AudioPageHeader(
              title: station.title ?? station.uuid ?? '',
              subTitle: station.codec == null ? null : station.codec ?? '',
              label: '${context.l10n.station} · ${station.bitRate ?? ''} kbps',
              description: SizedBox(
                width: kAudioHeaderDescriptionWidth,
                child: RadioPageTagBar(station: station),
              ),
              image: SafeNetworkImage(
                fallbackWidget: AudioFallBackIcon(
                  iconSize: kMaxAudioPageHeaderHeight / 2,
                  audio: station,
                  color: getAlphabetColor(station.uuid ?? 'a'),
                ),
                errorWidget: AudioFallBackIcon(
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
              allowNavigation: false,
            ),
            controlPanel: _StationPageControlPanel(uuid: uuid),
          );
        },
      );
}

class _StationPageTitle extends StatelessWidget with WatchItMixin {
  const _StationPageTitle({required this.uuid});

  final String uuid;

  @override
  Widget build(BuildContext context) {
    final station = watchValue((StationManager m) => m.command, param1: uuid);
    return Text(
      station?.title ?? station?.uuid ?? context.l10n.station,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _StationPageControlPanel extends WatchingWidget {
  const _StationPageControlPanel({required this.uuid});

  final String uuid;

  @override
  Widget build(BuildContext context) {
    final station = watchValue((StationManager m) => m.command, param1: uuid);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: space(
        children: [
          StaredStationIconButton(audio: station),
          if (station?.uuid != null) ...[
            AvatarPlayButton(
              pageId: station!.uuid!,
              audioPageType: AudioPageType.radio,
            ),
            RadioPageCopyHistoryButton(station: station),
          ],
        ],
      ),
    );
  }
}
