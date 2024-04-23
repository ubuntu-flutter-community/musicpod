import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/yaru.dart';

import '../../../app.dart';
import '../../../build_context_x.dart';
import '../../../common.dart';
import '../../../constants.dart';
import '../../../get.dart';
import '../../../l10n.dart';
import '../../../local_audio.dart';
import '../../../podcasts.dart';
import '../../../string_x.dart';
import '../../../theme_data_x.dart';
import '../../../theme_mode_x.dart';
import '../../globals.dart';
import '../../theme.dart';
import '../settings_model.dart';
import 'theme_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        YaruDialogTitleBar(
          backgroundColor: context.t.dialogBackgroundColor,
          onClose: (p0) => Navigator.of(rootNavigator: true, context).pop(),
          title: Text(context.l10n.settings),
        ),
        Expanded(
          child: ListView(
            children: const [
              _ThemeSection(),
              _PodcastSection(),
              _LocalAudioSection(),
              _AboutSection(),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeSection extends StatelessWidget with WatchItMixin {
  const _ThemeSection();

  @override
  Widget build(BuildContext context) {
    final model = getIt<SettingsModel>();

    final themeIndex = watchPropertyValue((SettingsModel m) => m.themeIndex);
    return YaruSection(
      margin: const EdgeInsets.only(
        left: kYaruPagePadding,
        top: kYaruPagePadding,
        right: kYaruPagePadding,
      ),
      headline: Text(context.l10n.theme),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: kYaruPagePadding),
          child: Wrap(
            spacing: kYaruPagePadding,
            children: [
              for (var i = 0; i < ThemeMode.values.length; ++i)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    YaruSelectableContainer(
                      padding: const EdgeInsets.all(1),
                      borderRadius: BorderRadius.circular(15),
                      selected: themeIndex == i,
                      onTap: () => model.setThemeIndex(i),
                      child: ThemeTile(ThemeMode.values[i]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(ThemeMode.values[i].localize(context.l10n)),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PodcastSection extends StatefulWidget with WatchItStatefulWidgetMixin {
  const _PodcastSection();

  @override
  State<_PodcastSection> createState() => _PodcastSectionState();
}

class _PodcastSectionState extends State<_PodcastSection> {
  String? _initialKey;
  String? _initialSecret;
  late TextEditingController _keyController, _secretController;

  @override
  void initState() {
    super.initState();
    final model = getIt<SettingsModel>();
    _initialKey = model.podcastIndexApiKey;
    _keyController = TextEditingController(text: _initialKey);
    _initialSecret = model.podcastIndexApiSecret;
    _secretController = TextEditingController(text: _initialSecret);
  }

  @override
  void dispose() {
    _keyController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final model = getIt<SettingsModel>();
    final usePodcastIndex =
        watchPropertyValue((SettingsModel m) => m.usePodcastIndex);
    final podcastIndexApiKey =
        watchPropertyValue((SettingsModel m) => m.podcastIndexApiKey);
    final podcastIndexApiSecret =
        watchPropertyValue((SettingsModel m) => m.podcastIndexApiSecret);

    return YaruSection(
      margin: const EdgeInsets.all(kYaruPagePadding),
      headline: Text(context.l10n.podcasts),
      child: Column(
        children: [
          YaruTile(
            title: Text(context.l10n.usePodcastIndex),
            trailing: CommonSwitch(
              value: usePodcastIndex,
              onChanged: (v) => model.setUsePodcastIndex(v).then(
                    (_) => getIt<PodcastModel>().init(
                      forceInit: true,
                      countryCode: getIt<AppModel>().countryCode,
                      updateMessage: context.l10n.newEpisodeAvailable,
                    ),
                  ),
            ),
          ),
          if (usePodcastIndex)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _keyController,
                onChanged: (v) => setState(() => _initialKey = v),
                obscureText: true,
                decoration: InputDecoration(
                  label: Text(kPodcastIndexApiKey.camelToSentence),
                  suffixIcon: IconButton(
                    tooltip: context.l10n.save,
                    onPressed: () =>
                        model.setPodcastIndexApiKey(_keyController.text),
                    icon: Icon(
                      Iconz().check,
                      color: podcastIndexApiKey == _initialKey
                          ? theme.colorScheme.success
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          if (usePodcastIndex)
            Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
                bottom: kYaruPagePadding,
              ),
              child: TextField(
                controller: _secretController,
                onChanged: (v) => setState(() => _initialSecret = v),
                obscureText: true,
                decoration: InputDecoration(
                  label: Text(kPodcastIndexApiSecret.camelToSentence),
                  suffixIcon: IconButton(
                    tooltip: context.l10n.save,
                    onPressed: () =>
                        model.setPodcastIndexApiSecret(_secretController.text),
                    icon: Icon(
                      Iconz().check,
                      color: podcastIndexApiSecret == _initialSecret
                          ? theme.colorScheme.success
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LocalAudioSection extends StatelessWidget with WatchItMixin {
  const _LocalAudioSection();

  @override
  Widget build(BuildContext context) {
    final settingsModel = getIt<SettingsModel>();
    final localAudioModel = getIt<LocalAudioModel>();
    final directory =
        watchPropertyValue((SettingsModel m) => m.directory ?? '');

    Future<void> onDirectorySelected(String? directoryPath) async {
      settingsModel.setDirectory(directoryPath).then(
            (value) async => await localAudioModel.init(
              forceInit: true,
              onFail: (failedImports) {
                if (settingsModel.neverShowFailedImports) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 10),
                    content: FailedImportsContent(
                      failedImports: failedImports,
                      onNeverShowFailedImports: () =>
                          settingsModel.setNeverShowFailedImports(true),
                    ),
                  ),
                );
              },
            ),
          );
    }

    return YaruSection(
      headline: Text(context.l10n.localAudio),
      margin: const EdgeInsets.symmetric(horizontal: kYaruPagePadding),
      child: Column(
        children: [
          YaruTile(
            title: Text(context.l10n.musicCollectionLocation),
            subtitle: Text(directory),
            trailing: ImportantButton(
              onPressed: () async {
                final directoryPath = await settingsModel.getPathOfDirectory();
                await onDirectorySelected(directoryPath);
              },
              child: Text(
                context.l10n.select,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget with WatchItMixin {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final appName = watchPropertyValue((SettingsModel m) => m.appName);

    final text = '${context.l10n.about} ${appName ?? ''}';
    return YaruSection(
      headline: Text(text),
      margin: const EdgeInsets.all(kYaruPagePadding),
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
    final settingsModel = getIt<SettingsModel>();
    if (settingsModel.allowManualUpdate && getIt<AppModel>().isOnline) {
      settingsModel.checkForUpdate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final settingsModel = getIt<SettingsModel>();
    final appModel = getIt<AppModel>();
    final updateAvailable =
        watchPropertyValue((SettingsModel m) => m.updateAvailable);
    final onlineVersion =
        watchPropertyValue((SettingsModel m) => m.onlineVersion);
    final currentVersion = watchPropertyValue((SettingsModel m) => m.version);

    return YaruTile(
      title: !appModel.isOnline || !settingsModel.allowManualUpdate
          ? Text(settingsModel.version ?? '')
          : updateAvailable == null
              ? Center(
                  child: SizedBox.square(
                    dimension: yaruStyled ? kYaruTitleBarItemHeight : 40,
                    child: const Progress(
                      padding: EdgeInsets.all(10),
                    ),
                  ),
                )
              : TapAbleText(
                  text: updateAvailable == true
                      ? '${context.l10n.updateAvailable}: $onlineVersion'
                      : currentVersion ?? context.l10n.unknown,
                  style: updateAvailable == true
                      ? TextStyle(
                          color: context.t.colorScheme.success
                              .scale(lightness: theme.isLight ? 0 : 0.3),
                        )
                      : null,
                  onTap: () => launchUrl(
                    Uri.parse(
                      p.join(
                        kRepoUrl,
                        'releases',
                        'tag',
                        onlineVersion,
                      ),
                    ),
                  ),
                ),
      trailing: OutlinedButton(
        onPressed: () => settingsNavigatorKey.currentState?.pushNamed('/about'),
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
        onPressed: () =>
            settingsNavigatorKey.currentState?.pushNamed('/licenses'),
        child: Text(context.l10n.dependencies),
      ),
      enabled: true,
    );
  }
}
