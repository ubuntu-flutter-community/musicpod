import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/app/local_audio/local_audio_model.dart';
import 'package:musicpod/app/local_audio/local_audio_search_field.dart';
import 'package:musicpod/app/local_audio/local_audio_search_page.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:provider/provider.dart';

class LocalAudioPage extends StatelessWidget {
  const LocalAudioPage({super.key, this.showWindowControls = true});

  final bool showWindowControls;

  @override
  Widget build(BuildContext context) {
    final searchQuery = context.select((LocalAudioModel m) => m.searchQuery);
    final audios = context.select((LocalAudioModel m) => m.audios);

    return Navigator(
      onPopPage: (route, result) => route.didPop(result),
      pages: [
        MaterialPage(
          child: AudioPage(
            title: const LocalAudioSearchField(),
            audioPageType: AudioPageType.immutable,
            placeTrailer: false,
            likePageButton: const SizedBox.shrink(),
            audios: audios,
            pageId: context.l10n.localAudio,
            editableName: false,
            deletable: false,
            showWindowControls: showWindowControls,
          ),
        ),
        if (searchQuery?.isNotEmpty == true)
          MaterialPage(
            child: LocalAudioSearchPage(
              showWindowControls: showWindowControls,
            ),
          )
      ],
    );
  }
}
