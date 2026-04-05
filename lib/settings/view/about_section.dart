import 'package:flutter/material.dart' hide AboutDialog, LicensePage;
import 'package:flutter_it/flutter_it.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/yaru.dart';

import '../../app/app_manager.dart';
import '../../app/connectivity_manager.dart';
import '../../app/app_config.dart';
import '../../common/view/progress.dart';
import '../../common/view/tapable_text.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../l10n/l10n.dart';
import '../settings_model.dart';
import 'about_page.dart';
import 'licenses_dialog.dart';

class AboutSection extends StatelessWidget with WatchItMixin {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final text = '${context.l10n.about} ${AppConfig.appTitle}';
    return YaruSection(
      headline: Text(text),
      margin: const EdgeInsets.all(kLargestSpace),
      child: const Column(children: [_AboutTile(), _LicenseTile()]),
    );
  }
}

class _AboutTile extends StatelessWidget with WatchItMixin {
  const _AboutTile();

  @override
  Widget build(BuildContext context) {
    callOnceAfterThisBuild((context) {
      final appManager = di<AppManager>();
      appManager.checkForUpdateCommand.run();
      appManager.fetchNumberOfDownloadsCommand.run();
    });

    final theme = context.theme;
    final appManager = di<AppManager>();
    final updateAvailableResults = watchValue(
      (AppManager m) => m.checkForUpdateCommand.results,
    );
    final updateAvailable = updateAvailableResults.data == true;
    final onlineVersion = watchValue((AppManager m) => m.onlineVersion);
    final downloads = watchValue(
      (AppManager m) => m.fetchNumberOfDownloadsCommand,
    );
    final currentVersion = di<AppManager>().version;
    final useYaruTheme = watchPropertyValue(
      (SettingsModel m) => m.useYaruTheme,
    );

    final isOnline = watchValue(
      (ConnectivityManager m) =>
          m.connectivityCommand.select((p) => p.isOnline),
    );
    return YaruTile(
      subtitle: Text(
        context.l10n.downloadsOfLatestRelease(downloads.toString()),
      ),
      title: !isOnline || !appManager.allowManualUpdate
          ? Text(di<AppManager>().version)
          : updateAvailableResults.isRunning
          ? Center(
              child: SizedBox.square(
                dimension: useYaruTheme ? kYaruTitleBarItemHeight : 40,
                child: const Progress(padding: EdgeInsets.all(10)),
              ),
            )
          : TapAbleText(
              text: updateAvailable
                  ? '${context.l10n.updateAvailable}: $onlineVersion'
                  : currentVersion,
              style: updateAvailable
                  ? TextStyle(
                      color: context.theme.colorScheme.success.scale(
                        lightness: theme.isLight ? 0 : 0.3,
                      ),
                    )
                  : null,
              onTap: () => launchUrl(
                Uri.parse(
                  p.join(AppConfig.repoUrl, 'releases', 'tag', onlineVersion),
                ),
              ),
            ),
      trailing: OutlinedButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const AboutDialog(),
        ),
        child: Text(context.l10n.contributors),
      ),
    );
  }
}

class _LicenseTile extends StatelessWidget {
  const _LicenseTile();

  @override
  Widget build(BuildContext context) {
    return YaruTile(
      title: TapAbleText(text: '${context.l10n.license}: GPL3'),
      trailing: OutlinedButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const LicensesDialog(),
        ),
        child: Text(context.l10n.dependencies),
      ),
      enabled: true,
    );
  }
}
