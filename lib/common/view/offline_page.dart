import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import 'header_bar.dart';
import 'ui_constants.dart';

class OfflinePage extends StatelessWidget {
  const OfflinePage({super.key, this.action});
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderBar(
        adaptive: true,
        title: Text(context.l10n.offline),
        backgroundColor: Colors.transparent,
      ),
      body: OfflineBody(action: action),
    );
  }
}

class OfflineBody extends StatelessWidget {
  const OfflineBody({super.key, this.action});

  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Center(
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
              top: kLargestSpace,
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
          if (action != null) action!,
        ],
      ),
    );
  }
}
