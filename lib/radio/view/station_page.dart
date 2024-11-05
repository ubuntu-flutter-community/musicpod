import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/connectivity_model.dart';
import '../../common/data/audio.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/audio_page_header.dart';
import '../../common/view/avatar_play_button.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/offline_page.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/search_button.dart';
import '../../common/view/sliver_audio_page_control_panel.dart';
import '../../common/view/theme.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../search/search_model.dart';
import '../../search/search_type.dart';
import 'radio_fall_back_icon.dart';
import 'radio_history_list.dart';
import 'radio_page_copy_histoy_button.dart';
import 'radio_page_star_button.dart';
import 'radio_page_tag_bar.dart';

class StationPage extends StatelessWidget with WatchItMixin {
  const StationPage({
    super.key,
    required this.station,
  });

  final Audio station;

  @override
  Widget build(BuildContext context) {
    final isOnline = watchPropertyValue((ConnectivityModel m) => m.isOnline);
    if (!isOnline) return const OfflinePage();

    return Scaffold(
      resizeToAvoidBottomInset: isMobile ? false : null,
      appBar: HeaderBar(
        adaptive: true,
        actions: [
          Padding(
            padding: appBarSingleActionSpacing,
            child: SearchButton(
              onPressed: () {
                di<LibraryModel>().push(pageId: kSearchPageId);
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: getAdaptiveHorizontalPadding(
                  constraints: constraints,
                  min: 40,
                ),
                sliver: SliverToBoxAdapter(
                  child: AudioPageHeader(
                    title: station.title ?? station.description ?? '',
                    subTitle: station.albumArtist == null
                        ? null
                        : station.albumArtist ?? '',
                    label:
                        '${context.l10n.station} · ${station.fileSize ?? ''} kbps',
                    description: SizedBox(
                      width: kAudioHeaderDescriptionWidth,
                      child: RadioPageTagBar(
                        station: station,
                      ),
                    ),
                    image: SafeNetworkImage(
                      fallBackIcon: RadioFallBackIcon(
                        iconSize: kMaxAudioPageHeaderHeight / 2,
                        station: station,
                      ),
                      url: station.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SliverAudioPageControlPanel(
                controlPanel: _StationPageControlPanel(
                  station: station,
                ),
              ),
              SliverPadding(
                padding: getAdaptiveHorizontalPadding(constraints: constraints),
                sliver: SliverRadioHistoryList(
                  filter: station.title,
                  emptyMessage: const SizedBox.shrink(),
                  emptyIcon: const SizedBox.shrink(),
                  padding: radioHistoryListPadding,
                  allowNavigation: false,
                ),
              ),
            ],
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
            AvatarPlayButton(
              audios: [station],
              pageId: station.description!,
            ),
          RadioPageCopyHistoryButton(station: station),
        ],
      ),
    );
  }
}
