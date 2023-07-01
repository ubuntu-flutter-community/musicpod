import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_filter.dart';
import 'package:musicpod/app/common/audio_page_control_panel.dart';
import 'package:musicpod/app/common/audio_tile_header.dart';
import 'package:musicpod/app/common/audio_tile.dart';
import 'package:musicpod/app/common/super_like_button.dart';
import 'package:musicpod/app/player/player_model.dart';
import 'package:musicpod/app/playlists/playlist_dialog.dart';
import 'package:musicpod/app/library_model.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:musicpod/utils.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class TitlesView extends StatefulWidget {
  const TitlesView({
    super.key,
    required this.audios,
    required this.showWindowControls,
    this.onArtistTap,
    this.onAlbumTap,
  });

  final Set<Audio>? audios;
  final bool showWindowControls;
  final void Function(String artist)? onArtistTap;
  final void Function(String album)? onAlbumTap;

  @override
  State<TitlesView> createState() => _TitlesViewState();
}

class _TitlesViewState extends State<TitlesView> {
  late AudioFilter _filter;
  late ScrollController _controller;
  int _amount = 40;

  @override
  void initState() {
    super.initState();
    _filter = AudioFilter.album;
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
    final theme = Theme.of(context);

    final isPlaying = context.select((PlayerModel m) => m.isPlaying);
    final startPlaylist = context.read<PlayerModel>().startPlaylist;

    final currentAudio = context.select((PlayerModel m) => m.audio);

    final setAudio = context.read<PlayerModel>().setAudio;
    final play = context.read<PlayerModel>().play;
    final pause = context.read<PlayerModel>().pause;
    final resume = context.read<PlayerModel>().resume;
    final isLiked = context.read<LibraryModel>().liked;

    final removeLikedAudio = context.read<LibraryModel>().removeLikedAudio;
    final addLikedAudio = context.read<LibraryModel>().addLikedAudio;
    final getPlaylistIds = context.read<LibraryModel>().getTopFivePlaylistNames;
    final addAudioToPlaylist = context.read<LibraryModel>().addAudioToPlaylist;
    final addPlaylist = context.read<LibraryModel>().addPlaylist;

    if (widget.audios == null) {
      return const Center(
        child: YaruCircularProgressIndicator(),
      );
    }

    final sortedAudios = widget.audios!.toList();

    sortListByAudioFilter(
      audioFilter: _filter,
      audios: sortedAudios,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 10,
            left: 20,
            right: 20,
            bottom: 10,
          ),
          child: AudioPageControlPanel(
            resume: resume,
            pause: pause,
            startPlaylist: startPlaylist,
            isPlaying: isPlaying,
            audios: Set.from(sortedAudios),
            listName: context.l10n.localAudio,
            editableName: false,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          child: AudioTileHeader(
            showTrack: true,
            audioFilter: _filter,
            onAudioFilterSelected: (audioFilter) => setState(() {
              _filter = audioFilter;
            }),
          ),
        ),
        const Divider(
          height: 0,
        ),
        Expanded(
          child: ListView.builder(
            controller: _controller,
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            itemCount: sortedAudios.take(_amount).length,
            itemBuilder: (context, index) {
              final audio = sortedAudios.elementAt(index);
              final audioSelected = currentAudio == audio;

              final liked = isLiked(audio);

              final superLikeButton = SuperLikeButton(
                onCreateNewPlaylist: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return PlaylistDialog(
                        audios: {audio},
                        onCreateNewPlaylist: addPlaylist,
                      );
                    },
                  );
                },
                onAddToPlaylist: (playlistId) =>
                    addAudioToPlaylist(playlistId, audio),
                topFivePlaylistIds: getPlaylistIds(),
                icon: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () =>
                      liked ? removeLikedAudio(audio) : addLikedAudio(audio),
                  child: Icon(
                    liked ? YaruIcons.heart_filled : YaruIcons.heart,
                    color: audioSelected
                        ? theme.colorScheme.onSurface
                        : theme.hintColor,
                  ),
                ),
              );

              return AudioTile(
                onArtistTap: widget.onArtistTap,
                onAlbumTap: widget.onAlbumTap,
                likeIcon: superLikeButton,
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
              );
            },
          ),
        )
      ],
    );
  }
}
