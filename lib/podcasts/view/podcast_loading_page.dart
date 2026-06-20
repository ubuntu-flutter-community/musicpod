import 'package:flutter/material.dart';

import '../../common/view/adaptive_multi_layout_body.dart';
import '../../common/view/header_bar.dart';
import '../../extensions/build_context_x.dart';
import 'podcast_page_header.dart';

class PodcastLoadingPage extends StatelessWidget {
  const PodcastLoadingPage({
    super.key,
    required this.child,
    this.expandChild = false,
    this.title,
  });

  final String? title;
  final Widget child;
  final bool expandChild;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const HeaderBar(),
    body: AdaptiveMultiLayoutBody(
      header: PodcastPageHeader(
        title: title ?? context.l10n.loadingPodcastFeed,
        episodes: [],
        showFallbackIcon: false,
      ),
      sliverBody: (constraints) => expandChild
          ? SliverFillRemaining(hasScrollBody: false, child: child)
          : SliverToBoxAdapter(child: child),
      controlPanel: const SizedBox.shrink(),
    ),
  );
}
