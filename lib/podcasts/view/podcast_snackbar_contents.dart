import '../../common/view/progress.dart';
import '../../common/view/theme.dart';
import '../../l10n/l10n.dart';
import 'package:flutter/material.dart';

class PodcastSearchTimeoutSnackBarContent extends StatelessWidget {
  const PodcastSearchTimeoutSnackBarContent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(context.l10n.podcastFeedLoadingTimeout)),
        SizedBox(
          height: iconSize,
          width: iconSize,
          child: const Progress(),
        ),
      ],
    );
  }
}

class PodcastSearchLoadingSnackBarContent extends StatelessWidget {
  const PodcastSearchLoadingSnackBarContent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(context.l10n.loadingPodcastFeed),
        SizedBox(
          height: iconSize,
          width: iconSize,
          child: const Progress(),
        ),
      ],
    );
  }
}

class PodcastSearchEmptyFeedSnackBarContent extends StatelessWidget {
  const PodcastSearchEmptyFeedSnackBarContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(context.l10n.podcastFeedIsEmpty);
  }
}
