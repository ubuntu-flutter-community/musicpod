import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/app_manager.dart';
import '../../app/routing_manager.dart';
import '../../app/page_ids.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';

void showAddedToPlaylistSnackBar({
  required BuildContext context,
  required String id,
}) {
  if (id == di<RoutingManager>().selectedPageId) {
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
        final appManager = di<AppManager>();
        if (appManager.fullWindowMode == true) {
          appManager.setFullWindowMode(false);
        }
        di<RoutingManager>().push(pageId: id);
      },
      label: context.l10n.open,
    ),
  );
}
