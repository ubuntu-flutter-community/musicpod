import 'package:flutter/material.dart';

import '../../common/view/adaptive_multi_layout_body.dart';
import '../../common/view/header_bar.dart';
import '../../extensions/build_context_x.dart';
import 'podcast_page_header.dart';

class LazyPodcastLoadingPage extends StatelessWidget {
  const LazyPodcastLoadingPage({
    super.key,
    this.imageUrl,
    required this.child,
    this.expandChild = false,
    this.title,
  });

  final String? title;
  final String? imageUrl;
  final Widget child;
  final bool expandChild;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const HeaderBar(),
    body: AdaptiveMultiLayoutBody(
      header: PodcastPageHeader(
        title: title ?? context.l10n.loadingPodcastFeed,
        imageUrl: imageUrl,
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
