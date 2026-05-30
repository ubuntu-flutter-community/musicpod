import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/adaptive_multi_layout_body.dart';
import '../../common/view/audio_fall_back_icon.dart';
import '../../common/view/audio_page_header.dart';
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
import '../../extensions/taget_platform_x.dart';
import '../../search/search_manager.dart';
import '../../search/search_type.dart';
import '../../settings/settings_model.dart';
import '../radio_manager.dart';
import '../radio_service.dart';
import 'radio_connect_mixin.dart';
import 'radio_error_retry_body.dart';
import 'radio_history_list.dart';
import 'radio_page_copy_histoy_button.dart';
import 'radio_page_tag_bar.dart';

class StationPage extends StatelessWidget with WatchItMixin, RadioConnectMixin {
  const StationPage({super.key, required this.uuid});

  final String uuid;

  @override
  Widget build(BuildContext context) {
    registerRadioConnectHandler(context);

    callAfterEveryBuild(
      (_, cancel) => di<RadioManager>().maybeRunStationByUUIDCommand(uuid),
    );

    registerHandler(
      select: (RadioManager m) => m.getStationByUUIDCommand(uuid).results,
      handler: (context, results, cancel) {
        if (results.hasError) {
          context.toast(
            Text(switch (results.error) {
              final e when e is FindStationTimeoutException =>
                context.l10n.findStationsTimeoutMessage,
              final e when e is RadioBrowserServerUnavailableException =>
                context.l10n.radioBrowserSeverUnavailable,
              final e when e is RadioBrowserApiNotConnectedException =>
                context.l10n.disconnectedFrom + ' RadioBrowser API',
              _ => results.error.toString(),
            }),
            action: SnackBarAction(
              label: context.l10n.retry,
              onPressed: () => di<RadioManager>().maybeRunStationByUUIDCommand(
                uuid,
                clearErrors: true,
              ),
            ),
          );
        } else if (results.hasData) {
          context.clearToasts();
        }
      },
    );

    final stationResult = watchValue(
      (RadioManager m) => m.getStationByUUIDCommand(uuid).results,
    );
    final station = stationResult.data;
    final error = stationResult.error;
    final isRunning = stationResult.isRunning;

    final useYaruTheme = watchPropertyValue(
      (SettingsModel m) => m.useYaruTheme,
    );
    final radioHistoryListPadding = getRadioHistoryListPadding(useYaruTheme);

    return Scaffold(
      appBar: HeaderBar(
        title: isMobile
            ? null
            : (station != null
                  ? Text(station.title ?? station.uuid ?? '')
                  : Text(context.l10n.station)),
        actions: [
          Padding(
            padding: appBarSingleActionSpacing,
            child: SearchButton(
              onPressed: () {
                di<RoutingManager>().push(pageId: PageIDs.searchPage);
                final searchManager = di<SearchManager>();
                if (searchManager.audioType != AudioType.radio) {
                  searchManager
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
            return RadioErrorRetryBody(
              error: error,
              onRetry: isRunning
                  ? null
                  : () => di<RadioManager>().maybeRunStationByUUIDCommand(
                      uuid,
                      clearErrors: true,
                    ),
            );
          }

          if (isRunning || station == null || stationResult.hasError) {
            return AdaptiveMultiLayoutBody(
              controlPanel: const SizedBox.shrink(),
              header: AudioPageHeader(
                title: '',
                image: isRunning
                    ? Container(
                        width: kMaxAudioPageHeaderHeight,
                        height: kMaxAudioPageHeaderHeight,
                        color: context.theme.cardColor,
                      )
                    : null,
              ),
              sliverBody: (_) => isRunning
                  ? const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Progress()),
                    )
                  : SliverNoSearchResultPage(
                      message: Text(
                        stationResult.error?.toString() ??
                            context.l10n.stationNotFound,
                      ),
                    ),
            );
          }

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
          StaredStationIconButton(audio: station),
          if (station.uuid != null)
            AvatarPlayButton(audios: [station], pageId: station.uuid!),
          RadioPageCopyHistoryButton(station: station),
        ],
      ),
    );
  }
}
