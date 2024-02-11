import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../library.dart';
import '../../utils.dart';
import 'album_page.dart';
import 'artist_page.dart';
import 'local_audio_service.dart';

class TitlesView extends StatefulWidget {
  const TitlesView({
    super.key,
    required this.audios,
    this.noResultMessage,
    this.noResultIcon,
  });

  final Set<Audio>? audios;
  final Widget? noResultMessage, noResultIcon;

  @override
  State<TitlesView> createState() => _TitlesViewState();
}

class _TitlesViewState extends State<TitlesView> {
  List<Audio>? _titles;

  void _initTitles() {
    _titles = widget.audios?.toList();
    if (_titles == null) return;
    sortListByAudioFilter(
      audioFilter: AudioFilter.album,
      audios: _titles!,
    );
  }

  @override
  void initState() {
    super.initState();
    _initTitles();
  }

  @override
  void didUpdateWidget(covariant TitlesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initTitles();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.audios == null) {
      return const Center(
        child: Progress(),
      );
    }

    final localAudioService = getService<LocalAudioService>();
    final libraryModel = context.read<LibraryModel>();

    return AudioPageBody(
      padding: const EdgeInsets.only(top: 10),
      showTrack: false,
      showControlPanel: false,
      noResultIcon: widget.noResultIcon,
      noResultMessage: widget.noResultMessage,
      audios: _titles == null ? null : Set.from(_titles!),
      audioPageType: AudioPageType.immutable,
      pageId: kLocalAudioPageId,
      showAudioPageHeader: false,
      onAlbumTap: ({required audioType, required text}) {
        final albumAudios = localAudioService.findAlbum(Audio(album: text));
        if (albumAudios?.firstOrNull == null) return;
        final id = generateAlbumId(albumAudios!.first);
        if (id == null) return;

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) {
              return AlbumPage(
                isPinnedAlbum: libraryModel.isPinnedAlbum,
                removePinnedAlbum: libraryModel.removePinnedAlbum,
                addPinnedAlbum: libraryModel.addPinnedAlbum,
                id: id,
                album: albumAudios,
              );
            },
          ),
        );
      },
      onArtistTap: ({required audioType, required text}) {
        final artistAudios = localAudioService.findArtist(Audio(artist: text));
        final images = localAudioService.findImages(artistAudios ?? {});

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) {
              return ArtistPage(
                images: images,
                artistAudios: artistAudios,
              );
            },
          ),
        );
      },
    );
  }
}
