import 'package:flutter/material.dart';

import '../../common/view/adaptive_multi_layout_body.dart';
import '../../common/view/header_bar.dart';
import 'podcast_page_control_panel.dart';
import 'podcast_page_header.dart';

class LazyPodcastLoadingPage extends StatelessWidget {
  const LazyPodcastLoadingPage({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.child,
  });

  final String title;
  final String? imageUrl;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const HeaderBar(adaptive: true),
    body: AdaptiveMultiLayoutBody(
      header: PodcastPageHeader(
        title: title,
        imageUrl: imageUrl,
        episodes: [],
        showFallbackIcon: false,
      ),
      sliverBody: (constraints) => SliverToBoxAdapter(child: child),
      controlPanel: const PodcastPageControlPanel(
        feedUrl: '',
        audios: [],
        title: '',
      ),
    ),
  );
}
