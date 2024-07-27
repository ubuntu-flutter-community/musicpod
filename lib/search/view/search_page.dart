import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/theme.dart';

import '../../app/app_model.dart';
import '../../common/data/audio.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/common_widgets.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import '../../podcasts/podcast_model.dart';
import '../../radio/radio_model.dart';
import '../../radio/view/radio_reconnect_button.dart';
import '../search_model.dart';
import 'audio_type_filter_button.dart';
import 'search_type_filter_bar.dart';
import 'sliver_podcast_search_results.dart';
import 'sliver_radio_search_results.dart';

class SearchPage extends StatefulWidget with WatchItStatefulWidgetMixin {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    super.initState();
    di<RadioModel>().init().then(
          (value) => di<PodcastModel>().init(
            countryCode: di<AppModel>().countryCode,
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
    final searchModel = di<SearchModel>();
    final searchQuery = watchPropertyValue((SearchModel m) => m.searchQuery);
    final audioType = watchPropertyValue((SearchModel m) => m.audioType);

    return Scaffold(
      resizeToAvoidBottomInset: isMobile ? false : null,
      appBar: HeaderBar(
        adaptive: true,
        title: SizedBox(
          width: kSearchBarWidth,
          // TODO: switch to country/language/tag autocomplete if selected
          child: SearchingBar(
            text: searchQuery,
            key: ValueKey(searchQuery ?? 'ya'),
            hintText: context.l10n.search,
            onChanged: (v) async {
              searchModel.setSearchQuery(v);
              await searchModel.search();
            },
            suffixIcon: const AudioTypeFilterButton(),
          ),
        ),
        actions: [
          if (!connectedHost)
            const RadioReconnectButton()
          else
            SizedBox.square(
              dimension: chipHeight + 5,
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
                sliver: const SearchTypeFilterBar(),
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
