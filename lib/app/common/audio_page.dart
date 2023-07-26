import 'package:flutter/material.dart';
import 'package:musicpod/app/app_model.dart';
import 'package:musicpod/app/common/audio_filter.dart';
import 'package:musicpod/app/common/audio_page_body.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:provider/provider.dart';
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
    this.controlPageButton,
    this.sort = true,
    this.showTrack = true,
    this.pageLabel,
    this.pageDescription,
    this.pageTitle,
    this.pageSubtile,
    this.image,
    this.showAudioPageHeader = true,
    this.audioFilter = AudioFilter.trackNumber,
    this.onArtistTap,
    this.onAlbumTap,
    this.noResultMessage,
    this.titleLabel,
    this.artistLabel,
    this.albumLabel,
    this.pageTitleWidget,
    this.titleFlex = 5,
    this.artistFlex = 5,
    this.albumFlex = 4,
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
  final bool sort;
  final bool showTrack;

  final Widget? image;
  final bool? showAudioPageHeader;
  final AudioFilter audioFilter;
  final String? noResultMessage;
  final String? titleLabel, artistLabel, albumLabel;
  final int titleFlex, artistFlex, albumFlex;

  final void Function(String artist)? onArtistTap;
  final void Function(String album)? onAlbumTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final showWindowControls =
        context.select((AppModel a) => a.showWindowControls);

    final body = AudioPageBody(
      albumFlex: albumFlex,
      titleFlex: titleFlex,
      artistFlex: artistFlex,
      titleLabel: titleLabel,
      artistLabel: artistLabel,
      albumLabel: albumLabel,
      noResultMessage: noResultMessage,
      onAlbumTap: onAlbumTap,
      onArtistTap: onArtistTap,
      audios: audios,
      audioPageType: audioPageType,
      pageId: pageId,
      editableName: editableName,
      sort: sort,
      showTrack: showTrack,
      audioFilter: audioFilter,
      image: image,
      pageDescription: pageDescription,
      likePageButton: controlPageButton,
      pageLabel: pageLabel,
      pageSubTitle: pageSubtile,
      pageTitle: pageTitle,
      pageTitleWidget: pageTitleWidget,
      showAudioPageHeader: showAudioPageHeader,
    );

    return YaruDetailPage(
      key: ValueKey(pageId),
      backgroundColor: theme.brightness == Brightness.dark
          ? kBackgroundDark
          : kBackGroundLight,
      appBar: YaruWindowTitleBar(
        backgroundColor: Colors.transparent,
        style: showWindowControls
            ? YaruTitleBarStyle.normal
            : YaruTitleBarStyle.undecorated,
        title: title ?? Text(pageTitle ?? pageId),
        leading: Navigator.canPop(context)
            ? const YaruBackButton(
                style: YaruBackButtonStyle.rounded,
              )
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
