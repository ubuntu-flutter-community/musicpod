import 'package:flutter/material.dart';
import 'package:music/app/common/audio_tile.dart';
import 'package:music/app/local_audio/local_audio_model.dart';
import 'package:music/app/player_model.dart';
import 'package:music/app/playlists/playlist_dialog.dart';
import 'package:music/app/playlists/playlist_model.dart';
import 'package:music/data/audio.dart';
import 'package:music/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';
import 'package:collection/collection.dart';

class AudioList extends StatefulWidget {
  const AudioList({
    super.key,
    required this.audios,
    this.likeIcon,
    this.listName,
    this.onAudioFilterSelected,
    this.audioFilter,
  });

  final Set<Audio> audios;
  final Widget? likeIcon;
  final String? listName;
  final void Function(AudioFilter)? onAudioFilterSelected;
  final AudioFilter? audioFilter;

  static Widget create(BuildContext context, Set<Audio> audios) {
    return ChangeNotifierProvider(
      create: (_) {},
      child: AudioList(audios: audios),
    );
  }

  @override
  State<AudioList> createState() => _AudioListState();
}

class _AudioListState extends State<AudioList> {
  late ScrollController _controller;
  int _amount = 40;

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
    final playerModel = context.watch<PlayerModel>();
    final playlistModel = context.watch<PlaylistModel>();
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 15,
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.inverseSurface,
                child: IconButton(
                  onPressed: () {
                    if (playerModel.isPlaying) {
                      if (const ListEquality()
                          .equals(playerModel.queue, widget.audios.toList())) {
                        playerModel.pause();
                      } else {
                        playerModel.queue = widget.audios.toList();
                        playerModel.audio = widget.audios.first;
                        playerModel.stop();
                        playerModel.play();
                      }
                    } else {
                      if (const ListEquality()
                          .equals(playerModel.queue, widget.audios.toList())) {
                        playerModel.resume();
                      } else {
                        playerModel.queue = widget.audios.toList();
                        playerModel.audio = widget.audios.first;
                        playerModel.stop();
                        playerModel.play();
                      }
                    }
                  },
                  icon: Icon(
                    playerModel.isPlaying
                        ? (const ListEquality().equals(
                            playerModel.queue,
                            widget.audios.toList(),
                          )
                            ? YaruIcons.media_pause
                            : YaruIcons.media_play)
                        : YaruIcons.media_play,
                    color: theme.colorScheme.onInverseSurface,
                  ),
                ),
              ),
              const SizedBox(
                width: kYaruPagePadding,
              ),
              Expanded(
                child: Text(
                  '${widget.listName == 'likedAudio' ? context.l10n.likedSongs : widget.listName ?? ''}  •  ${widget.audios.length} ${context.l10n.titles}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w100),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 8, right: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kYaruButtonRadius),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _HeaderElement(
                  onAudioFilterSelected: widget.onAudioFilterSelected == null
                      ? null
                      : (_) => widget.onAudioFilterSelected!(AudioFilter.title),
                  label: context.l10n.title,
                ),
                _HeaderElement(
                  onAudioFilterSelected: widget.onAudioFilterSelected == null
                      ? null
                      : (_) =>
                          widget.onAudioFilterSelected!(AudioFilter.artist),
                  label: context.l10n.artist,
                ),
                _HeaderElement(
                  onAudioFilterSelected: widget.onAudioFilterSelected == null
                      ? null
                      : (_) => widget.onAudioFilterSelected!(AudioFilter.album),
                  label: context.l10n.album,
                ),
              ],
            ),
            trailing: YaruPopupMenuButton<AudioFilter>(
              initialValue: widget.audioFilter,
              onSelected: widget.onAudioFilterSelected,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  side: BorderSide.none,
                  borderRadius: BorderRadius.circular(kYaruButtonRadius),
                ),
              ),
              child: Icon(
                YaruIcons.ordered_list,
                color: theme.colorScheme.onSurface,
              ),
              itemBuilder: (a) => [
                for (final filter in AudioFilter.values)
                  PopupMenuItem(
                    value: filter,
                    child: Text(filter.name),
                  )
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _controller,
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            itemCount: widget.audios.take(_amount).length,
            itemBuilder: (context, index) {
              final audio = widget.audios.elementAt(index);
              final audioSelected = playerModel.audio == audio;

              final liked = playlistModel.liked(audio);

              return AudioTile(
                key: ValueKey(audio),
                selected: audioSelected,
                audio: audio,
                likeIcon: widget.likeIcon ??
                    YaruPopupMenuButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          side: BorderSide.none,
                          borderRadius:
                              BorderRadius.circular(kYaruButtonRadius),
                        ),
                      ),
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            child: Text(context.l10n.createNewPlaylist),
                            onTap: () => showDialog(
                              context: context,
                              builder: (context) {
                                return ChangeNotifierProvider.value(
                                  value: playlistModel,
                                  child: PlaylistDialog(
                                    audios: [audio],
                                  ),
                                );
                              },
                            ),
                          ),
                          if (playlistModel.playlists
                              .containsKey(widget.listName))
                            PopupMenuItem(
                              child: Text('Remove from ${widget.listName}'),
                              onTap: () =>
                                  playlistModel.removeAudioFromPlaylist(
                                widget.listName!,
                                audio,
                              ),
                            ),
                          for (final playlist in playlistModel.playlists.entries
                              .take(5)
                              .toList())
                            if (playlist.key != 'likedAudio')
                              PopupMenuItem(
                                child: Text(
                                  '${context.l10n.addTo} ${playlist.key == 'likedAudio' ? context.l10n.likedSongs : playlist.key}',
                                ),
                                onTap: () => playlistModel.addAudioToPlaylist(
                                  playlist.key,
                                  audio,
                                ),
                              )
                        ];
                      },
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => liked
                            ? playlistModel.removeLikedAudio(audio)
                            : playlistModel.addLikedAudio(audio),
                        child: Icon(
                          liked ? YaruIcons.heart_filled : YaruIcons.heart,
                          color: audioSelected
                              ? theme.colorScheme.onSurface
                              : theme.hintColor,
                        ),
                      ),
                    ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HeaderElement extends StatelessWidget {
  const _HeaderElement({
    this.onAudioFilterSelected,
    required this.label,
  });

  final void Function(AudioFilter)? onAudioFilterSelected;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = TextStyle(
      color: theme.colorScheme.onSurface,
      fontWeight: FontWeight.w500,
    );
    return Expanded(
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: onAudioFilterSelected == null
                ? null
                : () => onAudioFilterSelected!(AudioFilter.title),
            child: Text(
              label,
              style: textStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
