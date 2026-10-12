import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/yaru.dart';

import '../../app/app_config.dart';
import '../../app/latest_release_manager.dart';
import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/view/global_keys.dart';
import '../../common/view/icons.dart';
import '../../common/view/progress.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';

class SettingsTile extends ConsumerWidget {
  const SettingsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPageId = ref.watch(routingManagerProvider);

    return Material(
      color: context.theme.scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsetsGeometry.all(kMediumSpace),
        child: ListTile(
          selected: selectedPageId == PageIDs.settings,
          leading: Icon(Iconz.settings),
          title: Text(context.l10n.settings),
          onTap: () {
            masterScaffoldKey.currentState
              ?..closeEndDrawer()
              ..closeDrawer();

            ref
                .read(routingManagerProvider.notifier)
                .push(pageId: PageIDs.settings);
          },
          trailing: (AppConfig.allowManualUpdate)
              ? const _UpdateButton()
              : null,
        ),
      ),
    );
  }
}

class _UpdateButton extends ConsumerWidget {
  const _UpdateButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final releaseAsync = ref.watch(latestReleaseManagerProvider);

    return releaseAsync.when(
      loading: () => SizedBox.square(
        dimension: context.buttonHeight * 0.6,
        child: const Progress(),
      ),
      error: (error, _) => IconButton(
        tooltip: error.toString(),
        onPressed: () =>
            ref.read(latestReleaseManagerProvider.notifier).refresh(),
        icon: Icon(Iconz.warning),
      ),
      data: (state) => switch (state.updateAvailable) {
        true => IconButton(
          tooltip: context.l10n.updateAvailable,
          onPressed: () => launchUrl(
            Uri.parse(
              p.join(AppConfig.repoUrl, 'releases', 'tag', state.onlineVersion),
            ),
          ),
          icon: Icon(
            Iconz.updateAvailable,
            color: context.theme.colorScheme.success,
          ),
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
