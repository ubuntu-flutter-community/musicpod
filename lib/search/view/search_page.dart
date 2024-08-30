import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/theme.dart';

import '../../common/data/audio.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/progress.dart';
import '../../common/view/search_button.dart';
import '../../common/view/theme.dart';
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
      resizeToAvoidBottomInset: isMobile ? false : null,
      appBar: HeaderBar(
        adaptive: true,
        title: Padding(
          padding: EdgeInsets.only(left: isMobile ? 5 : 0),
          child: const SearchPageInput(),
        ),
        actions: [
          Padding(
            padding: appBarSingleActionSpacing,
            child: SearchButton(
              active: true,
              onPressed: () => di<LibraryModel>().pop(),
              icon: loading
                  ? SizedBox.square(
                      dimension: yaruStyled ? 18 : 25,
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
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: getAdaptiveHorizontalPadding(constraints: constraints)
                    .copyWith(
                  bottom: 5,
                  top: isMobile ? 10 : 0,
                ),
                sliver: switch (audioType) {
                  AudioType.podcast => const SliverPodcastFilterBar(),
                  _ => const SliverSearchTypeFilterBar(),
                },
              ),
              SliverPadding(
                padding: getAdaptiveHorizontalPadding(constraints: constraints),
                sliver: switch (audioType) {
                  AudioType.radio => const SliverRadioSearchResults(),
                  AudioType.podcast => const SliverPodcastSearchResults(),
                  AudioType.local => const SliverLocalSearchResult(),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
