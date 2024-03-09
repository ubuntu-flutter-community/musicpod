import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../common.dart';
import '../../globals.dart';
import '../../l10n.dart';
import 'radio_discover_page.dart';

class OpenRadioDiscoverPageButton extends ConsumerWidget {
  const OpenRadioDiscoverPageButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline =
        ref.watch(appModelProvider.select((value) => value.isOnline));
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
