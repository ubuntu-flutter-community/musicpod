import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:watch_it/watch_it.dart';

import '../../app_config.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/progress.dart';
import '../../common/view/search_button.dart';
import '../../common/view/sliver_filter_app_bar.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../library/library_model.dart';
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

    return Scaffold(
      appBar: HeaderBar(
        adaptive: true,
        title: Padding(
          padding: EdgeInsets.only(left: AppConfig.isMobilePlatform ? 5 : 0),
          child: const SearchPageInput(),
        ),
        actions: [
          Padding(
            padding: appBarSingleActionSpacing.copyWith(
              left: Platform.isMacOS ? 5 : kLargestSpace,
            ),
            child: SearchButton(
              active: true,
              onPressed: () => di<LibraryModel>().pop(),
              icon: loading
                  ? SizedBox.square(
                      dimension: AppConfig.yaruStyled ? 18 : 25,
                      child: const Progress(
                        strokeWidth: 2,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
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
            child: CustomScrollView(
              slivers: [
                SliverFilterAppBar(
                  padding:
                      getAdaptiveHorizontalPadding(constraints: constraints)
                          .copyWith(
                    bottom: filterPanelPadding.bottom,
                    top: filterPanelPadding.top,
                  ),
                  onStretchTrigger: () async {
                    WidgetsBinding.instance
                        .addPostFrameCallback((timeStamp) async {
                      if (context.mounted) {
                        return di<SearchModel>().search();
                      }
                    });
                  },
                  title: switch (audioType) {
                    AudioType.podcast => const SliverPodcastFilterBar(),
                    _ => const SearchTypeFilterBar(),
                  },
                ),
                SliverPadding(
                  padding:
                      getAdaptiveHorizontalPadding(constraints: constraints)
                          .copyWith(
                    bottom: bottomPlayerPageGap,
                  ),
                  sliver: switch (audioType) {
                    AudioType.radio => const SliverRadioSearchResults(),
                    AudioType.podcast => const SliverPodcastSearchResults(),
                    AudioType.local => const SliverLocalSearchResult(),
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
