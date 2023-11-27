import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common.dart';
import '../../data.dart';
import '../../player.dart';
import '../../podcasts.dart';
import '../library/library_model.dart';

class AudioPageBody extends StatefulWidget {
  const AudioPageBody({
    super.key,
    this.audios,
    required this.audioPageType,
    this.headerLabel,
    required this.pageId,
    this.headerTitle,
    this.headerDescription,
    this.headerSubTitle,
    this.controlPanelButton,
    this.image,
    this.showAudioPageHeader,
    this.onTextTap,
    this.noResultMessage,
    this.titleLabel,
    this.artistLabel,
    this.albumLabel,
    this.controlPanelTitle,
    this.showTrack = true,
    this.showAlbum = true,
    this.showArtist = true,
    this.titleFlex = 5,
    this.artistFlex = 5,
    this.albumFlex = 4,
    this.showAudioTileHeader = true,
    this.padding,
  });

  final String pageId;
  final Set<Audio>? audios;
  final AudioPageType audioPageType;
  final String? headerLabel;
  final Widget? controlPanelTitle;
  final String? headerTitle;
  final String? headerDescription;
  final String? headerSubTitle;
  final Widget? controlPanelButton;
  final Widget? image;
  final bool? showAudioPageHeader;
  final bool showAudioTileHeader;
  final Widget? noResultMessage;
  final String? titleLabel, artistLabel, albumLabel;
  final int titleFlex, artistFlex, albumFlex;
  final bool showTrack, showAlbum, showArtist;
  final EdgeInsetsGeometry? padding;

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
    final isPlaying = context.select((PlayerModel m) => m.isPlaying);

    final playerModel = context.read<PlayerModel>();
    final startPlaylist = playerModel.startPlaylist;

    final queueName = context.select((PlayerModel m) => m.queueName);
    final currentAudio = context.select((PlayerModel m) => m.audio);
    final play = playerModel.play;
    final pause = playerModel.pause;
    final resume = playerModel.resume;
    final insertIntoQueue = playerModel.insertIntoQueue;

    context.select((LibraryModel m) => m.likedAudios.length);
    if (widget.audioPageType == AudioPageType.playlist) {
      context.select((LibraryModel m) => m.playlists[widget.pageId]?.length);
    }

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

    final sortedAudios = widget.audios?.toList() ?? [];

    final audioControlPanel = Padding(
      padding: const EdgeInsets.only(
        top: 10,
        left: 20,
        right: 20,
        bottom: 15,
      ),
      child: AudioPageControlPanel(
        title: widget.controlPanelTitle,
        pause: pause,
        resume: resume,
        startPlaylist: startPlaylist,
        isPlaying: isPlaying,
        queueName: queueName,
        listName: widget.headerTitle ?? widget.pageId,
        controlButton: widget.controlPanelButton,
        audios: sortedAudios.toSet(),
      ),
    );

    if (widget.audios == null) {
      return Column(
        children: [
          audioControlPanel,
          const Expanded(
            child: Center(
              child: Progress(),
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
              child: NoSearchResultPage(
                message: widget.noResultMessage,
              ),
            ),
          ],
        );
      }
    }

    return SingleChildScrollView(
      padding: widget.padding,
      controller: _controller,
      child: Column(
        children: [
          if (widget.showAudioPageHeader == true)
            AudioPageHeader(
              title:
                  widget.headerTitle ?? sortedAudios.firstOrNull?.album ?? '',
              description: widget.headerDescription ??
                  sortedAudios.firstOrNull?.description,
              image: widget.image,
              subTitle: widget.headerSubTitle,
              label: widget.headerLabel,
            ),
          audioControlPanel,
          if (widget.showAudioTileHeader)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AudioTileHeader(
                titleFlex: widget.titleFlex,
                artistFlex: widget.artistFlex,
                albumFlex: widget.albumFlex,
                titleLabel: widget.titleLabel,
                artistLabel: widget.artistLabel,
                albumLabel: widget.albumLabel,
                showTrack: widget.showTrack,
                showAlbum: widget.showAlbum,
                showArtist: widget.showArtist,
                audioFilter: AudioFilter.title,
              ),
            ),
          if (widget.showAudioTileHeader) const Divider(),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Column(
              children:
                  List.generate(sortedAudios.take(_amount).length, (index) {
                final audio = sortedAudios.elementAt(index);
                final audioSelected = currentAudio == audio;

                if (audio.audioType == AudioType.podcast) {
                  return PodcastAudioTile(
                    removeUpdate: () =>
                        libraryModel.removePodcastUpdate(widget.pageId),
                    updateAvailable:
                        libraryModel.podcastUpdateAvailable(widget.pageId),
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
                    lastPosition: libraryModel.getLastPosition.call(audio.url),
                    safeLastPosition: playerModel.safeLastPosition,
                  );
                }

                final likeButton = LikeButton(
                  key: ObjectKey(audio),
                  playlistId: widget.pageId,
                  audio: audio,
                  audioSelected: audioSelected,
                  liked: liked(audio),
                  removeLikedAudio: removeLikedAudio,
                  addLikedAudio: addLikedAudio,
                  onRemoveFromPlaylist:
                      widget.audioPageType != AudioPageType.playlist
                          ? null
                          : removeAudioFromPlaylist,
                  topFivePlaylistNames: getTopFivePlaylistNames(),
                  addAudioToPlaylist: addAudioToPlaylist,
                  addPlaylist: addPlaylist,
                  insertIntoQueue: () => insertIntoQueue(audio),
                );

                return AudioTile(
                  showAlbum: widget.showAlbum,
                  showArtist: widget.showArtist,
                  showTrack: widget.showTrack,
                  titleFlex: widget.titleFlex,
                  artistFlex: widget.artistFlex,
                  albumFlex: widget.albumFlex,
                  onTextTap: widget.onTextTap,
                  isPlayerPlaying: isPlaying,
                  pause: pause,
                  play: play,
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
          ),
        ],
      ),
    );
  }
}
