import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../../build_context_x.dart';
import '../../../common.dart';
import '../../../constants.dart';
import '../../../data.dart';
import '../../common/sliver_audio_page_control_panel.dart';
import '../../player/player_model.dart';
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
    final isOnline = watchPropertyValue((PlayerModel m) => m.isOnline);
    if (!isOnline) return const OfflinePage();

    return YaruDetailPage(
      appBar: HeaderBar(
        adaptive: true,
        title: Text(station.title ?? station.url ?? ''),
      ),
      body: AdaptiveContainer(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: AudioPageHeader(
                title: station.title ?? station.url ?? '',
                label: station.artist,
                descriptionWidget: RadioPageTagBar(station: station),
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
            SliverAudioPageControlPanel(
              controlPanel: _StationPageControlPanel(
                station: station,
              ),
            ),
            SliverRadioHistoryList(
              filter: station.title,
              emptyMessage: const SizedBox.shrink(),
              emptyIcon: const SizedBox.shrink(),
              padding: radioHistoryListPadding,
            ),
          ],
        ),
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
      mainAxisAlignment: context.smallWindow
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: AvatarPlayButton(
            audios: {station},
            pageId: station.url,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        RadioPageStarButton(station: station),
        RadioPageCopyHistoryButton(station: station),
      ],
    );
  }
}
