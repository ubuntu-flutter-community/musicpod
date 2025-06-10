import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/view/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/progress.dart';
import '../../common/view/search_button.dart';
import '../../common/view/sliver_body.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/taget_platform_x.dart';
import '../../settings/settings_model.dart';
import '../search_model.dart';
import 'search_page_input.dart';
import 'sliver_local_search_results.dart';
import 'sliver_podcast_filter_bar.dart';
import 'sliver_podcast_search_results.dart';
import 'sliver_radio_search_results.dart';
import 'sliver_search_type_filter_bar.dart';

class SearchPage extends StatelessWidget with WatchItMixin {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final audioType = watchPropertyValue((SearchModel m) => m.audioType);
    final loading = watchPropertyValue((SearchModel m) => m.loading);
    final useYaruTheme = watchPropertyValue(
      (SettingsModel m) => m.useYaruTheme,
    );

    return Scaffold(
      appBar: HeaderBar(
        adaptive: true,
        title: Padding(
          padding: EdgeInsets.only(left: isMobile ? 5 : 0),
          child: const SearchPageInput(),
        ),
        actions: [
          Padding(
            padding: appBarSingleActionSpacing.copyWith(
              left: isMacOS ? 5 : kLargestSpace,
            ),
            child: SearchButton(
              active: true,
              onPressed: () => di<RoutingManager>().pop(),
              icon: loading
                  ? SizedBox.square(
                      dimension: useYaruTheme ? 18 : 25,
                      child: const Progress(strokeWidth: 2),
                    )
                  : null,
            ),
          ),
        ],
      ),
      body: SliverBody(
        controlPanel: switch (audioType) {
          AudioType.podcast => const SliverPodcastFilterBar(),
          _ => const SearchTypeFilterBar(),
        },
        contentBuilder: (context, constraints) => switch (audioType) {
          AudioType.radio => const SliverRadioSearchResults(),
          AudioType.podcast => const SliverPodcastSearchResults(),
          AudioType.local => const SliverLocalSearchResult(),
        },
        onStretchTrigger: () async {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
            if (context.mounted) {
              return di<SearchModel>().search();
            }
          });
        },
        onNotification: (ScrollNotification notification) {
          if (audioType == AudioType.local) return true;

          if (notification is UserScrollNotification) {
            if (notification.metrics.axisDirection == AxisDirection.down &&
                notification.direction == ScrollDirection.reverse &&
                notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent * 0.6) {
              di<SearchModel>()
                ..incrementLimit(8)
                ..search();
            }
          } else if (notification is ScrollEndNotification) {
            final metrics = notification.metrics;
            if (metrics.atEdge) {
              final isAtBottom = metrics.pixels != 0;
              if (isAtBottom) {
                di<SearchModel>()
                  ..incrementLimit(16)
                  ..search();
              }
            }
          }

          return true;
        },
      ),
    );
  }
}
