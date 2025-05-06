import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/app_model.dart';
import '../../app/connectivity_model.dart';
import '../../app/view/routing_manager.dart';
import '../../app_config.dart';
import '../../common/page_ids.dart';
import '../../common/view/icons.dart';
import '../../common/view/progress.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../settings_model.dart';

class SettingsTile extends StatelessWidget with WatchItMixin {
  const SettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    Widget? trailing;
    // To not show any progress for Snap/Flatpak
    if (di<ConnectivityModel>().isOnline == true &&
        di<AppModel>().allowManualUpdate) {
      trailing = const _UpdateButton();
    }

    final selectedPageId =
        watchPropertyValue((RoutingManager m) => m.selectedPageId);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Stack(
        children: [
          YaruMasterTile(
            selected: selectedPageId == PageIDs.settings,
            leading: Icon(Iconz.settings),
            title: Text(context.l10n.settings),
            onTap: () => di<RoutingManager>().push(
              pageId: PageIDs.settings,
            ),
          ),
          if (trailing != null) Positioned(right: 15, child: trailing),
        ],
      ),
    );
  }
}

class _UpdateButton extends StatelessWidget with WatchItMixin {
  const _UpdateButton();

  @override
  Widget build(BuildContext context) {
    final useYaruTheme =
        watchPropertyValue((SettingsModel m) => m.useYaruTheme);
    final updateAvailable =
        watchPropertyValue((AppModel m) => m.updateAvailable);
    return switch (updateAvailable) {
      null => Center(
          child: SizedBox.square(
            dimension: useYaruTheme ? kYaruTitleBarItemHeight : 40,
            child: const Progress(
              padding: EdgeInsets.all(10),
            ),
          ),
        ),
      false => const SizedBox.shrink(),
      true => IconButton(
          tooltip: context.l10n.updateAvailable,
          onPressed: () => launchUrl(
            Uri.parse(
              p.join(
                AppConfig.repoUrl,
                'releases',
                'tag',
                di<AppModel>().onlineVersion,
              ),
            ),
          ),
          icon: Icon(
            Iconz.updateAvailable,
            color: context.theme.colorScheme.success,
          ),
        ),
    };
  }
}
