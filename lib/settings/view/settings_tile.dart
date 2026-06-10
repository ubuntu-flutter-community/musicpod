import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/yaru.dart';

import '../../app/app_manager.dart';

import '../../app/routing_manager.dart';
import '../../app/app_config.dart';
import '../../app/page_ids.dart';
import '../../common/view/global_keys.dart';
import '../../common/view/icons.dart';
import '../../common/view/progress.dart';
import '../../extensions/build_context_x.dart';

class SettingsTile extends StatelessWidget with WatchItMixin {
  const SettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedPageId = watchPropertyValue(
      (RoutingManager m) => m.selectedPageId,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: YaruMasterTile(
        selected: selectedPageId == PageIDs.settings,
        leading: Icon(Iconz.settings),
        title: Text(context.l10n.settings),
        onTap: () {
          masterScaffoldKey.currentState
            ?..closeEndDrawer()
            ..closeDrawer();

          di<RoutingManager>().push(pageId: PageIDs.settings);
        },
        trailing: (di<AppManager>().allowManualUpdate)
            ? const _UpdateButton()
            : null,
      ),
    );
  }
}

class _UpdateButton extends StatelessWidget with WatchItMixin {
  const _UpdateButton();

  @override
  Widget build(BuildContext context) {
    if (!di<AppManager>().checkForUpdateCommand.results.value.hasData) {
      callOnceAfterThisBuild(
        (context) => di<AppManager>().checkForUpdateCommand.run(),
      );
    }

    return watchValue(
      (AppManager m) => m.checkForUpdateCommand.results,
    ).toWidget(
      whileRunning: (lastResult, param) => SizedBox.square(
        dimension: context.buttonHeight * 0.6,
        child: const Progress(),
      ),
      onError: (error, param, _) => IconButton(
        tooltip: error.toString(),
        onPressed: di<AppManager>().checkForUpdateCommand,
        icon: Icon(Iconz.warning),
      ),
      onData: (result, param) => switch (result) {
        true => IconButton(
          tooltip: context.l10n.updateAvailable,
          onPressed: () => launchUrl(
            Uri.parse(
              p.join(
                AppConfig.repoUrl,
                'releases',
                'tag',
                di<AppManager>().onlineVersion.value,
              ),
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
