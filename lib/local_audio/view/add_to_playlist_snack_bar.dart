import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/full_window_mode_manager.dart';
import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../extensions/build_context_x.dart';

void showAddedToPlaylistSnackBar({
  required BuildContext context,
  required String id,
}) {
  final container = ProviderScope.containerOf(context, listen: false);
  if (id == container.read(routingManagerProvider)) {
    return;
  }

  ScaffoldMessenger.of(context).clearSnackBars();

  context.toast(
    Text(
      '${context.l10n.addedTo} ${id == PageIDs.likedAudios ? context.l10n.likedSongs : id}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    showCloseIcon: true,

    action: SnackBarAction(
      onPressed: () {
        container
            .read(fullWindowModeManagerProvider.notifier)
            .setFullWindowMode(false);
        container.read(routingManagerProvider.notifier).push(pageId: id);
      },
      label: context.l10n.open,
    ),
  );
}
