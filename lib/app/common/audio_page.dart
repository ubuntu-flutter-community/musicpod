import 'package:flutter/material.dart';
import 'package:music/app/common/audio_list.dart';
import 'package:music/app/playlists/playlist_dialog.dart';
import 'package:music/app/playlists/playlist_model.dart';
import 'package:music/data/audio.dart';
import 'package:music/utils.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AudioPage extends StatelessWidget {
  const AudioPage({super.key, required this.audios, required this.pageName});

  final Set<Audio> audios;
  final String pageName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return YaruDetailPage(
      backgroundColor: theme.brightness == Brightness.dark
          ? const Color.fromARGB(255, 37, 37, 37)
          : Colors.white,
      appBar: YaruWindowTitleBar(
        title: Text(
          createPlaylistName(pageName, context),
        ),
        leading: Navigator.canPop(context)
            ? const YaruBackButton(
                style: YaruBackButtonStyle.rounded,
              )
            : const SizedBox(
                width: 40,
              ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: AudioList(audios: audios, listName: pageName),
      ),
    );
  }
}
