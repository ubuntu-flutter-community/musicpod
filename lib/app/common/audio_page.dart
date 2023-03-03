import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:music/app/common/audio_list.dart';
import 'package:music/app/common/audio_tile.dart';
import 'package:music/app/common/search_field.dart';
import 'package:music/app/player_model.dart';
import 'package:music/app/playlists/playlist_dialog.dart';
import 'package:music/app/playlists/playlist_model.dart';
import 'package:music/data/audio.dart';
import 'package:music/l10n/l10n.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AudioPage extends StatefulWidget {
  const AudioPage({
    super.key,
    required this.audios,
    required this.pageName,
    required this.editableName,
    required this.deletable,
    this.audioPageType = AudioPageType.list,
    this.showLikeButton = true,
    this.title,
  });

  final Set<Audio> audios;
  final String pageName;
  final bool editableName;
  final bool deletable;
  final AudioPageType audioPageType;
  final bool showLikeButton;
  final Widget? title;

  @override
  State<AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerModel = context.watch<PlayerModel>();
    final playlistModel = context.watch<PlaylistModel>();
    final theme = Theme.of(context);

    Widget? body = Padding(
      padding: const EdgeInsets.only(top: 20),
      child: AudioList(
        deletable: widget.deletable,
        listName: widget.pageName,
        audios: widget.audios,
        editableName: widget.editableName,
        showLikeButton: widget.showLikeButton,
      ),
    );
    if (widget.audioPageType == AudioPageType.albumList &&
        widget.audios.firstOrNull?.metadata?.album != null) {
      body = ListView(
        controller: _controller,
        children: [
          FutureBuilder<Color?>(
            future: getColor(widget.audios.firstOrNull),
            builder: (context, snapshot) {
              return Container(
                height: 240,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.transparent,
                      snapshot.data ?? theme.cardColor
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.audios.firstOrNull?.metadata?.picture != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            widget.audios.firstOrNull!.metadata!.picture!.data,
                            width: 200.0,
                            fit: BoxFit.fitWidth,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                      )
                    else if (widget.audios.firstOrNull?.imageUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.audios.firstOrNull!.imageUrl!,
                            width: 200.0,
                            fit: BoxFit.fitWidth,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            context.l10n.album,
                            style: theme.textTheme.labelSmall,
                          ),
                          Text(
                            widget.audios.firstOrNull!.metadata?.album ?? '',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w300,
                              fontSize: 50,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            widget.audios.firstOrNull?.metadata?.artist ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          if (widget.audios.firstOrNull?.description != null)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: SizedBox(
                                  width: 500,
                                  child: Text(
                                    widget.audios.firstOrNull!.description!
                                        .trim(),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.hintColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 4,
                                  ),
                                ),
                              ),
                            )
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: 15,
            ),
            child: AudioListControlPanel(
              editableName: widget.editableName,
              audios: widget.audios,
              deletable: widget.deletable,
              showLikeButton: widget.showLikeButton,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            child: AudioListHeader(),
          ),
          const Divider(
            height: 0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Column(
              children:
                  List.generate(widget.audios.take(_amount).length, (index) {
                final audio = widget.audios.elementAt(index);
                final audioSelected = playerModel.audio == audio;

                final liked = playlistModel.liked(audio);

                return AudioTile(
                  isPlayerPlaying: playerModel.isPlaying,
                  pause: playerModel.pause,
                  play: () {
                    playerModel.audio = audio;
                    playerModel.stop().then((_) => playerModel.play());
                  },
                  key: ValueKey(audio),
                  selected: audioSelected,
                  audio: audio,
                  // TODO: extract popup menu button!!!
                  likeIcon: YaruPopupMenuButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        side: BorderSide.none,
                        borderRadius: BorderRadius.circular(kYaruButtonRadius),
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
                                  deletable: widget.deletable,
                                  audios: {audio},
                                  editableName: widget.editableName,
                                ),
                              );
                            },
                          ),
                        ),
                        if (playlistModel.playlists
                            .containsKey(widget.pageName))
                          PopupMenuItem(
                            child: Text('Remove from ${widget.pageName}'),
                            onTap: () => playlistModel.removeAudioFromPlaylist(
                              widget.pageName,
                              audio,
                            ),
                          ),
                        for (final playlist
                            in playlistModel.playlists.entries.take(5).toList())
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
              }),
            ),
          )
        ],
      );
    }

    return YaruDetailPage(
      backgroundColor: theme.brightness == Brightness.dark
          ? const Color.fromARGB(255, 37, 37, 37)
          : Colors.white,
      appBar: YaruWindowTitleBar(
        title: widget.title ?? const SearchField(),
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

enum AudioPageType {
  albumList,
  list,
  grid,
  artistGrid,
}

Future<Color?> getColor(Audio? audio) async {
  if (audio == null || audio.path == null) return null;

  final image = MemoryImage(
    audio.metadata!.picture!.data,
  );
  final generator = await PaletteGenerator.fromImageProvider(image);
  return generator.dominantColor?.color.withOpacity(0.1);
}
