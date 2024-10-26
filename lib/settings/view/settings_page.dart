import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/app_model.dart';
import '../../app/connectivity_model.dart';
import '../../app_config.dart';
import '../../common/data/close_btn_action.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/drop_down_arrow.dart';
import '../../common/view/global_keys.dart';
import '../../common/view/icons.dart';
import '../../common/view/progress.dart';
import '../../common/view/snackbars.dart';
import '../../common/view/tapable_text.dart';
import '../../common/view/theme.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/string_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../extensions/theme_mode_x.dart';
import '../../l10n/l10n.dart';
import '../../local_audio/local_audio_model.dart';
import '../../podcasts/download_model.dart';
import '../../podcasts/podcast_model.dart';
import '../settings_model.dart';
import 'theme_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        YaruDialogTitleBar(
          border: BorderSide.none,
          backgroundColor: context.theme.dialogBackgroundColor,
          onClose: (p0) => Navigator.of(rootNavigator: true, context).pop(),
          title: Text(context.l10n.settings),
        ),
        Expanded(
          child: ListView(
            children: const [
              _ThemeSection(),
              _PodcastSection(),
              _LocalAudioSection(),
              _ExposeOnlineSection(),
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
    final model = di<SettingsModel>();
    final l10n = context.l10n;
    final themeIndex = watchPropertyValue((SettingsModel m) => m.themeIndex);
    return YaruSection(
      margin: const EdgeInsets.only(
        left: kYaruPagePadding,
        top: kYaruPagePadding,
        right: kYaruPagePadding,
      ),
      headline: Text(l10n.theme),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
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
                          selectionColor: context.theme.colorScheme.primary,
                          child: ThemeTile(ThemeMode.values[i]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              Text(ThemeMode.values[i].localize(context.l10n)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          YaruTile(
            title: Text(l10n.useMoreAnimationsTitle),
            subtitle: Text(l10n.useMoreAnimationsDescription),
            trailing: CommonSwitch(
              onChanged: di<SettingsModel>().setUseMoreAnimations,
              value:
                  watchPropertyValue((SettingsModel m) => m.useMoreAnimations),
            ),
          ),
        ],
      ),
    );
  }
}

// TODO: figure out how to show the window from clicking the dock icon in macos, windows and linux
// Also figure out how to show the window again, when the gtk window is triggered from the outside (open with)
// if we can not figure this out, we can not land this feature.
// ignore: unused_element
class _CloseActionSection extends StatelessWidget with WatchItMixin {
  const _CloseActionSection();

  @override
  Widget build(BuildContext context) {
    final model = di<SettingsModel>();

    final closeBtnAction =
        watchPropertyValue((SettingsModel m) => m.closeBtnActionIndex);
    return YaruSection(
      margin: const EdgeInsets.only(
        left: kYaruPagePadding,
        top: kYaruPagePadding,
        right: kYaruPagePadding,
      ),
      headline: Text(context.l10n.closeBtnAction),
      child: Column(
        children: [
          YaruTile(
            title: Text(context.l10n.whenCloseBtnClicked),
            trailing: YaruPopupMenuButton<CloseBtnAction>(
              icon: const DropDownArrow(),
              initialValue: closeBtnAction,
              child: Text(closeBtnAction.localize(context.l10n)),
              onSelected: (value) {
                model.setCloseBtnActionIndex(value);
              },
              itemBuilder: (context) {
                return [
                  for (var i = 0; i < CloseBtnAction.values.length; ++i)
                    PopupMenuItem(
                      value: CloseBtnAction.values[i],
                      child:
                          Text(CloseBtnAction.values[i].localize(context.l10n)),
                    ),
                ];
              },
            ),
          ),
        ],
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
    final model = di<SettingsModel>();
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
    final theme = context.theme;
    final l10n = context.l10n;
    final model = di<SettingsModel>();
    final usePodcastIndex =
        watchPropertyValue((SettingsModel m) => m.usePodcastIndex);
    final podcastIndexApiKey =
        watchPropertyValue((SettingsModel m) => m.podcastIndexApiKey);
    final podcastIndexApiSecret =
        watchPropertyValue((SettingsModel m) => m.podcastIndexApiSecret);

    return YaruSection(
      margin: const EdgeInsets.all(kYaruPagePadding),
      headline: Text(l10n.podcasts),
      child: Column(
        children: [
          const _DownloadsTile(),
          YaruTile(
            title: Text(l10n.usePodcastIndex),
            trailing: CommonSwitch(
              value: usePodcastIndex,
              onChanged: (v) async {
                await model.setUsePodcastIndex(v);
                if (context.mounted) {
                  di<PodcastModel>().init(
                    forceInit: true,
                    updateMessage: l10n.newEpisodeAvailable,
                  );
                }
              },
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
                    tooltip: l10n.save,
                    onPressed: () =>
                        model.setPodcastIndexApiKey(_keyController.text),
                    icon: Icon(
                      Iconz.check,
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
                    tooltip: l10n.save,
                    onPressed: () =>
                        model.setPodcastIndexApiSecret(_secretController.text),
                    icon: Icon(
                      Iconz.check,
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

class _DownloadsTile extends StatefulWidget with WatchItStatefulWidgetMixin {
  const _DownloadsTile();

  @override
  State<_DownloadsTile> createState() => _DownloadsTileState();
}

class _DownloadsTileState extends State<_DownloadsTile> {
  String? _error;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return YaruTile(
      title: Text(l10n.downloadsDirectory),
      subtitle: Text(
        _error ?? watchPropertyValue((SettingsModel m) => m.downloadsDir ?? ''),
      ),
      trailing: ImportantButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: SizedBox(
                width: 300,
                child: Text(
                  l10n.downloadsChangeWarning,
                  style: context.textTheme.bodyLarge,
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: Navigator.of(context).pop,
                  child: Text(l10n.cancel),
                ),
                ImportantButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    di<SettingsModel>().setDownloadsCustomDir(
                      onSuccess: () => di<DownloadModel>().deleteAllDownloads(),
                      onFail: (e) => setState(() => _error = e.toString()),
                    );
                  },
                  child: Text(l10n.ok),
                ),
              ],
            ),
          );
        },
        child: Text(
          l10n.select,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _LocalAudioSection extends StatelessWidget with WatchItMixin {
  const _LocalAudioSection();

  @override
  Widget build(BuildContext context) {
    final settingsModel = di<SettingsModel>();
    final localAudioModel = di<LocalAudioModel>();
    final directory =
        watchPropertyValue((SettingsModel m) => m.directory ?? '');

    Future<void> onDirectorySelected(String directoryPath) async {
      settingsModel.setDirectory(directoryPath).then(
            (_) async => localAudioModel.init(
              forceInit: true,
              directory: directoryPath,
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
                if (directoryPath != null) {
                  await onDirectorySelected(directoryPath);
                }
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
    final text = '${context.l10n.about} $kAppTitle';
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
          ? Text(di<AppModel>().version ?? '')
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
                          color: context.theme.colorScheme.success
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

class _ExposeOnlineSection extends StatelessWidget with WatchItMixin {
  const _ExposeOnlineSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final discordEnabled = allowDiscordRPC
        ? watchPropertyValue((SettingsModel m) => m.enableDiscordRPC)
        : false;

    return YaruSection(
      headline: Text(l10n.exposeOnlineHeadline),
      margin: const EdgeInsets.only(
        top: kYaruPagePadding,
        right: kYaruPagePadding,
        left: kYaruPagePadding,
      ),
      child: Column(
        children: [
          YaruTile(
            title: Row(
              children: space(
                children: [
                  allowDiscordRPC
                      ? const Icon(
                          TablerIcons.brand_discord_filled,
                        )
                      : Icon(
                          TablerIcons.brand_discord_filled,
                          color: context.theme.disabledColor,
                        ),
                  Text(l10n.exposeToDiscordTitle),
                ],
              ),
            ),
            subtitle: Text(
              allowDiscordRPC
                  ? l10n.exposeToDiscordSubTitle
                  : l10n.featureDisabledOnPlatform,
            ),
            trailing: CommonSwitch(
              value: discordEnabled,
              onChanged: allowDiscordRPC
                  ? (v) {
                      di<SettingsModel>().setEnableDiscordRPC(v);
                      final appModel = di<AppModel>();
                      if (v) {
                        appModel.connectToDiscord();
                      } else {
                        appModel.disconnectFromDiscord();
                      }
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
