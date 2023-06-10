import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_filter.dart';
import 'package:musicpod/app/common/audio_page_body.dart';
import 'package:musicpod/data/audio.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AudioPage extends StatelessWidget {
  const AudioPage({
    super.key,
    required this.audios,
    required this.audioPageType,
    required this.pageId,
    required this.editableName,
    required this.deletable,
    this.title,
    this.imageUrl,
    this.controlPageButton,
    this.sort = true,
    this.showTrack = true,
    this.showWindowControls = true,
    this.pageLabel,
    this.pageDescription,
    this.pageTitle,
    this.pageSubtile,
    this.image,
    this.placeTrailer = true,
    this.audioFilter = AudioFilter.trackNumber,
    this.onArtistTap,
    this.onAlbumTap,
    this.placePlayAllButton = true,
    this.noResultMessage,
    this.titleLabel,
    this.artistLabel,
    this.albumLabel,
    this.pageTitleWidget,
  });

  final Set<Audio>? audios;
  final AudioPageType audioPageType;
  final String? pageLabel;
  final String pageId;
  final String? pageTitle;
  final Widget? pageTitleWidget;
  final String? pageDescription;
  final String? pageSubtile;
  final bool editableName;
  final bool deletable;
  final Widget? controlPageButton;
  final Widget? title;
  final String? imageUrl;
  final bool sort;
  final bool showTrack;
  final bool showWindowControls;
  final Widget? image;
  final bool? placeTrailer;
  final AudioFilter audioFilter;
  final bool placePlayAllButton;
  final String? noResultMessage;
  final String? titleLabel, artistLabel, albumLabel;

  final void Function(String artist)? onArtistTap;
  final void Function(String album)? onAlbumTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final body = AudioPageBody(
      titleLabel: titleLabel,
      artistLabel: artistLabel,
      albumLabel: albumLabel,
      noResultMessage: noResultMessage,
      placePlayAllButton: placePlayAllButton,
      onAlbumTap: onAlbumTap,
      onArtistTap: onArtistTap,
      audios: audios,
      audioPageType: audioPageType,
      pageId: pageId,
      editableName: editableName,
      deletable: deletable,
      sort: sort,
      showTrack: showTrack,
      showWindowControls: showWindowControls,
      audioFilter: audioFilter,
      image: image,
      imageUrl: imageUrl,
      pageDescription: pageDescription,
      likePageButton: controlPageButton,
      pageLabel: pageLabel,
      pageSubtile: pageSubtile,
      pageTitle: pageTitle,
      pageTitleWidget: pageTitleWidget,
      placeTrailer: placeTrailer,
    );

    return YaruDetailPage(
      key: ValueKey(pageId),
      backgroundColor: theme.brightness == Brightness.dark
          ? const Color.fromARGB(255, 37, 37, 37)
          : Colors.white,
      appBar: YaruWindowTitleBar(
        style: showWindowControls
            ? YaruTitleBarStyle.normal
            : YaruTitleBarStyle.undecorated,
        title: title ?? Text(pageTitle ?? pageId),
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
  immutable,
  artist,
  likedAudio,
  podcast,
  playlist,
  album,
  radio;
}
