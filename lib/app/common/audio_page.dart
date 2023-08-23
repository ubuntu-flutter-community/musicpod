import 'package:flutter/material.dart';
import 'package:musicpod/app/app_model.dart';
import 'package:musicpod/app/common/audio_page_body.dart';
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
    this.title,
    this.controlPanelButton,
    this.headerTitle,
    this.headerSubtile,
    this.headerLabel,
    this.headerDescription,
    this.image,
    this.showAudioPageHeader = true,
    this.onTextTap,
    this.noResultMessage,
    this.titleLabel,
    this.artistLabel,
    this.albumLabel,
    this.controlPanelTitle,
    this.titleFlex = 5,
    this.artistFlex = 5,
    this.albumFlex = 4,
    this.showTrack = true,
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
  final String? titleLabel, artistLabel, albumLabel;
  final int titleFlex, artistFlex, albumFlex;
  final bool showAudioPageHeader;
  final bool showAudioTileHeader;
  final bool showTrack;

  final void Function({
    required String text,
    required AudioType audioType,
  })? onTextTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final showWindowControls =
        context.select((AppModel a) => a.showWindowControls);

    final body = AudioPageBody(
      key: ValueKey(audios?.length),
      pageId: pageId,
      audios: audios,
      noResultMessage: noResultMessage,
      onTextTap: onTextTap,
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
    );

    return YaruDetailPage(
      key: ValueKey(pageId),
      appBar: YaruWindowTitleBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        border: BorderSide.none,
        style: showWindowControls
            ? YaruTitleBarStyle.normal
            : YaruTitleBarStyle.undecorated,
        title: title ?? Text(headerTitle ?? pageId),
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
