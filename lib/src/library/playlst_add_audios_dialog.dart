import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

import '../../library.dart';
import '../../local_audio.dart';
import '../common/audio_autocomplete.dart';
import '../data/audio.dart';

class PlaylistAddAudiosDialog extends ConsumerWidget {
  const PlaylistAddAudiosDialog({
    super.key,
    required this.playlistId,
  });

  final String playlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audios =
        ref.read(localAudioModelProvider).audios?.toList() ?? <Audio>[];
    final libraryModel = ref.read(libraryModelProvider);
    return SimpleDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(kYaruPagePadding),
          child: SizedBox(
            // height: 50,
            width: 300,
            child: AudioAutoComplete(
              audios: audios,
              onSelected: (value) {
                if (value == null) return;
                libraryModel.addAudioToPlaylist(playlistId, value);
              },
            ),
          ),
        ),
      ],
    );
  }
}
