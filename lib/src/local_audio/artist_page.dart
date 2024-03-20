import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

import '../../app.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../library.dart';
import '../../local_audio.dart';
import '../../player.dart';
import '../../settings.dart';
import '../../utils.dart';
import '../common/unknown_page.dart';
import '../l10n/l10n.dart';
import 'genre_page.dart';

class ArtistPage extends ConsumerWidget {
  const ArtistPage({
    super.key,
    required this.images,
    required this.artistAudios,
  });

  final Set<Uint8List>? images;
  final Set<Audio>? artistAudios;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageId =
        artistAudios?.firstWhereOrNull((e) => e.artist != null)?.artist;
    if (pageId == null) {
      return const UnknownPage();
    }

    final libraryModel = ref.read(libraryModelProvider);
    final model = ref.read(localAudioModelProvider);

    final useGridView = ref.watch(
      settingsModelProvider.select((v) => v.useArtistGridView),
    );
    final setUseGridView = ref.read(settingsModelProvider).setUseArtistGridView;

    var listModeToggle = Row(
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
      ],
    );

    final controlPanelButton = Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: StreamProviderRow(
            text:
                artistAudios?.firstWhereOrNull((e) => e.artist != null)?.artist,
          ),
        ),
        listModeToggle,
      ],
    );

    void onAlbumTap(text) {
      final audios = model.findAlbum(Audio(album: text));
      if (audios == null ||
          audios.none((a) => a.artist != null && a.album != null) == true) {
        return;
      }
      final id = generateAlbumId(
        audios.firstWhere((e) => e.artist != null && e.album != null),
      );
      if (id == null) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) {
            return AlbumPage(
              isPinnedAlbum: libraryModel.isPinnedAlbum,
              removePinnedAlbum: libraryModel.removePinnedAlbum,
              addPinnedAlbum: libraryModel.addPinnedAlbum,
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
      fallBackText:
          artistAudios?.firstWhereOrNull((e) => e.artist != null)?.artist,
    );

    if (!useGridView) {
      return AudioPage(
        classicTiles: false,
        showArtist: false,
        onAlbumTap: onAlbumTap,
        onSubTitleTab: onSubTitleTab,
        audioPageType: AudioPageType.artist,
        headerLabel: context.l10n.artist,
        headerTitle:
            artistAudios?.firstWhereOrNull((e) => e.artist != null)?.artist,
        image: roundImageContainer,
        imageRadius: BorderRadius.circular(10000),
        headerSubtile:
            artistAudios?.firstWhereOrNull((e) => e.genre != null)?.genre,
        audios: artistAudios,
        pageId: pageId,
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
    return Consumer(
      builder: (context, ref, _) {
        final showWindowControls =
            ref.watch(appModelProvider.select((a) => a.showWindowControls));

        final artist =
            artistAudios?.firstWhereOrNull((e) => e.artist != null)?.artist;
        final model = ref.read(localAudioModelProvider);
        final playerModel = ref.read(playerModelProvider);

        return YaruDetailPage(
          appBar: HeaderBar(
            style: showWindowControls
                ? YaruTitleBarStyle.normal
                : YaruTitleBarStyle.undecorated,
            title: isMobile ? null : Text(artist ?? ''),
            leading: Navigator.canPop(context)
                ? const NavBackButton()
                : const SizedBox.shrink(),
          ),
          body: artist == null || artistAudios == null
              ? const SizedBox.shrink()
              : Column(
                  children: [
                    AudioPageHeader(
                      imageRadius: BorderRadius.circular(10000),
                      title: artist,
                      image: image,
                      subTitle: artistAudios
                          ?.firstWhereOrNull((e) => e.genre != null)
                          ?.genre,
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
        );
      },
    );
  }
}
