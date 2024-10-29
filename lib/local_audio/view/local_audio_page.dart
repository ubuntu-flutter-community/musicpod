import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/data/audio.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/search_button.dart';
import '../../common/view/sliver_filter_app_bar.dart';
import '../../common/view/theme.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../search/search_model.dart';
import '../../search/search_type.dart';
import '../../settings/view/settings_dialog.dart';
import '../local_audio_model.dart';
import 'failed_imports_content.dart';
import 'local_audio_body.dart';
import 'local_audio_control_panel.dart';
import 'local_audio_view.dart';

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
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final audios = watchPropertyValue((LocalAudioModel m) => m.audios);
    final allArtists = watchPropertyValue((LocalAudioModel m) => m.allArtists);
    final allAlbums = watchPropertyValue((LocalAudioModel m) => m.allAlbums);
    final allGenres = watchPropertyValue((LocalAudioModel m) => m.allGenres);
    final playlists =
        watchPropertyValue((LibraryModel m) => m.playlists.keys.toList());
    final index = watchPropertyValue((LocalAudioModel m) => m.localAudioindex);
    final localAudioView = LocalAudioView.values[index];

    return Scaffold(
      resizeToAvoidBottomInset: isMobile ? false : null,
      appBar: HeaderBar(
        adaptive: true,
        titleSpacing: 0,
        actions: [
          Padding(
            padding: appBarSingleActionSpacing,
            child: SearchButton(
              active: false,
              onPressed: () {
                di<LibraryModel>().push(pageId: kSearchPageId);
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
                  left: filterPanelPadding.left,
                  top: filterPanelPadding.top,
                  right: filterPanelPadding.right,
                ),
                title: const LocalAudioControlPanel(),
              ),
              SliverPadding(
                padding: getAdaptiveHorizontalPadding(constraints: constraints),
                sliver: LocalAudioBody(
                  localAudioView: localAudioView,
                  titles: audios,
                  albums: allAlbums,
                  artists: allArtists,
                  genres: allGenres,
                  playlists: playlists,
                  noResultIcon: const AnimatedEmoji(AnimatedEmojis.bird),
                  noResultMessage: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(context.l10n.noLocalTitlesFound),
                      const SizedBox(
                        height: kYaruPagePadding,
                      ),
                      ImportantButton(
                        child: Text(context.l10n.settings),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const SettingsDialog(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
