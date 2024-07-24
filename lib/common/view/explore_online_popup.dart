import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import 'icons.dart';
import 'stream_provider_share_button.dart';

class ExploreOnlinePopup extends StatelessWidget with WatchItMixin {
  const ExploreOnlinePopup({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final isOnline = watchPropertyValue((PlayerModel m) => m.isOnline);
    return PopupMenuButton(
      enabled: isOnline,
      tooltip: context.l10n.searchOnline,
      itemBuilder: (c) => [
        PopupMenuItem(
          padding: const EdgeInsets.only(left: 5),
          child: StreamProviderRow(
            spacing: 5,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            text: text,
          ),
        ),
      ],
      icon: Icon(Iconz().explore),
    );
  }
}
