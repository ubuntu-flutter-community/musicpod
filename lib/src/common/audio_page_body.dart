import 'package:animated_emoji/animated_emoji.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../player.dart';
import '../../podcasts.dart';
import '../app/connectivity_notifier.dart';
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
    this.onAlbumTap,
    this.onArtistTap,
    this.noResultMessage,
    this.noResultIcon = const AnimatedEmoji(AnimatedEmojis.eyes),
    this.titleLabel,
    this.artistLabel,
    this.albumLabel,
    this.controlPanelTitle,
    this.showTrack = true,
    this.showAlbum = true,
    this.showArtist = true,
    this.titleFlex = 1,
    this.artistFlex = 1,
    this.albumFlex = 1,
    this.showAudioTileHeader = true,
    this.padding,
    this.showControlPanel = true,
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
  final bool showControlPanel;
  final bool showAudioTileHeader;
  final Widget? noResultMessage;
  final Widget? noResultIcon;
  final String? titleLabel, artistLabel, albumLabel;
  final int titleFlex, artistFlex, albumFlex;
  final bool showTrack, showAlbum, showArtist;
  final EdgeInsetsGeometry? padding;

  final void Function({
    required String text,
    required AudioType audioType,
  })? onAlbumTap, onArtistTap;

  @override
  State<AudioPageBody> createState() => _AudioPageBodyState();
}

class _AudioPageBodyState extends State<AudioPageBody> {
  late ScrollController _controller;
  double _headerHeight = kAudioPageHeaderHeight;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()..addListener(_listener);
  }

  void _listener() {
    if (_controller.position.userScrollDirection == ScrollDirection.reverse) {
      if (_headerHeight != 0) {
        setState(() => _headerHeight = 0);
      }
    }
    if (_controller.position.userScrollDirection == ScrollDirection.forward) {
      if (_headerHeight == 0) {
        setState(() => _headerHeight = kAudioPageHeaderHeight);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = context.select((ConnectivityNotifier c) => c.isOnline);
    final playerService = getService<PlayerService>();

    final startPlaylist = playerService.startPlaylist;

    final currentAudio = playerService.audio.watch(context);
    final play = playerService.play;
    final pause = playerService.pause;
    final resume = playerService.resume;
    final insertIntoQueue = playerService.insertIntoQueue;

    if (widget.audioPageType != AudioPageType.podcast) {
      context.select((LibraryModel m) => m.likedAudios.length);
    }
    if (widget.audioPageType == AudioPageType.playlist) {
      context.select((LibraryModel m) => m.playlists[widget.pageId]?.length);
    }

    final libraryModel = context.read<LibraryModel>();

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
        onTap: widget.audios?.isNotEmpty == false
            ? null
            : () => startPlaylist(
                  audios: widget.audios!,
                  listName: widget.pageId,
                ),
        controlButton: widget.controlPanelButton,
        audios: widget.audios ?? {},
      ),
    );

    final audioPageHeader = AudioPageHeader(
      height: _headerHeight,
      title: widget.headerTitle ??
          widget.audios?.firstOrNull?.album ??
          widget.pageId,
      description:
          widget.headerDescription ?? widget.audios?.firstOrNull?.description,
      image: widget.image,
      subTitle: widget.headerSubTitle,
      label: widget.headerLabel,
    );

    if (widget.audios == null) {
      return Column(
        children: [
          if (widget.showAudioPageHeader == true) audioPageHeader,
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
            if (widget.showAudioPageHeader == true) audioPageHeader,
            audioControlPanel,
            Expanded(
              child: NoSearchResultPage(
                icons: widget.noResultIcon,
                message: widget.noResultMessage,
              ),
            ),
          ],
        );
      }
    }

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Stack(
        children: [
          Column(
            children: [
              if (widget.showAudioPageHeader == true) audioPageHeader,
              if (widget.showControlPanel) audioControlPanel,
              if (widget.showAudioTileHeader)
                AudioTileHeader(
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
              if (widget.showAudioTileHeader) const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: _controller,
                  itemCount: widget.audios?.length,
                  itemBuilder: (context, index) {
                    final isPlaying = playerService.isPlaying.watch(context);

                    final audio = widget.audios!.elementAt(index);
                    final audioSelected = currentAudio == audio;
                    final download = libraryModel.getDownload(audio.url);

                    if (audio.audioType == AudioType.podcast &&
                        widget.audioPageType != AudioPageType.playlist) {
                      return PodcastAudioTile(
                        addPodcast:
                            audio.website == null || widget.audios == null
                                ? null
                                : () => libraryModel.addPodcast(
                                      audio.website!,
                                      widget.audios!,
                                    ),
                        removeUpdate: () =>
                            libraryModel.removePodcastUpdate(widget.pageId),
                        isExpanded: audioSelected,
                        audio: download != null
                            ? audio.copyWith(path: download)
                            : audio,
                        isPlayerPlaying: isPlaying,
                        selected: audioSelected,
                        pause: pause,
                        resume: resume,
                        play: play,
                        lastPosition: playerService.getLastPosition(audio.url),
                        safeLastPosition: playerService.safeLastPosition,
                        isOnline: isOnline,
                        insertIntoQueue: () =>
                            playerService.insertIntoQueue(audio),
                      );
                    }

                    final likeButton = LikeButton(
                      key: ObjectKey(audio),
                      libraryModel: libraryModel,
                      playlistId: widget.pageId,
                      audio: audio,
                      allowRemove:
                          widget.audioPageType == AudioPageType.playlist,
                      insertIntoQueue: () => insertIntoQueue(audio),
                    );

                    return AudioTile(
                      trackLabel: (widget.audioPageType ==
                                  AudioPageType.playlist ||
                              widget.audioPageType == AudioPageType.likedAudio)
                          ? (index + 1).toString().padLeft(2, '0')
                          : null,
                      showAlbum: widget.showAlbum,
                      showArtist: widget.showArtist,
                      showTrack: widget.showTrack,
                      titleFlex: widget.titleFlex,
                      artistFlex: widget.artistFlex,
                      albumFlex: widget.albumFlex,
                      onAlbumTap: widget.onAlbumTap,
                      onArtistTap: widget.onArtistTap,
                      isPlayerPlaying: isPlaying,
                      pause: pause,
                      startPlaylist: widget.audios == null
                          ? null
                          : () => startPlaylist(
                                audios: widget.audios!,
                                listName: widget.pageId,
                                index: index,
                              ),
                      resume: resume,
                      key: ValueKey(audio),
                      selected: audioSelected,
                      audio: audio,
                      likeIcon: likeButton,
                    );
                  },
                ),
              ),
            ],
          ),
          if (_headerHeight == 0)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                child: Icon(Iconz().goUp),
                onPressed: () {
                  _controller.animateTo(
                    0,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeInOut,
                  );
                  setState(() => _headerHeight = kAudioPageHeaderHeight);
                },
              ),
            ),
        ],
      ),
    );
  }
}
