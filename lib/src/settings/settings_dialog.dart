import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:provider/provider.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../globals.dart';
import '../../l10n.dart';
import '../../library.dart';
import '../../local_audio.dart';
import '../../theme_mode_x.dart';
import 'settings_model.dart';
import 'theme_tile.dart';

const _kTileSize = 50.0;

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Navigator(
      onPopPage: (route, result) => route.didPop(result),
      key: settingsNavigatorKey,
      initialRoute: '/settings',
      onGenerateRoute: (settings) {
        Widget page = switch (settings.name) {
          '/settings' => const _SettingsPage(),
          '/about' => const _AboutDialog(),
          '/licenses' => const _LicensePage(),
          _ => const _SettingsPage()
        };

        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 500),
        );
      },
    );

    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.background,
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      content: SizedBox(height: 800, width: 600, child: nav),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        YaruDialogTitleBar(
          onClose: (p0) => Navigator.of(rootNavigator: true, context).pop(),
          title: Text(context.l10n.settings),
        ),
        Expanded(
          child: ListView(
            children: const [
              ThemeSection(),
              PodcastSection(),
              LocalAudioSection(),
              AboutSection(),
            ],
          ),
        ),
      ],
    );
  }
}

class AboutSection extends StatelessWidget {
  const AboutSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final model = context.read<SettingsModel>();

    return YaruSection(
      headline: Text('${context.l10n.about} ${model.appName}'),
      margin: const EdgeInsets.all(kYaruPagePadding),
      child: const Column(
        children: [_AboutTile(), _LicenseTile()],
      ),
    );
  }
}

class LocalAudioSection extends StatelessWidget {
  const LocalAudioSection({super.key});

