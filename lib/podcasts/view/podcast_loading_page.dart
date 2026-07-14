import 'package:flutter/material.dart';

import '../../common/view/adaptive_multi_layout_body.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/progress.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import 'podcast_page_header.dart';

class PodcastLoadingPage extends StatelessWidget {
  const PodcastLoadingPage({
    super.key,
    this.expandChild = false,
    required this.feedUrl,
  });

  final String feedUrl;
  final bool expandChild;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const HeaderBar(),
    body: AdaptiveMultiLayoutBody(
      header: PodcastPageHeader(
        title: context.l10n.loadingPodcastFeed,
        showFallBackOrErrorIcon: false,
        feedUrl: feedUrl,
      ),
      sliverBody: (constraints) => expandChild
          ? const SliverFillRemaining(
              hasScrollBody: false,
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.all(kSmallestSpace),
                  child: Progress(),
                ),
              ),
            )
          : const SliverToBoxAdapter(
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.all(kSmallestSpace),
                  child: Progress(),
                ),
              ),
            ),
      controlPanel: const SizedBox.shrink(),
    ),
  );
}
