import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:watcher/watcher.dart';

import '../../common/data/audio_type.dart';
import '../../common/page_ids.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/confirm.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/search_button.dart';
import '../../common/view/sliver_filter_app_bar.dart';
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
    di<LocalAudioModel>().init().then((_) {
      final failedImports = di<LocalAudioModel>().failedImports;
      if (mounted && failedImports?.isNotEmpty == true) {
        showFailedImportsSnackBar(
          failedImports: failedImports!,
          context: context,
          message: context.l10n.failedToReadMetadata,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final audios = watchPropertyValue((LocalAudioModel m) => m.audios);
    final allArtists = watchPropertyValue((LocalAudioModel m) => m.allArtists);
    final allAlbumArtists =
        watchPropertyValue((LocalAudioModel m) => m.allAlbumArtists);

    final allAlbums = watchPropertyValue((LocalAudioModel m) => m.allAlbums);
    final allGenres = watchPropertyValue((LocalAudioModel m) => m.allGenres);
    final playlists =
        watchPropertyValue((LibraryModel m) => m.playlists.keys.toList());
    final index = watchPropertyValue((LocalAudioModel m) => m.localAudioindex);
    final localAudioView = LocalAudioView.values[index];

    registerStreamHandler(
      select: (LocalAudioModel m) =>
          m.fileWatcher?.events ?? const Stream<WatchEvent>.empty(),
      handler: (context, newValue, cancel) {
        if (newValue.hasData && !di<LocalAudioModel>().importing) {
          showDialog(
            context: context,
            builder: (context) => ConfirmationDialog(
              title: Text(l10n.localAudioWatchDialogTitle),
              content: Text(l10n.localAudioWatchDialogDescription),
              onConfirm: () => di<LocalAudioModel>().init(forceInit: true),
            ),
          );
        }
      },
    );

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
                di<LibraryModel>().push(pageId: PageIDs.searchPage);
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return CustomScrollView(
            slivers: [
              SliverFilterAppBar(
                padding: getAdaptiveHorizontalPadding(constraints: constraints)
                    .copyWith(
                  bottom: filterPanelPadding.bottom,
                  top: filterPanelPadding.top,
                ),
                title: const LocalAudioControlPanel(),
              ),
              SliverPadding(
                padding: getAdaptiveHorizontalPadding(constraints: constraints)
                    .copyWith(
                  bottom: bottomPlayerPageGap,
                ),
                sliver: audios != null && audios.isEmpty
                    ? SliverNoSearchResultPage(
                        icon: const AnimatedEmoji(AnimatedEmojis.bird),
                        message: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(context.l10n.noLocalTitlesFound),
                            const SizedBox(
                              height: kLargestSpace,
                            ),
                            const SettingsButton.important(),
                          ],
                        ),
                      )
                    : LocalAudioBody(
                        localAudioView: localAudioView,
                        titles: audios,
                        albums: allAlbums,
                        artists: allArtists,
                        albumArtists: allAlbumArtists,
                        genres: allGenres,
                        playlists: playlists,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
