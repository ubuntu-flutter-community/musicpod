import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/common_widgets.dart';
import '../../common/view/confirm.dart';
import '../../common/view/icons.dart';
import '../../common/view/ui_constants.dart';
import '../../custom_content/manager/custom_content_manager.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/string_x.dart';
import '../../podcasts/manager/download_manager.dart';
import '../../podcasts/manager/podcast_genre_manager.dart';
import '../../podcasts/manager/podcast_manager.dart';
import '../data/shared_preferences_keys.dart';
import '../manager/settings_manager.dart';
import '../manager/wipe_manager.dart';

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
    final model = di<SettingsManager>();
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
    final model = di<SettingsManager>();
    final usePodcastIndex = watchPropertyValue(
      (SettingsManager m) => m.usePodcastIndex,
    );
    final podcastIndexApiKey = watchPropertyValue(
      (SettingsManager m) => m.podcastIndexApiKey,
    );
    final podcastIndexApiSecret = watchPropertyValue(
      (SettingsManager m) => m.podcastIndexApiSecret,
    );

    return YaruSection(
      headline: Text(l10n.podcasts),
      child: Column(
        children: [
          const _DownloadsTile(),
          const _ControlCollectionTile(),
          YaruTile(
            title: Text(l10n.usePodcastIndex),
            trailing: CommonSwitch(
              value: usePodcastIndex,
              onChanged: (v) {
                if (!v) {
                  ConfirmationDialog.show(
                    context: context,
                    title: Text(l10n.iTunes + '?'),
                    onConfirm: () async {
                      di<PodcastManager>().initSearchCommand.run((
                        searchProvider: const ITunesProvider(),
                      ));

                      await model.setUsePodcastIndex(v);

                      await di<PodcastLoadGenresManager>().command.runAsync((
                        force: true,
                      ));
                    },
                  );
                } else {
                  model.setUsePodcastIndex(v);
                }
              },
            ),
          ),
          if (usePodcastIndex) ...[
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
            Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
                bottom: kLargestSpace,
              ),
              child: ValueListenableBuilder(
                valueListenable: _keyController,
                builder: (context, value, child) {
                  return TextField(
                    enabled: value.text.isNotEmpty,
                    controller: _secretController,
                    onChanged: (v) => setState(() => _initialSecret = v),
                    obscureText: true,
                    decoration: InputDecoration(
                      label: Text(SPKeys.podcastIndexApiSecret.camelToSentence),
                      suffixIcon: IconButton(
                        tooltip: l10n.save,
                        onPressed: () => model.setPodcastIndexApiSecret(
                          _secretController.text,
                        ),
                        icon: Icon(
                          Iconz.check,
                          color: podcastIndexApiSecret == _initialSecret
                              ? theme.colorScheme.success
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _secretController,
              builder: (context, value, child) {
                return ListTile(
                  trailing: ElevatedButton(
                    onPressed: value.text.isEmpty
                        ? null
                        : () => ConfirmationDialog.show(
                            context: context,
                            title: Text(l10n.usePodcastIndex + '?'),
                            onConfirm: () async =>
                                di<PodcastManager>().initSearchCommand.run((
                                  searchProvider: PodcastIndexProvider(
                                    key: model.podcastIndexApiKey!,
                                    secret: model.podcastIndexApiSecret!,
                                  ),
                                )),
                          ),
                    child: Text(context.l10n.confirm),
                  ),
                );
              },
            ),
          ],
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
              future: () =>
                  di<CustomContentManager>().exportPodcastsToOpmlFile(),
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
                  di<CustomContentManager>().importPodcastsFromOpmlFile(),
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
              onConfirm: () =>
                  di<WipeManager>().wipeCommand.runAsync({WipeType.podcasts}),
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
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final downloadsDirResults = watchValue(
      (DownloadManager m) => m.downloadsDirCommand.results,
    );
    final error = downloadsDirResults.error;
    final downloadsDir = downloadsDirResults.data;

    return YaruTile(
      title: Text(l10n.downloadsDirectory),
      subtitle: Text(error?.toString() ?? downloadsDir ?? ''),
      trailing: ElevatedButton(
        onPressed: () {
          context.dialog(
            (context) => ConfirmationDialog(
              content: SizedBox(
                width: 300,
                child: Text(
                  l10n.downloadsChangeWarning,
                  style: context.textTheme.bodyLarge,
                ),
              ),
              onConfirm: () async => di<DownloadManager>().downloadsDirCommand
                  .runAsync((getDefault: false)),
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
