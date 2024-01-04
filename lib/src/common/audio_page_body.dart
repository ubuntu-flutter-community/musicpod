import 'package:animated_emoji/animated_emoji.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common.dart';
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
    this.onTextTap,
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
  final Widget? noResultIcon;
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
    final isOnline = context.select((ConnectivityNotifier c) => c.isOnline);

    final playerModel = context.read<PlayerModel>();
    final startPlaylist = playerModel.startPlaylist;

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
        onTap: widget.audios?.isNotEmpty == false
            ? null
            : () => startPlaylist(
                  audios: widget.audios!,
                  listName: widget.pageId,
                ),
        controlButton: widget.controlPanelButton,
        audios: sortedAudios.toSet(),
      ),
    );

    final audioPageHeader = AudioPageHeader(
      title: widget.headerTitle ?? sortedAudios.firstOrNull?.album ?? '',
      description:
          widget.headerDescription ?? sortedAudios.firstOrNull?.description,
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

    return SingleChildScrollView(
      padding: widget.padding,
      controller: _controller,
      child: Column(
        children: [
          if (widget.showAudioPageHeader == true) audioPageHeader,
          audioControlPanel,
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
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children:
                  List.generate(sortedAudios.take(_amount).length, (index) {
                final audio = sortedAudios.elementAt(index);
                final audioSelected = currentAudio == audio;
                final download = libraryModel.getDownload(audio.url);

                if (audio.audioType == AudioType.podcast &&
                    widget.audioPageType != AudioPageType.playlist) {
                  return PodcastAudioTile(
                    addPodcast: audio.website == null || widget.audios == null
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
                    selected: audioSelected,
                    pause: pause,
                    resume: resume,
                    play: play,
                    lastPosition: libraryModel.getLastPosition.call(audio.url),
                    safeLastPosition: playerModel.safeLastPosition,
                    isOnline: isOnline,
                    insertIntoQueue: () => playerModel.insertIntoQueue(audio),
                  );
                }

                final likeButton = LikeButton(
                  key: ObjectKey(audio),
                  libraryModel: libraryModel,
                  playlistId: widget.pageId,
                  audio: audio,
                  allowRemove: widget.audioPageType == AudioPageType.playlist,
                  insertIntoQueue: () => insertIntoQueue(audio),
                );

                return AudioTile(
                  trackLabel: widget.audioPageType == AudioPageType.playlist
                      ? (index + 1).toString().padLeft(2, '0')
                      : null,
                  showAlbum: widget.showAlbum,
                  showArtist: widget.showArtist,
                  showTrack: widget.showTrack,
                  titleFlex: widget.titleFlex,
                  artistFlex: widget.artistFlex,
                  albumFlex: widget.albumFlex,
                  onTextTap: widget.onTextTap,
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
              }),
            ),
          ),
        ],
      ),
    );
  }
}
