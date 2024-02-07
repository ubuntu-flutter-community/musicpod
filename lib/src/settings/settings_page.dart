import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'settings_model.dart';
import 'theme_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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

class _ThemeSection extends ConsumerStatefulWidget {
  const _ThemeSection();

  @override
  ConsumerState<_ThemeSection> createState() => _ThemeSectionState();
}

class _ThemeSectionState extends ConsumerState<_ThemeSection> {
  @override
  Widget build(BuildContext context) {
    final model = ref.read(settingsModelProvider);

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

class _PodcastSection extends ConsumerStatefulWidget {
  const _PodcastSection();

  @override
  ConsumerState<_PodcastSection> createState() => _PodcastSectionState();
}

class _PodcastSectionState extends ConsumerState<_PodcastSection> {
  String? _initialKey;
  String? _initialSecret;
  late TextEditingController _keyController, _secretController;

  @override
  void initState() {
    super.initState();
    final model = ref.read(settingsModelProvider);
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
    final model = ref.read(settingsModelProvider);
    final usePodcastIndex =
        ref.watch(settingsModelProvider.select((p) => p.usePodcastIndex));
    final podcastIndexApiKey =
        ref.watch(settingsModelProvider.select((p) => p.podcastIndexApiKey));
    final podcastIndexApiSecret =
        ref.watch(settingsModelProvider.select((p) => p.podcastIndexApiSecret));

    return YaruSection(
      margin: const EdgeInsets.all(kYaruPagePadding),
      headline: Text(context.l10n.podcasts),
      child: Column(
        children: [
          YaruTile(
            title: Text(context.l10n.usePodcastIndex),
            subtitle: Text(context.l10n.requiresAppRestart),
            trailing: CommonSwitch(
              value: usePodcastIndex,
              onChanged: model.setUsePodcastIndex,
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
                  label: Text(kPodcastIndexApiKey.camelToSentence()),
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
                  label: Text(kPodcastIndexApiSecret.camelToSentence()),
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

class _LocalAudioSection extends ConsumerWidget {
  const _LocalAudioSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryModel = ref.read(libraryModelProvider);
    final localAudioModel = ref.read(localAudioModelProvider);
    final directory =
        ref.watch(localAudioModelProvider.select((p) => p.directory ?? ''));

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
    return Consumer(
      builder: (context, ref, _) {
        final appName =
            ref.watch(settingsModelProvider.select((p) => p.appName));

        final text = '${context.l10n.about} ${appName ?? ''}';
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
