import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/audio_page_header.dart';
import '../../common/view/audio_page_header_html_description.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/string_x.dart';
import '../../l10n/app_localizations.dart';
import '../../search/search_manager.dart';
import '../podcast_genre_manager.dart';
import 'podcast_page_image.dart';

class PodcastPageHeader extends StatelessWidget with WatchItMixin {
  const PodcastPageHeader({
    super.key,
    this.feedUrl,
    required this.title,
    required this.episodes,
    this.imageUrl,
    required this.showFallbackIcon,
  });

  final String? feedUrl;
  final String title;
  final String? imageUrl;
  final List<Audio>? episodes;
  final bool showFallbackIcon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final genre = feedUrl == null
        ? null
        : watch(
            di<PodcastGenreManager>(param1: feedUrl).findPodcastGenreCommand,
          ).value;

    return AudioPageHeader(
      image: PodcastPageImage(
        imageUrl: imageUrl,
        showFallbackIcon: showFallbackIcon,
      ),
      label: genre ?? l10n.podcast,
      subTitle: episodes?.firstOrNull?.copyright?.trim(),
      description: episodes?.firstOrNull?.podcastDescription == null
          ? null
          : AudioPageHeaderHtmlDescription(
              description: episodes!.firstOrNull!.podcastDescription!,
              title: title,
            ),
      title: title.unEscapeHtml ?? title,
      onLabelTab: (text) => _onGenreTap(l10n: l10n, text: text),
      onSubTitleTab: (text) => _onArtistTap(l10n: l10n, text: text),
    );
  }

  void _onArtistTap({required AppLocalizations l10n, required String text}) {
    di<RoutingManager>().push(pageId: PageIDs.searchPage);
    di<SearchManager>()
      ..setAudioType(AudioType.podcast)
      ..setSearchQuery(text)
      ..search();
  }

  Future<void> _onGenreTap({
    required AppLocalizations l10n,
    required String text,
  }) async {
    final genres = await di<SearchManager>().loadPodcastGenresCommand
        .runAsync();

    final genreOrNull = genres.firstWhereOrNull(
      (e) =>
          e.localize(l10n).toLowerCase() == text.toLowerCase() ||
          e.id.toLowerCase() == text.toLowerCase() ||
          e.name.toLowerCase() == text.toLowerCase(),
    );

    if (genreOrNull != null) {
      di<SearchManager>()
        ..setAudioType(AudioType.podcast)
        ..setPodcastGenre(genreOrNull)
        ..search();
    } else {
      _onArtistTap(l10n: l10n, text: text);
    }

    await Future.delayed(const Duration(milliseconds: 100));

    await di<RoutingManager>().push(pageId: PageIDs.searchPage);
  }
}
