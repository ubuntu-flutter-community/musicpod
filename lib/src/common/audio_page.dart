import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../common.dart';
import '../../data.dart';

class AudioPage extends StatelessWidget {
  const AudioPage({
    super.key,
    required this.audios,
    required this.audioPageType,
    required this.pageId,
    this.title,
    this.controlPanelButton,
    this.headerTitle,
    this.headerSubtile,
    this.headerLabel,
    this.headerDescription,
    this.image,
    this.onAlbumTap,
    this.onArtistTap,
    this.noResultMessage,
    this.noResultIcon,
    this.titleLabel,
    this.artistLabel,
    this.albumLabel,
    this.controlPanelTitle,
    this.titleFlex = 1,
    this.artistFlex = 1,
    this.albumFlex = 1,
    this.showTrack = true,
    this.showAlbum = true,
    this.showArtist = true,
    this.imageRadius,
    this.onLabelTab,
    this.onSubTitleTab,
    this.onAudioFilterSelected,
    this.classicTiles = true,
  });

  final Set<Audio>? audios;
  final AudioPageType audioPageType;
  final String? headerLabel;
  final String pageId;
  final String? headerTitle;
  final Widget? controlPanelTitle;
  final String? headerDescription;
  final String? headerSubtile;
  final Widget? controlPanelButton;
  final Widget? title;
  final Widget? image;
  final Widget? noResultMessage;
  final Widget? noResultIcon;
  final String? titleLabel, artistLabel, albumLabel;
  final int titleFlex, artistFlex, albumFlex;
  final bool showTrack, showAlbum, showArtist;
  final BorderRadius? imageRadius;
  final void Function(String text)? onSubTitleTab;
  final void Function(String text)? onLabelTab;
  final void Function(String text)? onAlbumTap;
  final void Function(String text)? onArtistTap;
  final void Function(AudioFilter)? onAudioFilterSelected;
  final bool classicTiles;

  @override
  Widget build(BuildContext context) {
    final body = AudioPageBody(
      key: ValueKey(audios?.length),
      classicTiles: classicTiles,
      pageId: pageId,
      audios: audios,
      noResultMessage: noResultMessage,
      noResultIcon: noResultIcon,
      onAlbumTap: onAlbumTap,
      onArtistTap: onArtistTap,
      audioPageType: audioPageType,
      image: image,
      imageRadius: imageRadius,
      headerDescription: headerDescription,
      controlPanelButton: controlPanelButton,
      headerLabel: headerLabel,
      onLabelTab: onLabelTab,
      headerSubTitle: headerSubtile,
      onSubTitleTab: onSubTitleTab,
      headerTitle: headerTitle,
      controlPanelTitle: controlPanelTitle,
      albumFlex: albumFlex,
      titleFlex: titleFlex,
      artistFlex: artistFlex,
      titleLabel: titleLabel,
      artistLabel: artistLabel,
      albumLabel: albumLabel,
      showTrack: showTrack,
      showAlbum: showAlbum,
      showArtist: showArtist,
      onAudioFilterSelected: onAudioFilterSelected,
    );

    return YaruDetailPage(
      key: ValueKey(pageId),
      appBar: HeaderBar(
        adaptive: true,
        title: isMobile ? null : (title ?? Text(headerTitle ?? pageId)),
      ),
      body: AdaptiveContainer(child: body),
    );
  }
}
