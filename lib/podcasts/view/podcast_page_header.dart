import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:watch_it/watch_it.dart';
import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/page_ids.dart';
import '../../common/view/audio_page_header.dart';
import '../../common/view/audio_page_header_html_description.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../search/search_model.dart';
import '../../settings/settings_model.dart';
import '../podcast_model.dart';
import 'podcast_page_image.dart';

class PodcastPageHeader extends StatelessWidget {
  const PodcastPageHeader({
    super.key,
    required this.title,
    required this.episodes,
    this.imageUrl,
  });

  final String title;
  final String? imageUrl;
  final List<Audio>? episodes;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AudioPageHeader(
      image: PodcastPageImage(imageUrl: imageUrl),
      label: (episodes ?? []).firstWhereOrNull((e) => e.genre != null)?.genre ??
          l10n.podcast,
      subTitle: episodes?.firstOrNull?.artist,
      description: episodes?.firstOrNull?.albumArtist == null
          ? null
          : AudioPageHeaderHtmlDescription(
              description: episodes!.firstOrNull!.albumArtist!,
              title: title,
            ),
      title: HtmlParser(title).parseFragment().text ?? title,
      onLabelTab: (text) => _onGenreTap(
        l10n: l10n,
        text: text,
      ),
      onSubTitleTab: (text) => _onArtistTap(
        l10n: l10n,
        text: text,
      ),
    );
  }

  Future<void> _onArtistTap({
    required AppLocalizations l10n,
    required String text,
  }) async {
    await di<PodcastModel>().init(updateMessage: l10n.updateAvailable);
    di<LibraryModel>().push(pageId: PageIDs.searchPage);
    di<SearchModel>()
      ..setAudioType(AudioType.podcast)
      ..setSearchQuery(text)
      ..search();
  }

  Future<void> _onGenreTap({
    required AppLocalizations l10n,
    required String text,
  }) async {
    await di<PodcastModel>().init(updateMessage: l10n.updateAvailable);
    final genres =
        di<SearchModel>().getPodcastGenres(di<SettingsModel>().usePodcastIndex);

    final genreOrNull = genres.firstWhereOrNull(
      (e) =>
          e.localize(l10n).toLowerCase() == text.toLowerCase() ||
          e.id.toLowerCase() == text.toLowerCase() ||
          e.name.toLowerCase() == text.toLowerCase(),
    );
    di<LibraryModel>().push(pageId: PageIDs.searchPage);
    if (genreOrNull != null) {
      di<SearchModel>()
        ..setAudioType(AudioType.podcast)
        ..setPodcastGenre(genreOrNull)
        ..search();
    } else {
      _onArtistTap(l10n: l10n, text: text);
    }
  }
}
