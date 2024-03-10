import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app.dart';
import '../../build_context_x.dart';
import '../../globals.dart';
import 'common_widgets.dart';
import 'package:yaru/yaru.dart';

import '../l10n/l10n.dart';

class OfflinePage extends ConsumerWidget {
  const OfflinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showWindowControls =
        ref.watch(appModelProvider.select((v) => v.showWindowControls));
    final theme = context.t;
    return YaruDetailPage(
      appBar: HeaderBar(
        style: showWindowControls
            ? YaruTitleBarStyle.normal
            : YaruTitleBarStyle.undecorated,
        title: Text(context.l10n.offline),
        backgroundColor: Colors.transparent,
        leading: navigatorKey.currentState?.canPop() == true
            ? const NavBackButton()
            : const SizedBox.shrink(),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            YaruAnimatedVectorIcon(
              YaruAnimatedIcons.no_network,
              size: 200,
              color: theme.disabledColor,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: kYaruPagePadding,
                left: 40,
                right: 40,
              ),
              child: Text(
                context.l10n.offlineDescription,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.disabledColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
