import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/app/local_audio/local_audio_model.dart';
import 'package:musicpod/app/local_audio/local_audio_search_page.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:provider/provider.dart';

class LocalAudioPage extends StatelessWidget {
  const LocalAudioPage({super.key, this.showWindowControls = true});

  final bool showWindowControls;

  @override
  Widget build(BuildContext context) {
    final localAudioModel = context.watch<LocalAudioModel>();
    final audios = localAudioModel.audios;

    return Navigator(
      onPopPage: (route, result) => route.didPop(result),
      pages: [
        MaterialPage(
          child: AudioPage(
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
        if (localAudioModel.searchQuery?.isNotEmpty == true)
          const MaterialPage(
            child: LocalAudioSearchPage(),
          )
      ],
    );
  }
}
