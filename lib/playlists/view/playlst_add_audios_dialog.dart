import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/audio_autocomplete.dart';
import '../../common/view/progress.dart';
import '../../common/view/ui_constants.dart';
import '../../library/library_model.dart';
import '../../local_audio/local_audio_model.dart';

class PlaylistAddAudiosDialog extends StatefulWidget
    with WatchItStatefulWidgetMixin {
  const PlaylistAddAudiosDialog({
    super.key,
    required this.playlistId,
  });

  final String playlistId;

  @override
  State<PlaylistAddAudiosDialog> createState() =>
      _PlaylistAddAudiosDialogState();
}

class _PlaylistAddAudiosDialogState extends State<PlaylistAddAudiosDialog> {
  @override
  void initState() {
    super.initState();
    di<LocalAudioModel>().init();
  }

  @override
  Widget build(BuildContext context) {
    final audios = watchPropertyValue((LocalAudioModel m) => m.audios);
    final libraryModel = di<LibraryModel>();
    return SimpleDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(kLargestSpace),
          child: SizedBox(
            // height: 50,
            width: 300,
            child: audios == null
                ? const Center(
                    child: Progress(),
                  )
                : AudioAutoComplete(
                    audios: audios,
                    onSelected: (value) {
                      if (value == null) return;
                      libraryModel.addAudiosToPlaylist(
                        id: widget.playlistId,
                        audios: [value],
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
