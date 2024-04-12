import 'package:flutter/material.dart';

import '../../app.dart';
import '../../common.dart';
import '../../get.dart';
import '../../globals.dart';
import '../../l10n.dart';
import 'radio_discover_page.dart';

class OpenRadioDiscoverPageButton extends StatelessWidget {
  const OpenRadioDiscoverPageButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isOnline = watchPropertyValue((AppModel m) => m.isOnline);
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
