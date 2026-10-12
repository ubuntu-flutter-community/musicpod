import 'package:flutter/material.dart' hide AboutDialog, LicensePage;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/yaru.dart';

import '../../app/app_config.dart';
import '../../app/latest_release_manager.dart';
import '../../common/view/progress.dart';
import '../../common/view/tapable_text.dart';
import '../../dependencies.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import 'about_page.dart';
import 'licenses_dialog.dart';
import 'settings_list_tile.dart';
import 'settings_section.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) => SettingsSection(
    heading: '${context.l10n.about} ${AppConfig.appTitle}',
    children: [const _AboutTile(), const _LicenseTile()],
  );
}

class _AboutTile extends ConsumerWidget {
  const _AboutTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final releaseAsync = ref.watch(latestReleaseManagerProvider);
    final currentVersion = di<PackageInfo>().version;

    final downloads = releaseAsync.value?.downloadCount ?? 0;
    final onlineVersion = releaseAsync.value?.onlineVersion;
    final updateAvailable = releaseAsync.value?.updateAvailable ?? false;

    return SettingsListTile(
      position: ListTilePosition.first,
      subtitle: Text(
        context.l10n.downloadsOfLatestRelease(downloads.toString()),
      ),
      title: releaseAsync.hasError || !AppConfig.allowManualUpdate
          ? Text(currentVersion)
          : releaseAsync.isLoading
          ? const SizedBox.square(
              dimension: 15,
              child: Progress(padding: EdgeInsets.all(10), strokeWidth: 2),
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
              onTap: () {
                if (onlineVersion != null) {
                  launchUrl(
                    Uri.parse(
                      p.join(
                        AppConfig.repoUrl,
                        'releases',
                        'tag',
                        onlineVersion,
                      ),
                    ),
                  );
                }
              },
            ),
      trailing: OutlinedButton(
        onPressed: () => context.dialog((context) => const AboutDialog()),
        child: Text(context.l10n.contributors),
      ),
    );
  }
}

class _LicenseTile extends StatelessWidget {
  const _LicenseTile();

  @override
  Widget build(BuildContext context) {
    return SettingsListTile(
      title: TapAbleText(text: '${context.l10n.license}: GPL3'),
      trailing: OutlinedButton(
        onPressed: () => context.dialog((context) => const LicensesDialog()),
        child: Text(context.l10n.dependencies),
      ),
      position: ListTilePosition.last,
    );
  }
}
