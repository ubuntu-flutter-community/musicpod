import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../common.dart';
import '../../../globals.dart';
import '../../../l10n.dart';
import '../../player/player_model.dart';
import 'radio_discover_page.dart';

class OpenRadioDiscoverPageButton extends StatelessWidget with WatchItMixin {
  const OpenRadioDiscoverPageButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isOnline = watchPropertyValue((PlayerModel m) => m.isOnline);
    return ImportantButton(
      onPressed: () {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) =>
                isOnline ? const RadioDiscoverPage() : const OfflinePage(),
          ),
        );
      },
      child: Text(context.l10n.discover),
    );
  }
}
