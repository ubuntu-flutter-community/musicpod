import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/app_manager.dart';
import '../../app/routing_manager.dart';
import '../../app/page_ids.dart';
import '../../l10n/l10n.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
showAddedToPlaylistSnackBar({
  required BuildContext context,
  required String id,
}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        '${context.l10n.addedTo} ${id == PageIDs.likedAudios ? context.l10n.likedSongs : id}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
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
    ),
  );
}
