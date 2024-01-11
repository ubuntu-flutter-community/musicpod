import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../library.dart';
import '../../local_audio.dart';
import '../../utils.dart';
import '../l10n/l10n.dart';

class TitlesView extends StatefulWidget {
  const TitlesView({
    super.key,
    required this.audios,
  });

  final Set<Audio>? audios;

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

    final model = context.read<LocalAudioModel>();
    final libraryModel = context.read<LibraryModel>();

    return AudioPageBody(
      padding: const EdgeInsets.only(top: 10),
      showTrack: false,
      showControlPanel: false,
      noResultMessage: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.noLocalTitlesFound),
          const ShopRecommendations(),
        ],
      ),
      audios: _titles == null ? null : Set.from(_titles!),
      audioPageType: AudioPageType.immutable,
      pageId: kLocalAudioPageId,
      showAudioPageHeader: false,
      onAlbumTap: ({required audioType, required text}) {
        final albumAudios = model.findAlbum(Audio(album: text));
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
        final artistAudios = model.findArtist(Audio(artist: text));
        final images = model.findImages(artistAudios ?? {});

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
