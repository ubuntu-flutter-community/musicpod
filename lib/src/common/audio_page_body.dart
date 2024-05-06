import 'package:animated_emoji/animated_emoji.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../get.dart';
import '../../l10n.dart';
import '../../player.dart';
import '../library/library_model.dart';

class AudioPageBody extends StatefulWidget with WatchItStatefulWidgetMixin {
  const AudioPageBody({
    super.key,
    required this.pageId,
    this.audios,
    required this.audioPageType,
    this.headerLabel,
    this.headerTitle,
    this.headerDescription,
    this.headerSubTitle,
    this.controlPanelButton,
    this.image,
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
    this.padding,
    this.imageRadius,
    this.onLabelTab,
    this.onSubTitleTab,
    this.onAudioFilterSelected,
    this.classicTiles = true,
    this.showAudioTileHeader = true,
  })  : showAudioPageHeader = audioPageType != AudioPageType.allTitlesView,
        showControlPanel = audioPageType != AudioPageType.allTitlesView;

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
  final BorderRadius? imageRadius;
  final bool? showAudioPageHeader;
  final bool showControlPanel;
  final bool showAudioTileHeader;
  final Widget? noResultMessage;
  final Widget? noResultIcon;
  final String? titleLabel, artistLabel, albumLabel;
  final int titleFlex, artistFlex, albumFlex;
  final bool showTrack, showAlbum, showArtist;
  final EdgeInsetsGeometry? padding;
  final void Function(String text)? onSubTitleTab;
  final void Function(String text)? onLabelTab;
  final void Function(String text)? onAlbumTap;
  final void Function(String text)? onArtistTap;
  final void Function(AudioFilter)? onAudioFilterSelected;
  final bool classicTiles;

  @override
  State<AudioPageBody> createState() => _AudioPageBodyState();
}

class _AudioPageBodyState extends State<AudioPageBody> {
  bool reorderAble = false;

  @override
  Widget build(BuildContext context) {
    final reorderAblePageType =
        (widget.audioPageType == AudioPageType.playlist ||
            widget.audioPageType == AudioPageType.likedAudio);
    final isReorderAble = reorderAble && reorderAblePageType;
    final isPlaying = watchPropertyValue((PlayerModel m) => m.isPlaying);

    final playerModel = getIt<PlayerModel>();
    final startPlaylist = playerModel.startPlaylist;

    final currentAudio = watchPropertyValue((PlayerModel m) => m.audio);
    final pause = playerModel.pause;
    final resume = playerModel.resume;

    watchPropertyValue((LibraryModel m) => m.likedAudios.length);
    if (widget.audioPageType == AudioPageType.playlist) {
      watchPropertyValue(
        (LibraryModel m) => m.playlists[widget.pageId]?.length,
      );
    }

    final libraryModel = getIt<LibraryModel>();

    final audioControlPanel = Padding(
      padding: kAudioControlPanelPadding,
      child: AudioPageControlPanel(
        title: widget.controlPanelTitle,
        onTap: widget.audios?.isNotEmpty == false
            ? null
            : () => startPlaylist(
                  audios: widget.audios!,
                  listName: widget.pageId,
                ),
        controlButton: reorderAblePageType && widget.audios?.isNotEmpty == true
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.controlPanelButton != null)
                    widget.controlPanelButton!,
                  IconButton(
                    tooltip: context.l10n.move,
                    isSelected: reorderAble,
                    onPressed: () {
                      setState(() {
                        reorderAble = !reorderAble;
                      });
                    },
                    icon: Icon(Iconz().reorder),
                  ),
                ],
              )
            : widget.controlPanelButton,
        audios: widget.audios ?? {},
      ),
    );

    final audioPageHeader = AudioPageHeader(
      imageRadius: widget.imageRadius,
      title: widget.headerTitle ??
          widget.audios?.firstOrNull?.album ??
          widget.pageId,
      description:
          widget.headerDescription ?? widget.audios?.firstOrNull?.description,
      image: widget.image,
      subTitle: widget.headerSubTitle,
      onSubTitleTab: widget.onSubTitleTab,
      label: widget.headerLabel,
      onLabelTab: widget.onLabelTab,
    );

    if (widget.audios == null) {
      return Column(
        children: [
          if (widget.showAudioPageHeader == true) audioPageHeader,
          if (widget.showControlPanel) audioControlPanel,
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
            if (widget.showControlPanel) audioControlPanel,
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

    Widget itemBuilder(BuildContext context, int index) {
      final audio = widget.audios!.elementAt(index);
      final audioSelected = currentAudio == audio;

      return AudioTile(
        key: reorderAblePageType ? ObjectKey(audio) : null,
        trackLabel: (widget.audioPageType == AudioPageType.playlist ||
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
        selected: audioSelected,
        audio: audio,
        insertIntoQueue: playerModel.insertIntoQueue,
        pageId: widget.pageId,
        libraryModel: libraryModel,
        audioPageType: widget.audioPageType,
        classic: widget.classicTiles,
      );
    }

    final audioTileHeader = widget.classicTiles
        ? AudioTileHeader(
            titleFlex: widget.titleFlex,
            artistFlex: widget.artistFlex,
            albumFlex: widget.albumFlex,
            titleLabel: widget.titleLabel,
            artistLabel: widget.artistLabel,
            albumLabel: widget.albumLabel,
            showTrack: widget.showTrack,
            showAlbum: widget.showAlbum,
            showArtist: widget.showArtist,
            onAudioFilterSelected: widget.onAudioFilterSelected,
          )
        : const SizedBox(height: 10);

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Column(
        children: [
          if (widget.showAudioPageHeader == true) audioPageHeader,
          if (widget.showControlPanel) audioControlPanel,
          if (widget.showAudioTileHeader) audioTileHeader,
          if (widget.showAudioTileHeader && widget.classicTiles)
            const Divider(),
          if (isReorderAble && widget.audios != null)
            Expanded(
              child: ReorderableListView.builder(
                itemBuilder: itemBuilder,
                itemCount: widget.audios!.length,
                onReorder: (oldIndex, newIndex) {
                  if (playerModel.queueName == widget.pageId) {
                    playerModel.moveAudioInQueue(oldIndex, newIndex);
                  }

                  libraryModel.moveAudioInPlaylist(
                    oldIndex: oldIndex,
                    newIndex: newIndex,
                    id: widget.pageId,
                  );
                },
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: widget.audios!.length,
                itemBuilder: itemBuilder,
              ),
            ),
        ],
      ),
    );
  }
}
