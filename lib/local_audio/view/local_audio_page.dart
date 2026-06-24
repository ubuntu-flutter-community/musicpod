import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/clean_up_caches.dart';
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
import '../../settings/manager/settings_manager.dart';
import '../../settings/view/settings_action.dart';
import '../manager/find_all_album_i_ds_manager.dart';
import '../manager/find_all_artists_manager.dart';
import '../manager/find_all_genres_manager.dart';
import '../manager/find_all_tracks_manager.dart';
import '../manager/local_audio_manager.dart';
import '../data/local_audio_view.dart';
import '../manager/playlist_ids_manager.dart';
import 'failed_import_snackbar.dart';
import 'local_audio_body.dart';
import 'local_audio_control_panel.dart';

class LocalAudioPage extends StatelessWidget with WatchItMixin {
  const LocalAudioPage({super.key});

  @override
  Widget build(BuildContext context) {
    callOnceAfterThisBuild((context) => clearImageCache());

    registerHandler(
      select: (LocalAudioManager m) => m.areTracksSyncedCommand.results,
      handler: (context, newValue, cancel) {
        if (newValue.isRunning)
          return;
        else if (newValue.hasError) {
          context.toast(Text(newValue.error.toString()));
        } else if (newValue.data == false) {
          ConfirmationDialog.show(
            context: context,
            title: Text(context.l10n.localAudioWatchDialogTitle),
            content: Text(context.l10n.localAudioWatchDialogDescription),
            onConfirm: () => di<LocalAudioManager>().initAudiosCommand.run((
              directory: null,
              forceInit: true,
              forceDbOnly: false,
            )),
          );
        }
      },
    );

    registerHandler(
      select: (LocalAudioManager m) => m.initAudiosCommand.results,
      handler: (context, results, cancel) {
        if (results.isRunning)
          return;
        else if (results.hasError) {
          context.toast(Text(results.error.toString()));
        } else if (results.hasData &&
            results.data?.failedImports.isNotEmpty == true) {
          showFailedImportsSnackBarIfNotBlocked(
            failedImports: results.data!.failedImports,
            context: context,
          );
        }
      },
    );

    final initResults = watchValue(
      (LocalAudioManager m) => m.initAudiosCommand.results,
    );
    final progress = watchValue(
      (LocalAudioManager m) => m.initAudiosCommand.progress,
    );
    final isRunning = initResults.isRunning;

    final index = watchPropertyValue((SettingsManager m) => m.localAudioindex);
    final localAudioView = LocalAudioView.values[index];

    final l10n = context.l10n;
    return Scaffold(
      appBar: HeaderBar(
        titleSpacing: 0,
        actions: [
          Padding(
            padding: appBarSingleActionSpacing,
            child: SearchButton(
              active: false,
              onPressed: () {
                di<RoutingManager>().push(pageId: PageIDs.searchPage);
                final searchManager = di<SearchManager>();
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
                  const Progress(adaptive: false),
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
  }
}

class LocalAudioPageBody extends StatelessWidget with WatchItMixin {
  const LocalAudioPageBody({
    super.key,
    required this.constraints,
    required this.localAudioView,
  });

  final BoxConstraints constraints;
  final LocalAudioView localAudioView;

  @override
  Widget build(BuildContext context) {
    final titlesResults = watchValue(
      (FindAllTracksManager m) => m.command.results,
    );
    final titlesResultsLoading = titlesResults.isRunning;
    if (!titlesResultsLoading &&
        (titlesResults.data == null || titlesResults.data!.isEmpty))
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
      titles: titlesResults.data,
      albumIDs: watchValue((FindAllAlbumIDsManager m) => m.command),
      artists: watchValue((FindAllArtistsManager m) => m.command),
      genres: watchValue((FindAllGenresManager m) => m.command),
      playlists: watchValue((PlaylistIDsManager m) => m.command),
      startNewPlaylistOnTap: true,
    );
  }
}
