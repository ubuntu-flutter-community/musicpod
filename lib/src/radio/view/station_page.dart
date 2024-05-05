import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../../build_context_x.dart';
import '../../../common.dart';
import '../../../constants.dart';
import '../../../data.dart';
import '../../../get.dart';
import '../../../theme_data_x.dart';
import '../../player/player_model.dart';
import 'radio_page_copy_histoy_button.dart';
import 'radio_page_star_button.dart';
import 'sliver_radio_history_list.dart';
import 'sliver_radio_page_header.dart';

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
    final theme = context.t;
    final size = context.m.size;
    final wrappedInContainer = size.width < 1200;

    final color = wrappedInContainer
        ? null
        : theme.colorScheme.background.scale(
            lightness: theme.isLight ? -0.02 : 0.02,
            saturation: -0.5,
          );

    return YaruDetailPage(
      appBar: HeaderBar(
        adaptive: true,
        title: Text(station.title ?? station.url ?? ''),
        leading: Navigator.canPop(context)
            ? const NavBackButton()
            : const SizedBox.shrink(),
      ),
      body: AdaptiveContainer(
        child: CustomScrollView(
          slivers: [
            SliverRadioPageHeader(station: station),
            SliverAppBar(
              backgroundColor: color,
              automaticallyImplyLeading: false,
              toolbarHeight: 80,
              pinned: true,
              floating: true,
              flexibleSpace: Padding(
                padding: const EdgeInsets.all(kYaruPagePadding),
                child: _StationPageControlPanel(station: station),
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
  const _StationPageControlPanel({
    required this.station,
  });

  final Audio station;

  @override
  Widget build(BuildContext context) {
    final size = context.m.size;
    final smallWindow = size.width < kMasterDetailBreakPoint;
    return Row(
      mainAxisAlignment:
          smallWindow ? MainAxisAlignment.center : MainAxisAlignment.start,
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
        const SizedBox(
          width: 5,
        ),
        RadioPageCopyHistoryButton(station: station),
      ],
    );
  }
}
