import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../app.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../globals.dart';
import '../../library.dart';
import '../../local_audio.dart';
import '../../player.dart';
import '../../settings.dart';
import '../../utils.dart';
import '../l10n/l10n.dart';

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
        listModeToggle,
        StreamProviderRow(
          spacing: const EdgeInsets.only(right: 10),
          text: artistAudios?.firstOrNull?.artist,
        ),
      ],
    );

    void onAlbumTap(text) {
      final audios = model.findAlbum(Audio(album: text));
      if (audios?.firstOrNull == null) return;
      final id = generateAlbumId(audios!.first);
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

    if (!useGridView) {
      return AudioPage(
        showArtist: false,
        onAlbumTap: onAlbumTap,
        audioPageType: AudioPageType.artist,
        headerLabel: context.l10n.artist,
        headerTitle: artistAudios?.firstOrNull?.artist,
        showAudioPageHeader: images?.isNotEmpty == true,
        image: ArtistImage(images: images),
        imageRadius: BorderRadius.circular(10000),
        headerSubtile: artistAudios?.firstOrNull?.genre,
        audios: artistAudios,
        pageId: artistAudios?.firstOrNull?.artist ?? artistAudios.toString(),
        controlPanelButton: controlPanelButton,
      );
    }

    return _ArtistAlbumsCardGrid(
      onLabelTab: onAlbumTap,
      images: images,
      artistAudios: artistAudios,
      controlPanelButton: controlPanelButton,
    );
  }
}

class _ArtistAlbumsCardGrid extends StatelessWidget {
  const _ArtistAlbumsCardGrid({
    required this.onLabelTab,
    required this.controlPanelButton,
    required this.images,
    required this.artistAudios,
  });

  final void Function(String)? onLabelTab;
  final Widget controlPanelButton;

  final Set<Uint8List>? images;
  final Set<Audio>? artistAudios;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final showWindowControls =
            ref.watch(appModelProvider.select((a) => a.showWindowControls));

        final artist = artistAudios?.firstOrNull?.artist;
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
                      height: kMaxAudioPageHeaderHeight,
                      imageRadius: BorderRadius.circular(10000),
                      title: artistAudios?.firstOrNull?.artist ?? '',
                      image: ArtistImage(images: images),
                      subTitle: artistAudios?.firstOrNull?.genre,
                      label: context.l10n.artist,
                      onLabelTab: onLabelTab,
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
                        pause: () {},
                        resume: () {},
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
