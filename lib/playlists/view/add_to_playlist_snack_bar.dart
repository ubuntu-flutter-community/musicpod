import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/app_model.dart';
import '../../app/view/routing_manager.dart';
import '../../common/page_ids.dart';
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
          final appModel = di<AppModel>();
          if (appModel.fullWindowMode == true) {
            appModel.setFullWindowMode(false);
          }
          di<RoutingManager>().push(pageId: id);
        },
        label: context.l10n.open,
      ),
    ),
  );
}
