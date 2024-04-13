import 'package:watch_it/watch_it.dart';

import '../../app.dart';
import '../../common.dart';
import '../l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

class ExploreOnlinePopup extends StatelessWidget with WatchItMixin {
  const ExploreOnlinePopup({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final isOnline = watchPropertyValue((AppModel m) => m.isOnline);
    return YaruPopupMenuButton(
      enabled: isOnline,
      tooltip: context.l10n.searchOnline,
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(100),
        ),
      ),
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
      child: Icon(Iconz().explore),
    );
  }
}
