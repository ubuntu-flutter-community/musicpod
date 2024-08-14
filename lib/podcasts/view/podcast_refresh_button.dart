import '../../common/view/icons.dart';
import '../../common/view/snackbars.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../podcast_model.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

class PodcastRefreshButton extends StatelessWidget {
  const PodcastRefreshButton({
    super.key,
    required this.pageId,
  });

  final String pageId;

  @override
  Widget build(BuildContext context) {
    var podcast = di<LibraryModel>().podcasts[pageId];

    return IconButton(
      tooltip: context.l10n.checkForUpdates,
      onPressed: podcast == null
          ? null
          : () => di<PodcastModel>().update(
                oldPodcasts: {
                  pageId: podcast,
                },
                updateMessage: context.l10n.updateAvailable,
                notify: ({required message}) =>
                    showSnackBar(context: context, content: Text(message)),
              ),
      icon: Icon(Iconz().refresh),
    );
  }
}
