import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../../common.dart';
import '../../../constants.dart';
import '../../../data.dart';
import '../../../get.dart';
import '../../../local_audio.dart';
import '../../../player.dart';
import '../../../settings.dart';
import '../../common/explore_online_popup.dart';
import '../../l10n/l10n.dart';
import 'genre_page.dart';

class ArtistPage extends StatelessWidget with WatchItMixin {
  const ArtistPage({
    super.key,
    required this.images,
    required this.artistAudios,
  });

  final Set<Uint8List>? images;
  final Set<Audio>? artistAudios;

  @override
  Widget build(BuildContext context) {
    final model = getIt<LocalAudioModel>();

    final useGridView =
        watchPropertyValue((SettingsModel m) => m.useArtistGridView);
    final setUseGridView = getIt<SettingsModel>().setUseArtistGridView;

    final controlPanelButton = _ArtistPageControlButton(
      useGridView: useGridView,
      setUseGridView: setUseGridView,
      artist: artistAudios?.firstOrNull?.artist,
    );

    void onAlbumTap(text) {
      final audios = model.findAlbum(Audio(album: text));
      if (audios?.firstOrNull == null) return;
      final id = audios!.first.albumId;
      if (id == null) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) {
            return AlbumPage(
              id: id,
              album: audios,
            );
          },
        ),
      );
    }

    void onSubTitleTab(text) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return GenrePage(genre: text);
          },
        ),
      );
    }

    final roundImageContainer = RoundImageContainer(
      images: images,
      fallBackText: artistAudios?.firstOrNull?.artist ?? 'a',
    );

    if (!useGridView) {
      return AudioPage(
        classicTiles: false,
        showArtist: false,
        onAlbumTap: onAlbumTap,
        onSubTitleTab: onSubTitleTab,
        audioPageType: AudioPageType.artist,
        headerLabel: context.l10n.artist,
        headerTitle: artistAudios?.firstOrNull?.artist,
        image: roundImageContainer,
        imageRadius: BorderRadius.circular(10000),
        headerSubtile: artistAudios?.firstOrNull?.genre,
        audios: artistAudios,
        pageId: artistAudios?.firstOrNull?.artist ?? artistAudios.toString(),
        controlPanelButton: controlPanelButton,
      );
    }

    return _ArtistAlbumsCardGrid(
      onLabelTab: onAlbumTap,
      onSubTitleTab: onSubTitleTab,
      image: roundImageContainer,
      artistAudios: artistAudios,
      controlPanelButton: controlPanelButton,
    );
  }
}

class _ArtistPageControlButton extends StatelessWidget {
  const _ArtistPageControlButton({
    required this.useGridView,
    required this.setUseGridView,
    required this.artist,
  });

  final bool useGridView;
  final void Function(bool) setUseGridView;
  final String? artist;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Iconz().list),
          isSelected: !useGridView,
          onPressed: () => setUseGridView(false),
        ),
        IconButton(
          icon: Icon(Iconz().grid),
          isSelected: useGridView,
          onPressed: () => setUseGridView(true),
        ),
        if (artist != null) ExploreOnlinePopup(text: artist!),
      ],
    );
  }
}

class _ArtistAlbumsCardGrid extends StatelessWidget {
  const _ArtistAlbumsCardGrid({
    required this.onLabelTab,
    required this.controlPanelButton,
    required this.image,
    required this.artistAudios,
    this.onSubTitleTab,
  });

  final void Function(String)? onLabelTab;
  final void Function(String text)? onSubTitleTab;

  final Widget controlPanelButton;

  final Widget? image;
  final Set<Audio>? artistAudios;

  @override
  Widget build(BuildContext context) {
    final artist = artistAudios?.firstOrNull?.artist;
    final model = getIt<LocalAudioModel>();
    final playerModel = getIt<PlayerModel>();

    return YaruDetailPage(
      appBar: HeaderBar(
        adaptive: true,
        title: isMobile ? null : Text(artist ?? ''),
        leading: Navigator.canPop(context)
            ? const NavBackButton()
            : const SizedBox.shrink(),
      ),
      body: AdaptiveContainer(
        child: artist == null || artistAudios == null
            ? const SizedBox.shrink()
            : Column(
                children: [
                  AudioPageHeader(
                    imageRadius: BorderRadius.circular(10000),
                    title: artistAudios?.firstOrNull?.artist ?? '',
                    image: image,
                    subTitle: artistAudios?.firstOrNull?.genre,
                    label: context.l10n.artist,
                    onLabelTab: onLabelTab,
                    onSubTitleTab: onSubTitleTab,
                  ),
                  Padding(
                    padding: kAudioControlPanelPadding,
                    child: AudioPageControlPanel(
                      controlButton: controlPanelButton,
                      audios: artistAudios!,
                      onTap: () => playerModel.startPlaylist(
                        audios: artistAudios!,
                        listName: artist,
                      ),
                    ),
                  ),
                  Expanded(
                    child: AlbumsView(
                      albums: model.findAllAlbums(newAudios: artistAudios),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
