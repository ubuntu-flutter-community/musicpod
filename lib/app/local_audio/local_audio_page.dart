import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:music/app/common/audio_list.dart';
import 'package:music/app/common/search_field.dart';
import 'package:music/app/local_audio/local_audio_model.dart';
import 'package:music/app/tabbed_page.dart';
import 'package:music/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class LocalAudioPage extends StatefulWidget {
  const LocalAudioPage({super.key});

  @override
  State<LocalAudioPage> createState() => _LocalAudioPageState();
}

class _LocalAudioPageState extends State<LocalAudioPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localAudioModel = context.watch<LocalAudioModel>();
    final theme = Theme.of(context);

    final page = localAudioModel.directory == null ||
            localAudioModel.directory!.isEmpty ||
            localAudioModel.audios == null
        ? Center(
            child: ElevatedButton(
              onPressed: () async {
                localAudioModel.directory = await getDirectoryPath();
                await localAudioModel.init();
              },
              child: const Text('Pick your music collection'),
            ),
          )
        : TabbedPage(
            tabTitles: [
              context.l10n.library,
              context.l10n.playlists,
              context.l10n.discover,
              context.l10n.forYou,
              // context.l10n.years,
            ],
            views: [
              AudioList(audios: Set.from(localAudioModel.audios!)),
              const Center(),
              const Center(),
              const Center(),
              // const Center(),
            ],
          );

    final appBar = YaruWindowTitleBar(
      leading: Navigator.of(context).canPop()
          ? const YaruBackButton(
              style: YaruBackButtonStyle.rounded,
            )
          : const SizedBox(
              width: 40,
            ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Center(
            child: YaruIconButton(
              isSelected: localAudioModel.searchActive,
              icon: const Icon(YaruIcons.search),
              onPressed: () => setState(() {
                localAudioModel.searchActive = !localAudioModel.searchActive;
              }),
            ),
          ),
        )
      ],
      title: localAudioModel.searchActive
          ? SearchField(
              label: context.l10n.searchLocalAudioHint,
              text: localAudioModel.searchQuery,
              onChanged: (value) => localAudioModel.searchQuery = value,
            )
          : Center(child: Text(context.l10n.localAudio)),
    );

    return YaruDetailPage(
      backgroundColor: theme.brightness == Brightness.dark
          ? const Color.fromARGB(255, 37, 37, 37)
          : Colors.white,
      appBar: appBar,
      body: page,
    );
  }
}
