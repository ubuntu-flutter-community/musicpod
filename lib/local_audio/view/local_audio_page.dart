import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/app_model.dart';
import '../../common/data/audio.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/icons.dart';
import '../../common/view/search_button.dart';
import '../../common/view/theme.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../../settings/view/settings_dialog.dart';
import '../local_audio_model.dart';
import 'failed_imports_content.dart';
import 'local_audio_body.dart';
import 'local_audio_control_panel.dart';
import 'local_audio_search_page.dart';
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
    final failedImports = di<LocalAudioModel>().failedImports;
    if (mounted && failedImports?.isNotEmpty == true) {
      showFailedImportsSnackBar(
        failedImports: failedImports!,
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = di<LocalAudioModel>();
    final audios = watchPropertyValue((LocalAudioModel m) => m.audios);
    final index = watchPropertyValue((AppModel m) => m.localAudioindex);
    final localAudioView = LocalAudioView.values[index];

    void search({
      required String? text,
    }) {
      final libraryModel = di<LibraryModel>();

      if (text != null) {
        model.search(text);
        libraryModel.push(
          builder: (_) => const LocalAudioSearchPage(),
          pageId: kSearchPageId,
        );
      } else {
        libraryModel.pop();
      }
    }

    final headerBar = HeaderBar(
      adaptive: true,
      titleSpacing: 0,
      actions: [
        Flexible(
          child: Padding(
            padding: appBarSingleActionSpacing,
            child: SearchButton(
              active: false,
              onPressed: () => search(text: ''),
            ),
          ),
        ),
      ],
      title: Text(context.l10n.localAudio),
    );

    return Scaffold(
      resizeToAvoidBottomInset: isMobile ? false : null,
      appBar: headerBar,
      body: Column(
        children: [
          const LocalAudioControlPanel(),
          Expanded(
            child: LocalAudioBody(
              localAudioView: localAudioView,
              titles: audios,
              albums: model.allAlbums,
              artists: model.allArtists,
              genres: model.allGenres,
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
      ),
    );
  }
}

class LocalAudioPageIcon extends StatelessWidget with WatchItMixin {
  const LocalAudioPageIcon({
    super.key,
    required this.selected,
  });

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final audioType = watchPropertyValue((PlayerModel m) => m.audio?.audioType);

    final theme = context.t;
    if (audioType == AudioType.local) {
      return Icon(
        Iconz().play,
        color: theme.colorScheme.primary,
      );
    }

    return Padding(
      padding: kMainPageIconPadding,
      child:
          selected ? Icon(Iconz().localAudioFilled) : Icon(Iconz().localAudio),
    );
  }
}
