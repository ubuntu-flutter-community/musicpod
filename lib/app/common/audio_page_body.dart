import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:musicpod/app/common/audio_filter.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/app/common/audio_page_control_panel.dart';
import 'package:musicpod/app/common/audio_page_header.dart';
import 'package:musicpod/app/common/audio_tile.dart';
import 'package:musicpod/app/common/super_like_button.dart';
import 'package:musicpod/app/player_model.dart';
import 'package:musicpod/app/playlists/playlist_dialog.dart';
import 'package:musicpod/app/playlists/playlist_model.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:musicpod/utils.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AudioPageBody extends StatefulWidget {
  const AudioPageBody({
    super.key,
    this.audios,
    required this.audioPageType,
    this.pageLabel,
    required this.pageId,
    this.pageTitle,
    this.pageDescription,
    this.pageSubtile,
    required this.editableName,
    required this.deletable,
    this.likePageButton,
    this.imageUrl,
    required this.sort,
    required this.showTrack,
    required this.showWindowControls,
    this.image,
    this.placeTrailer,
    required this.audioFilter,
  });

  final Set<Audio>? audios;
  final AudioPageType audioPageType;
  final String? pageLabel;
  final String pageId;
  final String? pageTitle;
  final String? pageDescription;
  final String? pageSubtile;
  final bool editableName;
  final bool deletable;
  final Widget? likePageButton;
  final String? imageUrl;
  final bool sort;
  final bool showTrack;
  final bool showWindowControls;
  final Widget? image;
  final bool? placeTrailer;
  final AudioFilter audioFilter;

  @override
  State<AudioPageBody> createState() => _AudioPageBodyState();
}

class _AudioPageBodyState extends State<AudioPageBody> {
  late ScrollController _controller;
  int _amount = 40;
  late AudioFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.audioFilter;
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
    final isPlaying = context.select((PlayerModel m) => m.isPlaying);
    final setAudio = context.read<PlayerModel>().setAudio;
    final currentAudio = context.select((PlayerModel m) => m.audio);
    final play = context.read<PlayerModel>().play;
    final pause = context.read<PlayerModel>().pause;
    final resume = context.read<PlayerModel>().resume;

    final isLiked = context.read<PlaylistModel>().liked;
    final removeLikedAudio = context.read<PlaylistModel>().removeLikedAudio;
    final addLikedAudio = context.read<PlaylistModel>().addLikedAudio;
    final isStarredStation = context.read<PlaylistModel>().isStarredStation;
    final addStarredStation = context.read<PlaylistModel>().addStarredStation;
    final unStarStation = context.read<PlaylistModel>().unStarStation;
    final removeAudioFromPlaylist =
        context.read<PlaylistModel>().removeAudioFromPlaylist;
    final getTopFivePlaylistNames =
        context.read<PlaylistModel>().getTopFivePlaylistNames;
    final addAudioToPlaylist = context.read<PlaylistModel>().addAudioToPlaylist;
    final addPlaylist = context.read<PlaylistModel>().addPlaylist;

    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;

    if (widget.audios == null) {
      return const Center(
        child: YaruCircularProgressIndicator(),
      );
    }

    var sortedAudios = widget.audios!.toList();

    if (widget.sort) {
      sortListByAudioFilter(audioFilter: _filter, audios: sortedAudios);
    }

    final description =
        widget.pageDescription ?? sortedAudios.firstOrNull?.description ?? '';

    final title = widget.pageTitle ?? sortedAudios.firstOrNull?.album ?? '';

