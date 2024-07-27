import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/theme.dart';

import '../../app/app_model.dart';
import '../../common/data/audio.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/common_widgets.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import '../../podcasts/podcast_model.dart';
import '../../radio/radio_model.dart';
import '../../radio/view/radio_reconnect_button.dart';
import '../search_model.dart';
import 'search_page_input.dart';
import 'sliver_podcast_filter_bar.dart';
import 'sliver_podcast_search_results.dart';
import 'sliver_radio_search_results.dart';
import 'sliver_search_type_filter_bar.dart';

class SearchPage extends StatefulWidget with WatchItStatefulWidgetMixin {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    super.initState();
    final countryCode = di<AppModel>().countryCode;
    di<RadioModel>().init(countryCode: countryCode).then(
          (value) => di<PodcastModel>().init(
            countryCode: countryCode,
            updateMessage: context.l10n.newEpisodeAvailable,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = watchPropertyValue((PlayerModel m) => m.isOnline);
    final connectedHost = watchPropertyValue(
      (RadioModel m) => m.connectedHost != null && isOnline,
    );
    final audioType = watchPropertyValue((SearchModel m) => m.audioType);

    return Scaffold(
      resizeToAvoidBottomInset: isMobile ? false : null,
      appBar: HeaderBar(
        adaptive: true,
        title: const SearchPageInput(),
        actions: [
          if (!connectedHost)
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: RadioReconnectButton(),
            ),
          if (watchPropertyValue((SearchModel m) => m.loading))
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: SideBarProgress(),
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: getAdaptiveHorizontalPadding(constraints)
                    .copyWith(bottom: 10),
                sliver: audioType == AudioType.podcast
                    ? const SliverPodcastFilterBar()
                    : const SliverSearchTypeFilterBar(),
              ),
              if (audioType == AudioType.radio)
                SliverPadding(
                  padding: getAdaptiveHorizontalPadding(constraints),
                  sliver: const SliverRadioSearchResults(),
                )
              else if (audioType == AudioType.podcast)
                SliverPadding(
                  padding: getAdaptiveHorizontalPadding(constraints),
                  sliver: const SliverPodcastSearchResults(),
                ),
              // TODO: recreate localaudiosearchpage simplified
              // else
            ],
          );
        },
      ),
    );
  }
}
