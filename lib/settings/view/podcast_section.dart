import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:yaru/yaru.dart';

import '../../common/file_names.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/confirm.dart';
import '../../common/view/icons.dart';
import '../../common/view/ui_constants.dart';
import '../../custom_content/custom_content_model.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/shared_preferences_x.dart';
import '../../extensions/string_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../persistence_utils.dart';
import '../../player/player_service.dart';
import '../../podcasts/download_model.dart';
import '../../podcasts/podcast_model.dart';
import '../settings_model.dart';

class PodcastSection extends StatefulWidget with WatchItStatefulWidgetMixin {
  const PodcastSection({super.key});

  @override
  State<PodcastSection> createState() => _PodcastSectionState();
}

class _PodcastSectionState extends State<PodcastSection> {
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
    final usePodcastIndex = watchPropertyValue(
      (SettingsModel m) => m.usePodcastIndex,
    );
    final podcastIndexApiKey = watchPropertyValue(
      (SettingsModel m) => m.podcastIndexApiKey,
    );
    final podcastIndexApiSecret = watchPropertyValue(
      (SettingsModel m) => m.podcastIndexApiSecret,
    );

    return YaruSection(
      margin: const EdgeInsets.all(kLargestSpace),
      headline: Text(l10n.podcasts),
      child: Column(
        children: [
          const _DownloadsTile(),
          const _ControlCollectionTile(),
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
                  label: Text(SPKeys.podcastIndexApiKey.camelToSentence),
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
                bottom: kLargestSpace,
              ),
              child: TextField(
                controller: _secretController,
                onChanged: (v) => setState(() => _initialSecret = v),
                obscureText: true,
                decoration: InputDecoration(
                  label: Text(SPKeys.podcastIndexApiSecret.camelToSentence),
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

class _ControlCollectionTile extends StatelessWidget with WatchItMixin {
  const _ControlCollectionTile();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return YaruTile(
      title: Text(l10n.podcastSubscriptions),
      trailing: Row(
        children: [
          IconButton(
            icon: Icon(
              Iconz.export,
              semanticLabel: context.l10n.exportPodcastsToOpmlFile,
            ),
            tooltip: context.l10n.exportPodcastsToOpmlFile,
            onPressed: () => showFutureLoadingDialog(
              context: context,
              future: () => di<CustomContentModel>().exportPodcastsToOpmlFile(),
              backLabel: context.l10n.back,
              title: context.l10n.exportingPodcastsPleaseWait,
            ),
          ),
          IconButton(
            icon: Icon(
              Iconz.import,
              semanticLabel: context.l10n.importPodcastsFromOpmlFile,
            ),
            tooltip: context.l10n.importPodcastsFromOpmlFile,
            onPressed: () => showFutureLoadingDialog(
              context: context,
              future: () =>
                  di<CustomContentModel>().importPodcastsFromOpmlFile(),
              title: context.l10n.importingPodcastsPleaseWait,
              backLabel: context.l10n.back,
            ),
          ),
          IconButton(
            icon: Icon(Iconz.remove),
            tooltip: context.l10n.podcasts,
            onPressed: () => ConfirmationDialog.show(
              context: context,
              title: Text(context.l10n.removeAllPodcastsConfirm),
              content: Text(context.l10n.removeAllPodcastsDescription),
              confirmLabel: context.l10n.ok,
              cancelLabel: context.l10n.cancel,
              onConfirm: () async {
                await di<LibraryModel>().removeAllPodcasts();
                di<PlayerService>().clearAllLastPositions();
                wipeCustomSettings(filename: FileNames.podcastUpdates);
                wipeCustomSettings(filename: FileNames.lastPositions);
              },
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
      trailing: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => ConfirmationDialog(
              content: SizedBox(
                width: 300,
                child: Text(
                  l10n.downloadsChangeWarning,
                  style: context.textTheme.bodyLarge,
                ),
              ),
              onConfirm: () => di<SettingsModel>().setDownloadsCustomDir(
                onSuccess: () => di<DownloadModel>().deleteAllDownloads(),
                onFail: (e) => setState(() => _error = e.toString()),
              ),
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