  @override
  Widget build(BuildContext context) {
    final libraryModel = context.read<LibraryModel>();
    final localAudioModel = context.read<LocalAudioModel>();
    final directory =
        context.select((LocalAudioModel m) => localAudioModel.directory ?? '');

    Future<void> onDirectorySelected(String? directoryPath) async {
      localAudioModel.setDirectory(directoryPath).then(
            (value) async => await localAudioModel.init(
              forceInit: true,
              onFail: (failedImports) {
                if (libraryModel.neverShowFailedImports) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 10),
                    content: FailedImportsContent(
                      failedImports: failedImports,
                      onNeverShowFailedImports:
                          libraryModel.setNeverShowLocalImports,
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
            leading: Text(directory),
            trailing: ImportantButton(
              onPressed: () async {
                final directoryPath = await getDirectoryPath();
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

class ThemeSection extends StatefulWidget {
  const ThemeSection({super.key});

  @override
  State<ThemeSection> createState() => _ThemeSectionState();
}

class _ThemeSectionState extends State<ThemeSection> {
  @override
  Widget build(BuildContext context) {
    final model = context.read<SettingsModel>();

    void onChanged(int index) {
      model.setThemeIndex(index);
      setState(() => themeNotifier.value = ThemeMode.values[index]);
    }

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
                      selected: themeNotifier.value == ThemeMode.values[i],
                      onTap: () => onChanged(i),
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

class _AboutTile extends StatelessWidget {
  const _AboutTile();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SettingsModel>();

    return YaruTile(
      title: Text(
        '${context.l10n.version}: ${model.version}',
      ),
      trailing: OutlinedButton(
        onPressed: () => settingsNavigatorKey.currentState!.pushNamed('/about'),
        child: Text(context.l10n.contributors),
      ),
    );
  }
}

class _AboutDialog extends StatelessWidget {
  const _AboutDialog();

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final linkStyle = theme.textTheme.bodyLarge
        ?.copyWith(color: Colors.lightBlue, overflow: TextOverflow.visible);
    const maxLines = 3;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          YaruDialogTitleBar(
            leading: YaruBackButton(
              style: YaruBackButtonStyle.rounded,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(kYaruPagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TapAbleText(
                    text:
                        'MusicPod is made by Frederik Feichtmeier. If you like MusicPod, please sponsor me!',
                    onTap: () => launchUrl(Uri.parse(kSponsorLink)),
                    style: linkStyle,
                    maxLines: maxLines,
                  ),
                  const SizedBox(
                    height: kYaruPagePadding,
                  ),
                  TapAbleText(
                    onTap: () =>
                        launchUrl(Uri.parse('https://ko-fi.com/amugofjava')),
                    text:
                        'The Podcast Dart Library is made by Ben Hills, please sponsor him!',
                    style: linkStyle,
                    maxLines: maxLines,
                  ),
                  const SizedBox(
                    height: kYaruPagePadding,
                  ),
                  TapAbleText(
                    onTap: () =>
                        launchUrl(Uri.parse('https://github.com/kenvandine')),
                    text: 'Snap packaging by Ken VanDine, please sponsor him!',
                    style: linkStyle,
                    maxLines: maxLines,
                  ),
                  const SizedBox(
                    height: 2 * kYaruPagePadding,
                  ),
                  Text(
                    context.l10n.contributors,
                    style: theme.textTheme.bodyLarge,
                  ),
                  Expanded(
                    child: FutureBuilder<List<Contributor>>(
                      future: _loadContributors(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return SizedBox(
                            height: 300,
                            width: 400,
                            child: GridView.builder(
                              padding:
                                  const EdgeInsets.only(bottom: 20, top: 10),
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: _kTileSize,
                                mainAxisExtent: _kTileSize,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                              ),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                final e = snapshot.data!.elementAt(index);
                                return InkWell(
                                  borderRadius: BorderRadius.circular(100),
                                  onTap: e.htmlUrl == null
                                      ? null
                                      : () => launchUrl(Uri.parse(e.htmlUrl!)),
                                  child: CircleAvatar(
                                    backgroundImage: e.avatarUrl != null
                                        ? NetworkImage(
                                            e.avatarUrl!,
                                          )
                                        : null,
                                    child: e.avatarUrl == null
                                        ? const YaruPlaceholderIcon(
                                            size: Size.square(_kTileSize),
                                          )
                                        : null,
                                  ),
                                );
                              },
                            ),
                          );
                        } else {
                          return const Center(
                            child: Progress(),
                          );
                        }
                      },
                    ),
                  ),
                  TapAbleText(
                    style: linkStyle,
                    onTap: () => launchUrl(Uri.parse(kRepoUrl)),
                    text:
                        'Copyright by Frederik Feichtmeier 2023 and onwards - all rights reserved.',
                    maxLines: maxLines,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Contributor>> _loadContributors() async {
    final github = getService<GitHub>();
    return (await github.repositories
        .listContributors(
          RepositorySlug.full(kGitHubShortLink),
        )
        .where((c) => c.type == 'User')
        .toList());
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
            settingsNavigatorKey.currentState!.pushNamed('/licenses'),
        child: Text(context.l10n.dependencies),
      ),
      enabled: true,
    );
  }
}

class _LicensePage extends StatelessWidget {
  const _LicensePage();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8.0),
          bottomRight: Radius.circular(8.0),
        ),
        child: Column(
          children: [
            const YaruDialogTitleBar(),
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  pageTransitionsTheme:
                      YaruMasterDetailTheme.of(context).landscapeTransitions,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(kYaruPagePadding),
                  child: LicensePage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PodcastSection extends StatelessWidget {
  const PodcastSection({super.key});

  @override
  Widget build(BuildContext context) {
    // final model = context.read<SettingsModel>();
    final usePodcastIndex =
        context.select((SettingsModel m) => m.usePodcastIndex);
    return YaruSection(
      margin: const EdgeInsets.all(kYaruPagePadding),
      headline: Text(context.l10n.podcasts),
      child: Column(
        children: [
          YaruTile(
            leading: Text(context.l10n.usePodcastIndex),
            trailing: CommonSwitch(
              value: usePodcastIndex,
              // TODO: implement podcastindex
              // onChanged: model.setUsePodcastIndex,
            ),
          ),
        ],
      ),
    );
  }
}
