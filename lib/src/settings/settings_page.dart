import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../l10n.dart';
import '../../library.dart';
import '../../local_audio.dart';
import '../../string_x.dart';
import '../../theme_mode_x.dart';
import '../globals.dart';
import 'settings_service.dart';
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

class _ThemeSection extends StatefulWidget {
  const _ThemeSection();

  @override
  State<_ThemeSection> createState() => _ThemeSectionState();
}

class _ThemeSectionState extends State<_ThemeSection> {
  @override
  Widget build(BuildContext context) {
    final service = getService<SettingsService>();

    void onChanged(int index) {
      service.setThemeIndex(index);
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

class _PodcastSection extends StatefulWidget {
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
    final service = getService<SettingsService>();
    _initialKey = service.podcastIndexApiKey.value;
    _keyController = TextEditingController(text: _initialKey);
    _initialSecret = service.podcastIndexApiSecret.value;
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
    final service = getService<SettingsService>();
    final usePodcastIndex = service.usePodcastIndex;

    final podcastIndexApiKey = service.podcastIndexApiKey;
    final podcastIndexApiSecret = service.podcastIndexApiSecret;

    return YaruSection(
      margin: const EdgeInsets.all(kYaruPagePadding),
      headline: Text(context.l10n.podcasts),
      child: Column(
        children: [
          YaruTile(
            title: Text(context.l10n.usePodcastIndex),
            subtitle: Text(context.l10n.requiresAppRestart),
            trailing: Watch.builder(
              builder: (context) {
                return CommonSwitch(
                  value: usePodcastIndex.value,
                  onChanged: service.setUsePodcastIndex,
                );
              },
            ),
          ),
          if (usePodcastIndex.value)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _keyController,
                onChanged: (v) => setState(() => _initialKey = v),
                obscureText: true,
                decoration: InputDecoration(
                  label: Text(kPodcastIndexApiKey.camelToSentence()),
                  suffixIcon: IconButton(
                    tooltip: context.l10n.save,
                    onPressed: () =>
                        service.setPodcastIndexApiKey(_keyController.text),
                    icon: Watch.builder(
                      builder: (context) {
                        return Icon(
                          Iconz().check,
                          color: podcastIndexApiKey.value == _initialKey
                              ? theme.colorScheme.success
                              : theme.colorScheme.onSurface,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          if (usePodcastIndex.value)
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
                  label: Text(kPodcastIndexApiSecret.camelToSentence()),
                  suffixIcon: IconButton(
                    tooltip: context.l10n.save,
                    onPressed: () => service
                        .setPodcastIndexApiSecret(_secretController.text),
                    icon: Watch.builder(
                      builder: (context) {
                        return Icon(
                          Iconz().check,
                          color: podcastIndexApiSecret.value == _initialSecret
                              ? theme.colorScheme.success
                              : theme.colorScheme.onSurface,
                        );
                      },
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

class _LocalAudioSection extends StatelessWidget {
  const _LocalAudioSection();

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
            title: Text(context.l10n.musicCollectionLocation),
            subtitle: Text(directory),
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

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final service = getService<SettingsService>();
    final appName = service.appName;

    final text = '${context.l10n.about} ${appName.value ?? ''}';
    return Watch.builder(
      builder: (context) {
        return YaruSection(
          headline: Text(text),
          margin: const EdgeInsets.all(kYaruPagePadding),
          child: Column(
            children: [_AboutTile(text: text), const _LicenseTile()],
          ),
        );
      },
    );
  }
}

class _AboutTile extends StatelessWidget {
  const _AboutTile({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return YaruTile(
      title: Text(text),
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
