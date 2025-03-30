import 'package:flutter/material.dart';

import '../../common/view/snackbars.dart';
import '../podcast_search_state.dart';
import 'podcast_snackbar_contents.dart';

void podcastStateStreamHandler(
  BuildContext context,
  AsyncSnapshot<PodcastSearchState?> newValue,
  void Function() cancel,
) {
  if (newValue.hasData) {
    if (newValue.data == PodcastSearchState.done) {
      ScaffoldMessenger.of(context).clearSnackBars();
    } else {
      showSnackBar(
        context: context,
        content: switch (newValue.data) {
          PodcastSearchState.loading =>
            const PodcastSearchLoadingSnackBarContent(),
          PodcastSearchState.empty =>
            const PodcastSearchEmptyFeedSnackBarContent(),
          PodcastSearchState.timeout =>
            const PodcastSearchTimeoutSnackBarContent(),
          _ => const SizedBox.shrink()
        },
        duration: switch (newValue.data) {
          PodcastSearchState.loading => const Duration(seconds: 1000),
          _ => const Duration(seconds: 3),
        },
      );
    }
  }
}
