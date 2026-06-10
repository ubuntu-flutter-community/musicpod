import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/confirm.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/progress.dart';
import '../../common/view/search_button.dart';
import '../../common/view/default_page_body.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../search/search_manager.dart';
import '../../search/search_type.dart';
import '../../settings/settings_manager.dart';
import '../../settings/view/settings_action.dart';
import '../local_audio_manager.dart';
import '../local_audio_view.dart';
import 'failed_import_snackbar.dart';
import 'local_audio_body.dart';
import 'local_audio_control_panel.dart';

class LocalAudioPage extends StatelessWidget with WatchItMixin {
  const LocalAudioPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (di<LocalAudioManager>().initAudiosCommand.value == null) {
      callOnceAfterThisBuild(
        (_) => di<LocalAudioManager>().initAudiosCommand.run((
          directory: null,
          forceInit: false,
          forceDbOnly: false,
        )),
      );
    }

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

    final audiosResults = watchValue(
      (LocalAudioManager m) => m.initAudiosCommand.results,
    );
    final progress = watchValue(
      (LocalAudioManager m) => m.initAudiosCommand.progress,
    );
    final audios = audiosResults.data?.audios;
    final isRunning = audiosResults.isRunning;
    final localAudioManager = di<LocalAudioManager>();

    final playlists = watchValue(
      (LocalAudioManager m) => m.allPlaylistsCommand,
    );
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
      body: audios == null || isRunning
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
              sliverContentBuilder: (context, constraints) => audios.isEmpty
                  ? SliverNoSearchResultPage(
                      message: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l10n.noLocalTitlesFound),
                          const SizedBox(height: kLargestSpace),
                          const SettingsButton.important(scrollIndex: 2),
                        ],
                      ),
                    )
                  : LocalAudioBody(
                      constraints: constraints,
                      localAudioView: localAudioView,
                      titles: audios,
                      albumIDs: localAudioManager.allAlbumIDs,
                      artists: localAudioManager.allArtists,
                      genres: localAudioManager.allGenres,
                      playlists: playlists,
                    ),
            ),
    );
  }
}
