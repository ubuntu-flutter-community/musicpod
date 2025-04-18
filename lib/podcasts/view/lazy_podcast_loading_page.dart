import 'package:flutter/material.dart';

import '../../common/view/header_bar.dart';
import '../../common/view/sliver_audio_page_control_panel.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderBar(adaptive: true),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            sliver: SliverToBoxAdapter(
              child: PodcastPageHeader(
                title: title,
                imageUrl: imageUrl,
                episodes: [],
              ),
            ),
          ),
          const SliverAudioPageControlPanel(
            controlPanel: PodcastPageControlPanel(
              feedUrl: '',
              audios: [],
              title: '',
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: child,
          ),
        ],
      ),
    );
  }
}
