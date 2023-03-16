import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_card.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/app/common/audio_page_header.dart';
import 'package:musicpod/app/common/audio_tile.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/app/common/loading_tile.dart';
import 'package:musicpod/app/local_audio/local_audio_search_field.dart';
import 'package:musicpod/app/player_model.dart';
import 'package:musicpod/app/playlists/playlist_model.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import 'local_audio_model.dart';

class LocalAudioSearchPage extends StatefulWidget {
  const LocalAudioSearchPage({
    super.key,
    this.showWindowControls = true,
  });

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
    final startPlaylist = context.read<PlayerModel>().startPlaylist;
    final isPinnedAlbum = context.read<PlaylistModel>().isPinnedAlbum;
    final removePinnedAlbum = context.read<PlaylistModel>().removePinnedAlbum;
    final addPinnedAlbum = context.read<PlaylistModel>().addPinnedAlbum;
    final audios = context.select((LocalAudioModel m) => m.audios);

    final Set<Audio>? titlesResult =
        context.select((LocalAudioModel m) => m.titlesSearchResult);

    final Set<Audio>? similarAlbumsResult =
        context.select((LocalAudioModel m) => m.similarAlbumsSearchResult);

    // final Set<Set<Set<Audio>>>? artistsResults = {};

    final theme = Theme.of(context);

    final titlesList = Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Row(
            children: [
              Text(
                '${context.l10n.titles}  •  ${titlesResult?.length ?? 0}',
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
            bottom: 15,
          ),
          child: Divider(
            height: 0,
          ),
        ),
        if (titlesResult == null)
          Column(
            children: [
              for (var i = 0; i < 5; i++)
                Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: i == 4 ? 0 : 15,
                  ),
                  child: const LoadingTile(),
                )
            ],
          )
        else
          Column(
            children: List.generate(titlesResult.take(5).length, (index) {
              final audio = titlesResult.take(5).elementAt(index);
              final audioSelected = currentAudio == audio;

              return Padding(
                padding: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                child: AudioTile(
                  showTrack: false,
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
                  likeIcon: const SizedBox(width: 65),
                ),
              );
            }),
          )
      ],
    );

    final albumGrid = similarAlbumsResult == null
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
            itemCount: similarAlbumsResult.length,
            gridDelegate: kImageGridDelegate,
            itemBuilder: (context, index) {
              var audio = similarAlbumsResult.elementAt(index);

              final album = audios?.where(
                (a) =>
                    a.metadata != null &&
                    a.metadata!.album != null &&
                    a.metadata?.album == audio.metadata?.album,
              );

              final albumList = album?.toList();
              albumList?.sort(
                (a, b) {
                  if (a.metadata == null ||
                      b.metadata == null ||
                      a.metadata?.trackNumber == null ||
                      b.metadata?.trackNumber == null) return 0;
                  return a.metadata!.trackNumber!
                      .compareTo(b.metadata!.trackNumber!);
                },
              );

              final name = album?.firstOrNull?.metadata?.album;

              final image = audio.metadata?.picture?.data == null
                  ? Center(
                      child: Icon(
                        YaruIcons.music_note,
                        size: 140,
                        color: theme.hintColor,
                      ),
                    )
                  : Image.memory(
                      audio.metadata!.picture!.data,
                    );

              return AudioCard(
                bottom: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(1),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.inverseSurface,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(kYaruContainerRadius),
                        bottomRight: Radius.circular(kYaruContainerRadius),
                      ),
                    ),
                    child: Text(
                      '${audio.metadata?.album == null ? '' : audio.metadata!.album!} • ${audio.metadata?.artist == null ? '' : audio.metadata!.artist!}',
                      style:
                          TextStyle(color: theme.colorScheme.onInverseSurface),
                    ),
                  ),
                ),
                image: image,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return AudioPage(
                        title: const LocalAudioSearchField(),
                        audioPageType: AudioPageType.album,
                        pageLabel: context.l10n.album,
                        image: image,
                        likePageButton: name == null
                            ? null
                            : isPinnedAlbum(name)
                                ? YaruIconButton(
                                    icon: Icon(
                                      YaruIcons.pin,
                                      color: theme.primaryColor,
                                    ),
                                    onPressed: () => removePinnedAlbum(
                                      name,
                                    ),
                                  )
                                : YaruIconButton(
                                    icon: const Icon(
                                      YaruIcons.pin,
                                    ),
                                    onPressed: () => addPinnedAlbum(
                                      audio.metadata!.album!,
                                      Set.from(album!.toList()),
                                    ),
                                  ),
                        showWindowControls: widget.showWindowControls,
                        deletable: false,
                        audios: Set.from(album!.toList()),
                        pageId: name!,
                        editableName: false,
                      );
                    },
                  ),
                ),
                onPlay: albumList == null
                    ? null
                    : () => startPlaylist(Set.from(albumList)),
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
                '${context.l10n.albums}  •  ${similarAlbumsResult?.length ?? 0}',
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
          height: 10,
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
