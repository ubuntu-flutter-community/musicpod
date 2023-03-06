import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:music/app/common/audio_list.dart';
import 'package:music/app/common/audio_tile.dart';
import 'package:music/app/common/safe_network_image.dart';
import 'package:music/app/common/search_field.dart';
import 'package:music/app/local_audio/local_audio_model.dart';
import 'package:music/app/player_model.dart';
import 'package:music/app/playlists/playlist_dialog.dart';
import 'package:music/app/playlists/playlist_model.dart';
import 'package:music/data/audio.dart';
import 'package:music/l10n/l10n.dart';
import 'package:music/utils.dart';
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
    this.title,
    this.imageUrl,
    this.likeButton,
    this.sort = true,
    this.showTrack = true,
    this.showWindowControls = true,
  });

  final Set<Audio> audios;
  final String pageName;
  final bool editableName;
  final bool deletable;
  final AudioPageType audioPageType;
  final Widget? likeButton;
  final Widget? title;
  final String? imageUrl;
  final bool sort;
  final bool showTrack;
  final bool showWindowControls;

  @override
  State<AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  late ScrollController _controller;
  int _amount = 40;
  AudioFilter _filter = AudioFilter.trackNumber;

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
    final light = theme.brightness == Brightness.light;

    var sortedAudios = widget.audios.toList();

    if (widget.sort) {
      sortListByAudioFilter(audioFilter: _filter, audios: sortedAudios);
    }

    Widget? body = Padding(
      padding: const EdgeInsets.only(top: 20),
      child: AudioList(
        deletable: widget.deletable,
        listName: widget.pageName,
        audios: sortedAudios.toSet(),
        editableName: widget.editableName,
        likeButton: widget.likeButton,
      ),
    );
    if (widget.audioPageType == AudioPageType.albumList &&
        sortedAudios.firstOrNull?.metadata?.album != null) {
      body = SingleChildScrollView(
        controller: _controller,
        child: Column(
          children: [
            Container(
              height: 240,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    light ? Colors.white : Colors.transparent,
                    light ? const Color(0xFFfafafa) : theme.cardColor
                  ],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (sortedAudios.firstOrNull?.metadata?.picture != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          sortedAudios.firstOrNull!.metadata!.picture!.data,
                          width: 200.0,
                          fit: BoxFit.fitWidth,
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                    )
                  else if (widget.imageUrl != null ||
                      sortedAudios.firstOrNull?.imageUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SafeNetworkImage(
                          fallBackIcon: SizedBox(
                            width: 200,
                            child: Center(
                              child: Icon(
                                YaruIcons.music_note,
                                size: 80,
                                color: theme.hintColor,
                              ),
                            ),
                          ),
                          url: widget.imageUrl ??
                              sortedAudios.firstOrNull?.imageUrl,
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
                          sortedAudios.firstOrNull!.metadata?.album ?? '',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w300,
                            fontSize: 50,
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          sortedAudios.firstOrNull?.metadata?.artist ?? '',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        if (sortedAudios.firstOrNull?.description != null)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: SizedBox(
                                width: 500,
                                child: Text(
                                  sortedAudios.firstOrNull!.description!.trim(),
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
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: 15,
              ),
              child: AudioListControlPanel(
                likeButton: widget.likeButton,
                editableName: widget.editableName,
                audios: sortedAudios.toSet(),
                deletable: widget.deletable,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: AudioListHeader(
                showTrack: widget.showTrack,
                audioFilter: AudioFilter.title,
                onAudioFilterSelected: (audioFilter) => setState(() {
                  _filter = audioFilter;
                }),
              ),
            ),
            const Divider(
              height: 0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Column(
                children:
                    List.generate(sortedAudios.take(_amount).length, (index) {
                  final audio = sortedAudios.elementAt(index);
                  final audioSelected = playerModel.audio == audio;

                  final liked = playlistModel.liked(audio);

                  return AudioTile(
                    isPlayerPlaying: playerModel.isPlaying,
                    pause: playerModel.pause,
                    play: () {
                      WidgetsBinding.instance
                          .addPostFrameCallback((timeStamp) async {
                        if (context.mounted) {
                          playerModel.audio = audio;
                          await playerModel.play();
                        }
                      });
                    },
                    key: ValueKey(audio),
                    selected: audioSelected,
                    audio: audio,
                    // TODO: extract popup menu button!!!
                    likeIcon: YaruPopupMenuButton(
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
                              onTap: () =>
                                  playlistModel.removeAudioFromPlaylist(
                                widget.pageName,
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
                }),
              ),
            )
          ],
        ),
      );
    }

    return YaruDetailPage(
      backgroundColor: theme.brightness == Brightness.dark
          ? const Color.fromARGB(255, 37, 37, 37)
          : Colors.white,
      appBar: YaruWindowTitleBar(
        style: widget.showWindowControls
            ? YaruTitleBarStyle.normal
            : YaruTitleBarStyle.undecorated,
        title: widget.title ??
            SearchField(
              spawnPageWithWindowControls: widget.showWindowControls,
            ),
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
  if (audio == null) return null;

  if (audio.path != null) {
    final image = MemoryImage(
      audio.metadata!.picture!.data,
    );
    final generator = await PaletteGenerator.fromImageProvider(image);
    return generator.dominantColor?.color.withOpacity(0.1);
  } else if (audio.audioType == AudioType.podcast) {
    if (audio.imageUrl == null) return null;
    final image = NetworkImage(
      audio.imageUrl!,
    );
    final generator = await PaletteGenerator.fromImageProvider(image);
    return generator.dominantColor?.color.withOpacity(0.1);
  }
  return null;
}
