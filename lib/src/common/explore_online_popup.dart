import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../common.dart';
import '../l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

class ExploreOnlinePopup extends ConsumerWidget {
  const ExploreOnlinePopup({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(appModelProvider.select((v) => v.isOnline));
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
