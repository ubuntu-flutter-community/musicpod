import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:podcast_search/podcast_search.dart';

import '../../common/data/retry_capsule.dart';
import '../../common/view/adaptive_multi_layout_body.dart';
import '../../common/view/error_retry_body.dart';
import '../../common/view/header_bar.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/command_x.dart';
import '../manager/episodes_manager.dart';
import 'podcast_page_header.dart';

class PodcastErrorPage extends StatelessWidget with WatchItMixin {
  const PodcastErrorPage({
    super.key,
    required this.error,
    required this.feedUrl,
    required this.stackTrace,
  });

  final Object error;
  final StackTrace stackTrace;
  final String feedUrl;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const HeaderBar(),
    body: AdaptiveMultiLayoutBody(
      header: PodcastPageHeader(
        title: context.l10n.oopsSomethingWentWrong,
        feedUrl: feedUrl,
      ),
      sliverBody: (constraints) => ErrorRetryBody(
        logError: error is! PodcastFailedException,
        sliver: true,
        error: error,
        stackTrace: stackTrace,
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
