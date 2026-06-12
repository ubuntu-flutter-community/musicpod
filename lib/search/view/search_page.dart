import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/default_page_body.dart';
import '../../common/view/error_retry_body.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/progress.dart';
import '../../common/view/search_button.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/command_x.dart';
import '../../extensions/object_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../search_manager.dart';
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
    final colorScheme = context.colorScheme;
    final audioType = watchValue((SearchManager m) => m.audioType);
    final loading = watchValue((SearchManager m) => m.searchCommand.isRunning);
    final error = watchValue(
      (SearchManager m) => m.searchCommand.errors.select((v) => v?.error),
    );
    // TODO: care for timeouts

    return Scaffold(
      appBar: HeaderBar(
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
            ),
          ),
        ],
      ),
      body: error != null
          ? ErrorRetryBody(
              error: error,
              errorText: error.localizedErrorMessage(context.l10n),
              onRetry: () => di<SearchManager>().searchCommand.runRestricted(
                param: (clear: true, manualFilter: false),
                immediatelyClearErrors: true,
              ),
            )
          : Stack(
              alignment: Alignment.center,
              children: [
                DefaultPageBody(
                  controlPanel: switch (audioType) {
                    AudioType.podcast => const SliverPodcastFilterBar(),
                    _ => const SearchTypeFilterBar(),
                  },
                  sliverContentBuilder: (context, constraints) =>
                      switch (audioType) {
                        AudioType.radio => SliverRadioSearchResults(
                          width: constraints.maxWidth,
                        ),
                        AudioType.podcast => const SliverPodcastSearchResults(),
                        AudioType.local => SliverLocalSearchResult(
                          constraints: constraints,
                        ),
                      },
                  onStretchTrigger: () async {
                    WidgetsBinding.instance.addPostFrameCallback((
                      timeStamp,
                    ) async {
                      if (context.mounted) {
                        return di<SearchManager>().refresh();
                      }
                    });
                  },
                  onNotification: (ScrollNotification notification) {
                    if (audioType == AudioType.local) return true;

                    if (notification is UserScrollNotification) {
                      if (notification.metrics.axisDirection ==
                              AxisDirection.down &&
                          notification.direction == ScrollDirection.reverse &&
                          notification.metrics.pixels >=
                              notification.metrics.maxScrollExtent * 0.6) {
                        di<SearchManager>()
                          ..incrementLimit(8)
                          ..search();
                      }
                    } else if (notification is ScrollEndNotification) {
                      final metrics = notification.metrics;
                      if (metrics.atEdge) {
                        final isAtBottom = metrics.pixels != 0;
                        if (isAtBottom) {
                          di<SearchManager>()
                            ..incrementLimit(16)
                            ..search();
                        }
                      }
                    }

                    return true;
                  },
                ),
                if (loading)
                  Positioned(
                    bottom: kLargestSpace,
                    child: Container(
                      padding: const EdgeInsets.all(kMediumSpace),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.isLight
                            ? colorScheme.surface
                            : Colors.black,
                        boxShadow: [
                          BoxShadow(
                            color:
                                (colorScheme.isLight
                                        ? colorScheme.onSurface
                                        : Colors.black)
                                    .withAlpha(100),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.fromBorderSide(
                          BorderSide(color: colorScheme.outline, width: 1),
                        ),
                      ),
                      child: Center(
                        child: SizedBox.square(
                          dimension: 20,
                          child: Progress(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
