import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_card.dart';
import 'package:musicpod/app/common/audio_page_header.dart';
import 'package:musicpod/app/common/audio_tile.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/app/local_audio/local_audio_search_field.dart';
import 'package:musicpod/app/player_model.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import 'local_audio_model.dart';

class LocalAudioSearchPage extends StatefulWidget {
  const LocalAudioSearchPage({
    super.key,
    this.titlesResult,
    this.albumsResult,
    this.artistsResults,
    this.showWindowControls = true,
  });

  final Set<Audio>? titlesResult;
  final Set<Set<Audio>>? albumsResult;
  final Set<Set<Set<Audio>>>? artistsResults;
  final bool showWindowControls;

  @override
  State<LocalAudioSearchPage> createState() => _LocalAudioSearchPageState();
}

class _LocalAudioSearchPageState extends State<LocalAudioSearchPage> {
  @override
  Widget build(BuildContext context) {
    final isPlaying = context.select((PlayerModel m) => m.isPlaying);
    final setAudio = context.read<PlayerModel>().setAudio;
    final currentAudio = context.select((PlayerModel m) => m.audio);
    final play = context.read<PlayerModel>().play;
    final pause = context.read<PlayerModel>().pause;
    final resume = context.read<PlayerModel>().resume;

    final theme = Theme.of(context);
    // final light = theme.brightness == Brightness.light;

    final titlesList = Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Row(
            children: [
              Text(
                '${context.l10n.titles}  •  ${widget.titlesResult?.length ?? 0}',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w100),
              )
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 15, right: 15),
          child: AudioPageHeader(
            showTrack: false,
            audioFilter: AudioFilter.title,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 20,
          ),
          child: Divider(
            height: 0,
          ),
        ),
        if (widget.titlesResult == null)
          const Center(
            child: YaruCircularProgressIndicator(),
          )
        else
          Column(
            children:
                List.generate(widget.titlesResult!.take(5).length, (index) {
              final audio = widget.titlesResult!.take(5).elementAt(index);
              final audioSelected = currentAudio == audio;

              return AudioTile(
                isPlayerPlaying: isPlaying,
                pause: pause,
                play: () async {
                  setAudio(audio);
                  await play();
                },
                resume: resume,
                key: ValueKey(audio),
                selected: audioSelected,
                audio: audio,
                likeIcon: const SizedBox.shrink(),
              );
            }),
          )
      ],
    );

    final albumGrid = widget.albumsResult == null
        ? GridView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: kImageGridDelegate,
            padding: EdgeInsets.zero,
            children: List.generate(8, (index) => Audio())
                .map((e) => const AudioCard())
                .toList(),
          )
        : GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: widget.albumsResult!.length,
            gridDelegate: kImageGridDelegate,
            itemBuilder: (context, index) {
              final podcast = widget.albumsResult!.elementAt(index);

              return AudioCard(
                imageUrl: podcast.firstOrNull?.imageUrl,
                onPlay: () {},
              );
            },
          );

    final albumColumn = Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Row(
            children: [
              Text(
                '${context.l10n.albums}  •  ${widget.albumsResult?.length ?? 0}',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w100),
              )
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 10,
            bottom: 20,
          ),
          child: Divider(
            height: 0,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: albumGrid,
        )
      ],
    );

    final body = ListView(
      shrinkWrap: true,
      children: [
        titlesList,
        const SizedBox(
          height: kYaruPagePadding,
        ),
        albumColumn,
        const SizedBox(
          height: kYaruPagePadding,
        ),
      ],
    );

    return YaruDetailPage(
      backgroundColor: theme.brightness == Brightness.dark
          ? const Color.fromARGB(255, 37, 37, 37)
          : Colors.white,
      appBar: YaruWindowTitleBar(
        style: widget.showWindowControls
            ? YaruTitleBarStyle.normal
            : YaruTitleBarStyle.undecorated,
        title: const LocalAudioSearchField(),
        leading: Navigator.canPop(context)
            ? const YaruBackButton(
                style: YaruBackButtonStyle.rounded,
              )
            : const SizedBox(
                width: 40,
              ),
      ),
      body: body,
    );
  }
}
