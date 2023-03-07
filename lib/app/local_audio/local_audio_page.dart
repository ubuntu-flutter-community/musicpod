import 'package:flutter/material.dart';
import 'package:music/app/common/audio_page.dart';
import 'package:music/app/local_audio/local_audio_model.dart';
import 'package:music/data/audio.dart';
import 'package:music/l10n/l10n.dart';
import 'package:provider/provider.dart';

class LocalAudioPage extends StatelessWidget {
  const LocalAudioPage({super.key, this.showWindowControls = true});

  final bool showWindowControls;

  @override
  Widget build(BuildContext context) {
    final localAudioModel = context.watch<LocalAudioModel>();
    final audios = localAudioModel.audios;

    return AudioPage(
      audioType: AudioType.local,
      placeTrailer: false,
      likePageButton: const SizedBox.shrink(),
      audios: audios,
      pageId: context.l10n.localAudio,
      editableName: false,
      deletable: false,
      showWindowControls: showWindowControls,
    );
  }
}
