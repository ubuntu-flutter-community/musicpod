import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/app/common/audio_page_body.dart';
import 'package:musicpod/app/local_audio/local_audio_model.dart';
import 'package:musicpod/app/local_audio/local_audio_search_field.dart';
import 'package:musicpod/app/local_audio/local_audio_search_page.dart';
import 'package:musicpod/app/tabbed_page.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class LocalAudioPage extends StatefulWidget {
  const LocalAudioPage({super.key, this.showWindowControls = true});

  final bool showWindowControls;

  @override
  State<LocalAudioPage> createState() => _LocalAudioPageState();
}

class _LocalAudioPageState extends State<LocalAudioPage> {
  @override
  Widget build(BuildContext context) {
    final searchQuery = context.select((LocalAudioModel m) => m.searchQuery);

    return Navigator(
      onPopPage: (route, result) => route.didPop(result),
      pages: [
        MaterialPage(
          child: _TitlesView(
            audios: context.read<LocalAudioModel>().audios?.take(10).toSet(),
            showWindowControls: widget.showWindowControls,
          ),
        ),
        if (searchQuery?.isNotEmpty == true)
          MaterialPage(
            child: LocalAudioSearchPage(
              showWindowControls: widget.showWindowControls,
            ),
          )
      ],
    );
  }
}

class StartPage extends StatelessWidget {
  const StartPage({
    super.key,
    required this.showWindowControls,
  });

  final bool showWindowControls;

  @override
  Widget build(BuildContext context) {
    final audios = context.read<LocalAudioModel>().audios;
    final theme = Theme.of(context);
    return YaruDetailPage(
      backgroundColor: theme.brightness == Brightness.dark
          ? const Color.fromARGB(255, 37, 37, 37)
          : Colors.white,
      appBar: const YaruWindowTitleBar(
        title: LocalAudioSearchField(),
      ),
      body: TabbedPage(
        tabTitles: [
          context.l10n.titles,
          context.l10n.artists,
          context.l10n.albums,
          context.l10n.genres,
        ],
        views: [
          _TitlesView(audios: audios, showWindowControls: showWindowControls),
          Center(
            child: Text(context.l10n.artists),
          ),
          Center(
            child: Text(context.l10n.albums),
          ),
          Center(
            child: Text(context.l10n.genres),
          )
        ],
      ),
    );
  }
}

class _TitlesView extends StatelessWidget {
  const _TitlesView({
    required this.audios,
    required this.showWindowControls,
  });

  final Set<Audio>? audios;
  final bool showWindowControls;

  @override
  Widget build(BuildContext context) {
    return AudioPageBody(
      audioPageType: AudioPageType.immutable,
      placeTrailer: false,
      likePageButton: const SizedBox.shrink(),
      audios: audios,
      pageId: context.l10n.localAudio,
      editableName: false,
      deletable: false,
      showWindowControls: showWindowControls,
      audioFilter: AudioFilter.title,
      showTrack: true,
      sort: true,
    );
  }
}
