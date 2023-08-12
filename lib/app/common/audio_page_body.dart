import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_filter.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/app/common/audio_page_control_panel.dart';
import 'package:musicpod/app/common/audio_page_header.dart';
import 'package:musicpod/app/common/audio_tile.dart';
import 'package:musicpod/app/common/audio_tile_header.dart';
import 'package:musicpod/app/common/like_button.dart';
import 'package:musicpod/app/library_model.dart';
import 'package:musicpod/app/player/player_model.dart';
import 'package:musicpod/app/podcasts/podcast_audio_tile.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:musicpod/utils.dart';
import 'package:provider/provider.dart';
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
    this.pageSubTitle,
    required this.editableName,
    this.likePageButton,
    required this.sort,
    required this.showTrack,
    this.image,
    this.showAudioPageHeader,
    required this.audioFilter,
    this.onTextTap,
    this.noResultMessage,
    this.titleLabel,
    this.artistLabel,
    this.albumLabel,
    this.pageTitleWidget,
    this.titleFlex = 5,
    this.artistFlex = 5,
    this.albumFlex = 4,
    this.showAudioTileHeader = true,
    this.countryCode,
  });

  final Set<Audio>? audios;
  final AudioPageType audioPageType;
  final String? pageLabel;
  final String pageId;
  final Widget? pageTitleWidget;

  final String? pageTitle;
  final String? pageDescription;
  final String? pageSubTitle;
  final bool editableName;
  final Widget? likePageButton;
  final bool sort;
  final bool showTrack;
  final Widget? image;
  final bool? showAudioPageHeader;
  final bool showAudioTileHeader;
  final AudioFilter audioFilter;
  final String? noResultMessage;
  final String? titleLabel, artistLabel, albumLabel;
  final int titleFlex, artistFlex, albumFlex;
  final String? countryCode;

  final void Function({
    required String text,
    required AudioType audioType,
  })? onTextTap;

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

    final playerModel = context.read<PlayerModel>();
    final startPlaylist = playerModel.startPlaylist;

    final queueName = context.select((PlayerModel m) => m.queueName);
    final currentAudio = context.select((PlayerModel m) => m.audio);
    final play = playerModel.play;
    final pause = playerModel.pause;
    final resume = playerModel.resume;

    context.select((LibraryModel m) => m.likedAudios.length);
    final libraryModel = context.read<LibraryModel>();
    final liked = libraryModel.liked;
    final removeLikedAudio = libraryModel.removeLikedAudio;
    final addLikedAudio = libraryModel.addLikedAudio;
    final void Function(String, Audio) removeAudioFromPlaylist =
        libraryModel.removeAudioFromPlaylist;
    final List<String> Function() getTopFivePlaylistNames =
        libraryModel.getTopFivePlaylistNames;
    final void Function(String, Audio) addAudioToPlaylist =
        libraryModel.addAudioToPlaylist;
    final void Function(String, Set<Audio>) addPlaylist =
        libraryModel.addPlaylist;

    final removePlaylist = libraryModel.removePlaylist;
    final updatePlaylistName = libraryModel.updatePlaylistName;

    final sortedAudios = widget.audios?.toList() ?? [];

    final audioControlPanel = Padding(
      padding: const EdgeInsets.only(
        top: 10,
        left: 20,
        right: 20,
        bottom: 15,
      ),
      child: AudioPageControlPanel(
        title: widget.pageTitleWidget,
        removePlaylist: removePlaylist,
        updatePlaylistName: updatePlaylistName,
        pause: pause,
        resume: resume,
        startPlaylist: startPlaylist,
        isPlaying: isPlaying,
        queueName: queueName,
        listName: widget.pageTitle ?? widget.pageId,
        pinButton: widget.likePageButton,
        editableName: widget.editableName,
        audios: sortedAudios.toSet(),
      ),
    );

    if (widget.audios == null) {
      return Column(
        children: [
          audioControlPanel,
          const Expanded(
            child: Center(
              child: YaruCircularProgressIndicator(),
            ),
          ),
        ],
      );
    } else {
      if (widget.audios!.isEmpty) {
        return Column(
          children: [
            audioControlPanel,
            Expanded(
              child: Center(
                child:
                    Text(widget.noResultMessage ?? context.l10n.nothingFound),
              ),
            ),
          ],
        );
      }
    }

    if (widget.sort) {
      sortListByAudioFilter(audioFilter: _filter, audios: sortedAudios);
    }

    return SingleChildScrollView(
      controller: _controller,
      child: Column(
        children: [
          if (widget.showAudioPageHeader == true)
            AudioPageHeader(
              title: widget.pageTitle ?? sortedAudios.firstOrNull?.album ?? '',
              description: widget.pageDescription ??
                  sortedAudios.firstOrNull?.description,
              image: widget.image,
              subTitle: widget.pageSubTitle,
              label: widget.pageLabel,
            ),
          Padding(
            padding: widget.showAudioPageHeader == false
                ? const EdgeInsets.only(top: 10)
                : EdgeInsets.zero,
            child: audioControlPanel,
          ),
          if (widget.showAudioTileHeader)
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: AudioTileHeader(
                titleFlex: widget.titleFlex,
                artistFlex: widget.artistFlex,
                albumFlex: widget.albumFlex,
                titleLabel: widget.titleLabel,
                artistLabel: widget.artistLabel,
                albumLabel: widget.albumLabel,
                showTrack: widget.showTrack,
                audioFilter: AudioFilter.title,
                onAudioFilterSelected: widget.sort == false
                    ? null
                    : (audioFilter) => setState(() {
                          _filter = audioFilter;
                        }),
              ),
            ),
          if (widget.showAudioTileHeader)
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

                final likeButton = LikeButton(
                  key: ObjectKey(audio),
                  pageId: widget.pageId,
                  audio: audio,
                  audioSelected: audioSelected,
                  audioPageType: widget.audioPageType,
                  isLiked: liked,
                  removeLikedAudio: removeLikedAudio,
                  addLikedAudio: addLikedAudio,
                  removeAudioFromPlaylist: removeAudioFromPlaylist,
                  getTopFivePlaylistNames: getTopFivePlaylistNames,
                  addAudioToPlaylist: addAudioToPlaylist,
                  addPlaylist: addPlaylist,
                );

                if (audio.audioType == AudioType.podcast) {
                  return PodcastAudioTile(
                    isExpanded: audioSelected,
                    audio: audio,
                    isPlayerPlaying: isPlaying,
                    selected: audioSelected,
                    pause: pause,
                    resume: resume,
                    startPlaylist: widget.audios == null
                        ? null
                        : () => play(newAudio: audio),
                    play: play,
                    lastPosition: null,
                    countryCode: widget.countryCode,
                  );
                }

                return AudioTile(
                  titleFlex: widget.titleFlex,
                  artistFlex: widget.artistFlex,
                  albumFlex: widget.albumFlex,
                  onTextTap: widget.onTextTap,
                  isPlayerPlaying: isPlaying,
                  pause: pause,
                  play: () async {
                    await play(newAudio: audio);
                  },
                  startPlaylist: widget.audios == null
                      ? null
                      : () => startPlaylist(
                            widget.audios!.skip(index).toSet(),
                            queueName ??
                                audio.artist ??
                                audio.album ??
                                widget.audios.toString(),
                          ),
                  resume: resume,
                  key: ValueKey(audio),
                  selected: audioSelected,
                  audio: audio,
                  likeIcon: likeButton,
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}
