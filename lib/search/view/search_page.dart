import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/theme.dart';

import '../../common/data/audio.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/progress.dart';
import '../../common/view/search_button.dart';
import '../../common/view/theme.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../podcasts/podcast_model.dart';
import '../../radio/radio_model.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (context.mounted) {
        await di<PodcastModel>().init(
          updateMessage: context.l10n.newEpisodeAvailable,
        );
        await di<RadioModel>().init();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioType = watchPropertyValue((SearchModel m) => m.audioType);
    final loading = watchPropertyValue((SearchModel m) => m.loading);

    return Scaffold(
      resizeToAvoidBottomInset: isMobile ? false : null,
      appBar: HeaderBar(
        adaptive: true,
        title: const SearchPageInput(),
        actions: [
          Padding(
            padding: appBarSingleActionSpacing,
            child: SearchButton(
              active: true,
              onPressed: () => di<LibraryModel>().pop(),
              icon: loading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: Progress(
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
                    .copyWith(bottom: 5),
                sliver: switch (audioType) {
                  AudioType.podcast => const SliverPodcastFilterBar(),
                  _ => const SliverSearchTypeFilterBar(),
                },
              ),
              if (audioType == AudioType.radio)
                SliverPadding(
                  padding:
                      getAdaptiveHorizontalPadding(constraints: constraints),
                  sliver: const SliverRadioSearchResults(),
                )
              else if (audioType == AudioType.podcast)
                SliverPadding(
                  padding:
                      getAdaptiveHorizontalPadding(constraints: constraints),
                  sliver: const SliverPodcastSearchResults(),
                ),
            ],
          );
        },
      ),
    );
  }
}
