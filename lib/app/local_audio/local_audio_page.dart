import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:music/app/local_audio/local_audio_model.dart';
import 'package:music/app/player_model.dart';
import 'package:music/app/tabbed_page.dart';
import 'package:music/data/audio.dart';
import 'package:music/l10n/l10n.dart';
import 'package:music/utils.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class LocalAudioPage extends StatefulWidget {
  const LocalAudioPage({super.key});

  @override
  State<LocalAudioPage> createState() => _LocalAudioPageState();
}

class _LocalAudioPageState extends State<LocalAudioPage> {
  late ScrollController _controller;
  int _amount = 40;
  bool _searchActive = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(() {
      if (_controller.position.maxScrollExtent == _controller.offset) {
        setState(() {
          _amount++;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localAudioModel = context.watch<LocalAudioModel>();
    final playerModel = context.watch<PlayerModel>();
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
        : Container(
            color: theme.brightness == Brightness.dark
                ? const Color.fromARGB(255, 37, 37, 37)
                : Colors.white,
            child: TabbedPage(
              tabTitles: const ['Songs', 'Artists', 'Albums', 'Genre'],
              views: [
                ListView.builder(
                  controller: _controller,
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                  ),
                  itemCount: localAudioModel.audios!.take(_amount).length,
                  itemBuilder: (context, index) {
                    final audioSelected =
                        playerModel.audio == localAudioModel.audios![index];

                    return _LocalAudioTile(
                      key: ValueKey(localAudioModel.audios![index]),
                      selected: audioSelected,
                      audio: localAudioModel.audios![index],
                    );
                  },
                ),
                const Center(),
                const Center(),
                const Center(),
              ],
            ),
          );

    final appBar = YaruWindowTitleBar(
      leading: Navigator.of(context).canPop()
          ? const YaruBackButton(
              style: YaruBackButtonStyle.rounded,
            )
          : null,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Center(
            child: YaruIconButton(
              isSelected: _searchActive,
              icon: const Icon(YaruIcons.search),
              onPressed: () => setState(() {
                _searchActive = !_searchActive;
              }),
            ),
          ),
        )
      ],
      title: _searchActive
          ? const SizedBox(
              height: 35,
              // width: 400,
              child: TextField(),
            )
          : Text(context.l10n.localAudio),
    );

    return YaruDetailPage(
      appBar: appBar,
      body: page,
    );
  }
}

class _LocalAudioTile extends StatelessWidget {
  const _LocalAudioTile({
    super.key,
    required this.selected,
    required this.audio,
  });

  final Audio audio;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final playerModel = context.watch<PlayerModel>();
    final theme = Theme.of(context);
    final textStyle = TextStyle(
      color: selected ? theme.colorScheme.onSurface : theme.hintColor,
      fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
    );

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 8, right: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kYaruButtonRadius),
      ),
      onTap: () async {
        if (playerModel.isPlaying && selected) {
          playerModel.pause();
        } else {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
            playerModel.audio = audio;
            await playerModel.play();
          });
        }
      },
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              audio.metadata?.title ?? audio.name!,
              style: textStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              audio.metadata?.artist ?? '',
              style: textStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              audio.metadata?.album ?? '',
              style: textStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (audio.metadata?.durationMs != null)
            Expanded(
              child: Text(
                formatTime(
                  Duration(
                    milliseconds: audio.metadata!.durationMs!.toInt(),
                  ),
                ),
                style: textStyle,
              ),
            )
        ],
      ),
      trailing: YaruIconButton(
        icon: const Icon(YaruIcons.heart),
        onPressed: () {},
      ),
    );
  }
}
