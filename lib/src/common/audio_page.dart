import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../app.dart';
import '../../common.dart';
import '../../data.dart';
import '../../globals.dart';
import '../l10n/l10n.dart';

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
    this.showAudioPageHeader = true,
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
    this.showAudioTileHeader = true,
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
  final bool showAudioPageHeader;
  final bool showAudioTileHeader;
  final bool showTrack, showAlbum, showArtist;

  final void Function({
    required String text,
    required AudioType audioType,
  })? onAlbumTap, onArtistTap;

  @override
  Widget build(BuildContext context) {
    final showWindowControls =
        context.select((AppModel a) => a.showWindowControls);

    final body = AudioPageBody(
      key: ValueKey(audios?.length),
      pageId: pageId,
      audios: audios,
      noResultMessage: noResultMessage,
      noResultIcon: noResultIcon,
      onAlbumTap: onAlbumTap,
      onArtistTap: onArtistTap,
      audioPageType: audioPageType,
      image: image,
      headerDescription: headerDescription,
      controlPanelButton: controlPanelButton,
      headerLabel: headerLabel,
      headerSubTitle: headerSubtile,
      headerTitle: headerTitle,
      controlPanelTitle: controlPanelTitle,
      showAudioPageHeader: showAudioPageHeader,
      showAudioTileHeader: showAudioTileHeader,
      albumFlex: albumFlex,
      titleFlex: titleFlex,
      artistFlex: artistFlex,
      titleLabel: titleLabel,
      artistLabel: artistLabel,
      albumLabel: albumLabel,
      showTrack: showTrack,
      showAlbum: showAlbum,
      showArtist: showArtist,
    );

    return YaruDetailPage(
      key: ValueKey(pageId),
      appBar: HeaderBar(
        style: showWindowControls
            ? YaruTitleBarStyle.normal
            : YaruTitleBarStyle.undecorated,
        title: isMobile ? null : (title ?? Text(headerTitle ?? pageId)),
        leading: Navigator.canPop(context)
            ? const NavBackButton()
            : const SizedBox.shrink(),
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

  String localize(AppLocalizations l10n) {
    switch (this) {
      case AudioPageType.immutable:
        return 'immutable';
      case AudioPageType.artist:
        return l10n.artists;
      case AudioPageType.likedAudio:
        return l10n.likedSongs;
      case AudioPageType.podcast:
        return l10n.podcasts;
      case AudioPageType.playlist:
        return l10n.playlists;
      case AudioPageType.album:
        return l10n.albums;
      case AudioPageType.radio:
        return l10n.radio;
    }
  }
}

final mainPageType = AudioPageType.values.where(
  (e) => !<AudioPageType>[
    AudioPageType.immutable,
    AudioPageType.likedAudio,
    AudioPageType.artist,
  ].contains(e),
);