    return SingleChildScrollView(
      controller: _controller,
      child: Column(
        children: [
          if (widget.placeTrailer == true)
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
                  if (widget.image != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: widget.image!,
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.pageLabel ?? context.l10n.album,
                          style: theme.textTheme.labelSmall,
                        ),
                        Text(
                          title,
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
                          widget.pageSubtile ??
                              sortedAudios.firstOrNull?.artist ??
                              '',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: SizedBox(
                              width: 800,
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(kYaruButtonRadius),
                                onTap: () => showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: YaruDialogTitleBar(
                                      title: Text(title),
                                      backgroundColor: Colors.transparent,
                                      border: BorderSide.none,
                                    ),
                                    titlePadding: EdgeInsets.zero,
                                    contentPadding: const EdgeInsets.only(
                                      top: 10,
                                      left: kYaruPagePadding,
                                      right: kYaruPagePadding,
                                      bottom: kYaruPagePadding,
                                    ),
                                    content: SizedBox(
                                      width: 400,
                                      child: Html(
                                        data: description,
                                        style: {
                                          'html': Style(
                                            margin: EdgeInsets.zero,
                                            padding: EdgeInsets.zero,
                                          ),
                                          'body': Style(
                                            margin: EdgeInsets.zero,
                                            padding: EdgeInsets.zero,
                                            color: theme.hintColor,
                                          )
                                        },
                                      ),
                                    ),
                                    scrollable: true,
                                  ),
                                ),
                                child: Html(
                                  data: description,
                                  style: {
                                    'html': Style(
                                      margin: EdgeInsets.zero,
                                      padding: EdgeInsets.zero,
                                    ),
                                    'body': Style(
                                      margin: EdgeInsets.zero,
                                      padding: EdgeInsets.zero,
                                      color: theme.hintColor,
                                      textOverflow: TextOverflow.ellipsis,
                                      maxLines: 4,
                                    )
                                  },
                                ),
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
            child: AudioPageControlPanel(
              listName: widget.pageId,
              likeButton: widget.likePageButton,
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
            child: AudioPageHeader(
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
                final audioSelected = currentAudio == audio;

                final liked = isLiked(audio);

                final likedAudioButton = InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () =>
                      liked ? removeLikedAudio(audio) : addLikedAudio(audio),
                  child: Icon(
                    liked ? YaruIcons.heart_filled : YaruIcons.heart,
                    color: audioSelected
                        ? theme.colorScheme.onSurface
                        : theme.hintColor,
                  ),
                );

                final starred = audio.title == null
                    ? false
                    : isStarredStation(audio.title!);

                final starStationButton = InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: audio.title == null
                      ? null
                      : () {
                          !starred
                              ? addStarredStation(audio.title!, {audio})
                              : unStarStation(audio.title!);
                        },
                  child: Icon(
                    starred ? YaruIcons.star_filled : YaruIcons.star,
                    color: audioSelected
                        ? theme.colorScheme.onSurface
                        : theme.hintColor,
                  ),
                );

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
                  likeIcon: widget.audioPageType != AudioPageType.podcast &&
                          widget.audioPageType != AudioPageType.radio
                      ? SuperLikeButton(
                          playlistId: widget.pageId,
                          onRemoveFromPlaylist:
                              widget.audioPageType == AudioPageType.album ||
                                      widget.audioPageType ==
                                          AudioPageType.immutable
                                  ? null
                                  : (v) => removeAudioFromPlaylist(v, audio),
                          onCreateNewPlaylist: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return SimplePlaylistDialog(
                                  audio: audio,
                                  onCreateNewPlaylist: addPlaylist,
                                );
                              },
                            );
                          },
                          onAddToPlaylist: (playlistId) =>
                              addAudioToPlaylist(playlistId, audio),
                          topFivePlaylistIds: getTopFivePlaylistNames(),
                          icon: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => liked
                                ? removeLikedAudio(audio)
                                : addLikedAudio(audio),
                            child: Icon(
                              liked ? YaruIcons.heart_filled : YaruIcons.heart,
                              color: audioSelected
                                  ? theme.colorScheme.onSurface
                                  : theme.hintColor,
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(right: 30, left: 10),
                          child: widget.audioPageType == AudioPageType.radio
                              ? starStationButton
                              : likedAudioButton,
                        ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}
