import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/view/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/page_ids.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/search_button.dart';
import '../../common/view/sliver_body.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../search/search_model.dart';
import '../../search/search_type.dart';
import '../../settings/view/settings_action.dart';
import '../local_audio_model.dart';
import '../local_audio_view.dart';
import 'failed_import_snackbar.dart';
import 'local_audio_body.dart';
import 'local_audio_control_panel.dart';

class LocalAudioPage extends StatefulWidget with WatchItStatefulWidgetMixin {
  const LocalAudioPage({super.key});

  @override
  State<LocalAudioPage> createState() => _LocalAudioPageState();
}

class _LocalAudioPageState extends State<LocalAudioPage> {
  @override
  void initState() {
    super.initState();
    final model = di<LocalAudioModel>();
    final failedImports = model.failedImports;
    model.init().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && failedImports != null && failedImports.isNotEmpty) {
          showFailedImportsSnackBar(
            failedImports: failedImports,
            context: context,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final audios = watchPropertyValue((LocalAudioModel m) => m.audios);
    final allArtists = watchPropertyValue((LocalAudioModel m) => m.allArtists);
    final allAlbumIDs = watchPropertyValue(
      (LocalAudioModel m) => m.allAlbumIDs,
    );
    final allGenres = watchPropertyValue((LocalAudioModel m) => m.allGenres);
    final playlists = watchPropertyValue((LibraryModel m) => m.playlistIDs);
    final index = watchPropertyValue((LocalAudioModel m) => m.localAudioindex);
    final localAudioView = LocalAudioView.values[index];

    return Scaffold(
      appBar: HeaderBar(
        adaptive: true,
        titleSpacing: 0,
        actions: [
          Padding(
            padding: appBarSingleActionSpacing,
            child: SearchButton(
              active: false,
              onPressed: () {
                di<RoutingManager>().push(pageId: PageIDs.searchPage);
                final searchmodel = di<SearchModel>();
                searchmodel
                  ..setAudioType(AudioType.local)
                  ..setSearchType(SearchType.localTitle)
                  ..search();
              },
            ),
          ),
        ],
        title: Text(context.l10n.localAudio),
      ),
      body: SliverBody(
        controlPanel: const LocalAudioControlPanel(),
        contentBuilder: (context, constraints) =>
            audios != null && audios.isEmpty
            ? SliverNoSearchResultPage(
                message: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(context.l10n.noLocalTitlesFound),
                    const SizedBox(height: kLargestSpace),
                    const SettingsButton.important(scrollIndex: 2),
                  ],
                ),
              )
            : LocalAudioBody(
                constraints: constraints,
                localAudioView: localAudioView,
                titles: audios,
                albumIDs: allAlbumIDs,
                artists: allArtists,
                genres: allGenres,
                playlists: playlists,
              ),
      ),
    );
  }
}
