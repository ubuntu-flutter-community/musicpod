import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/confirm.dart';
import '../../common/view/default_page_body.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/progress.dart';
import '../../common/view/search_button.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../search/manager/search_manager.dart';
import '../../search/data/search_type.dart';
import '../../settings/data/shared_preferences_keys.dart';
import '../../settings/manager/settings_manager.dart';
import '../../settings/view/settings_action.dart';
import '../manager/find_all_album_i_ds_manager.dart';
import '../manager/find_all_artists_manager.dart';
import '../manager/find_all_genres_manager.dart';
import '../manager/find_all_tracks_manager.dart';
import '../manager/local_audio_manager.dart';
import '../manager/tracks_synced_manager.dart';
import '../data/local_audio_view.dart';
import '../manager/playlist_ids_manager.dart';
import 'failed_import_snackbar.dart';
import 'local_audio_body.dart';
import 'local_audio_control_panel.dart';

class LocalAudioPage extends StatelessWidget {
  const LocalAudioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Consumer(
      builder: (context, ref, _) {
        final index =
            ref.watch(settingsIntManagerProvider(SPKeys.localAudioIndex)) ?? 0;
        final localAudioView = LocalAudioView
            .values[index.clamp(0, LocalAudioView.values.length - 1)];
        ref.listen<AsyncValue<LocalAudioState>>(localAudioManagerProvider, (
          prev,
          next,
        ) {
          if (next.hasError && prev?.error != next.error) {
            context.toast(Text(next.error.toString()));
          }
          final failed = next.value?.failedImports;
          if (failed?.isNotEmpty == true &&
              prev?.value?.failedImports != failed) {
            showFailedImportsSnackBarIfNotBlocked(
              failedImports: failed!,
              context: context,
            );
          }
        });

        ref.listen<AsyncValue<bool>>(tracksSyncedManagerProvider, (prev, next) {
          if (next.value == false && prev?.value != false) {
            ConfirmationDialog.show(
              context: context,
              title: Text(context.l10n.localAudioWatchDialogTitle),
              content: Text(context.l10n.localAudioWatchDialogDescription),
              onConfirm: () => ref
                  .read(localAudioManagerProvider.notifier)
                  .initAudios(forceInit: true),
            );
          }
        });

        final audioAsync = ref.watch(localAudioManagerProvider);
        final isRunning = audioAsync.isLoading;
        final progress = (audioAsync.progress as double?) ?? 0.0;

        return Scaffold(
          appBar: HeaderBar(
            titleSpacing: 0,
            actions: [
              Padding(
                padding: appBarSingleActionSpacing,
                child: SearchButton(
                  active: false,
                  onPressed: () {
                    ref
                        .read(routingManagerProvider.notifier)
                        .push(pageId: PageIDs.searchPage);
                    final searchManager = ref.read(
                      searchManagerProvider.notifier,
                    );
                    searchManager
                      ..setAudioType(AudioType.local)
                      ..setSearchType(SearchType.localTitle)
                      ..search();
                  },
                ),
              ),
            ],
            title: Text(context.l10n.localAudio),
          ),
          body: isRunning
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: kLargestSpace,
                    children: [
                      Progress(value: progress, adaptive: false),
                      Text(
                        '${'${(progress * 100).toStringAsFixed(0)}%'} ... ${switch (progress) {
                          0.25 => l10n.parsingLocalAudioFilesMetadataPleaseWait,
                          0.5 => l10n.persistingLocalAudioFilesMetadataPleaseWait,
                          0.75 => l10n.buildingLocalAudioLibraryPleaseWait,
                          _ => l10n.loadingPleaseWait,
                        }}',
                      ),
                    ],
                  ),
                )
              : DefaultPageBody(
                  controlPanel: const LocalAudioControlPanel(),
                  sliverContentBuilder: (context, constraints) =>
                      LocalAudioPageBody(
                        constraints: constraints,
                        localAudioView: localAudioView,
                      ),
                ),
        );
      },
    );
  }
}

class LocalAudioPageBody extends ConsumerWidget {
  const LocalAudioPageBody({
    super.key,
    required this.constraints,
    required this.localAudioView,
  });

  final BoxConstraints constraints;
  final LocalAudioView localAudioView;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titlesResults = ref.watch(findAllTracksManagerProvider);
    final titlesResultsLoading = titlesResults.isLoading;
    if (!titlesResultsLoading &&
        (titlesResults.value == null || titlesResults.value!.isEmpty))
      return SliverNoSearchResultPage(
        message: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.noLocalTitlesFound),
            const SizedBox(height: kLargestSpace),
            const SettingsButton.important(scrollIndex: 2),
          ],
        ),
      );

    return LocalAudioBody(
      constraints: constraints,
      localAudioView: localAudioView,
      titles: titlesResults.value,
      albumIDs: ref.watch(findAllAlbumIDsManagerProvider).value,
      artists: ref.watch(findAllArtistsManagerProvider).value,
      genres: ref.watch(findAllGenresManagerProvider).value,
      playlists: ref.watch(playlistIDsManagerProvider).value ?? [],
      startNewPlaylistOnTap: true,
    );
  }
}
