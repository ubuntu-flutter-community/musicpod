import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/data/retry_capsule.dart';
import '../../common/view/adaptive_multi_layout_body.dart';
import '../../common/view/error_retry_body.dart';
import '../../common/view/header_bar.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/command_x.dart';
import '../episodes_manager.dart';
import 'podcast_page_header.dart';

class PodcastErrorPage extends StatelessWidget with WatchItMixin {
  const PodcastErrorPage({
    super.key,
    required this.error,
    this.imageUrl,
    required this.feedUrl,
  });

  final Object error;
  final String? imageUrl;
  final String feedUrl;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const HeaderBar(),
    body: AdaptiveMultiLayoutBody(
      header: PodcastPageHeader(
        title: context.l10n.oopsSomethingWentWrong,
        imageUrl: imageUrl,
        episodes: [],
        showFallbackIcon: false,
      ),
      sliverBody: (constraints) => ErrorRetryBody(
        sliver: true,
        error: error,
        retryCapsule: RetryCapsule(
          retryViewId: feedUrl,
          onRetry: () =>
              di<EpisodesManager>(param1: feedUrl).command.runRestricted(
                runWhen: RunWhen.hasNoValueAndNoErrors,
                immediatelyClearErrors: true,
              ),
        ),
      ),
      controlPanel: const SizedBox.shrink(),
    ),
  );
}
