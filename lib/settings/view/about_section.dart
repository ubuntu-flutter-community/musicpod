import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/app_model.dart';
import '../../app/connectivity_model.dart';
import '../../app_config.dart';
import '../../common/view/global_keys.dart';
import '../../common/view/progress.dart';
import '../../common/view/snackbars.dart';
import '../../common/view/tapable_text.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import 'about_page.dart';

class AboutSection extends StatelessWidget with WatchItMixin {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final text = '${context.l10n.about} ${AppConfig.appTitle}';
    return YaruSection(
      headline: Text(text),
      margin: const EdgeInsets.all(kLargestSpace),
      child: const Column(
        children: [_AboutTile(), _LicenseTile()],
      ),
    );
  }
}

class _AboutTile extends StatefulWidget with WatchItStatefulWidgetMixin {
  const _AboutTile();

  @override
  State<_AboutTile> createState() => _AboutTileState();
}

class _AboutTileState extends State<_AboutTile> {
  @override
  void initState() {
    super.initState();
    di<AppModel>().checkForUpdate(
      isOnline: di<ConnectivityModel>().isOnline == true,
      onError: (e) {
        if (mounted) {
          showSnackBar(context: context, content: Text(e));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final appModel = di<AppModel>();
    final updateAvailable =
        watchPropertyValue((AppModel m) => m.updateAvailable);
    final onlineVersion = watchPropertyValue((AppModel m) => m.onlineVersion);
    final currentVersion = watchPropertyValue((AppModel m) => m.version);

    return YaruTile(
      title: !di<ConnectivityModel>().isOnline == true ||
              !appModel.allowManualUpdate
          ? Text(di<AppModel>().version)
          : updateAvailable == null
              ? Center(
                  child: SizedBox.square(
                    dimension:
                        AppConfig.yaruStyled ? kYaruTitleBarItemHeight : 40,
                    child: const Progress(
                      padding: EdgeInsets.all(10),
                    ),
                  ),
                )
              : TapAbleText(
                  text: updateAvailable == true
                      ? '${context.l10n.updateAvailable}: $onlineVersion'
                      : currentVersion,
                  style: updateAvailable == true
                      ? TextStyle(
                          color: context.theme.colorScheme.success
                              .scale(lightness: theme.isLight ? 0 : 0.3),
                        )
                      : null,
                  onTap: () => launchUrl(
                    Uri.parse(
                      p.join(
                        AppConfig.repoUrl,
                        'releases',
                        'tag',
                        onlineVersion,
                      ),
                    ),
                  ),
                ),
      trailing: OutlinedButton(
        onPressed: () => AppConfig.isMobilePlatform
            ? di<LibraryModel>().push(
                pageId: 'about',
                builder: (p0) => const AboutPage(),
              )
            : settingsNavigatorKey.currentState?.pushNamed('/about'),
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
      title: TapAbleText(
        text: '${context.l10n.license}: GPL3',
      ),
      trailing: OutlinedButton(
        onPressed: () => AppConfig.isMobilePlatform
            ? di<LibraryModel>().push(
                pageId: 'licenses',
                builder: (p0) => const LicensePage(),
              )
            : settingsNavigatorKey.currentState?.pushNamed('/licenses'),
        child: Text(context.l10n.dependencies),
      ),
      enabled: true,
    );
  }
}
