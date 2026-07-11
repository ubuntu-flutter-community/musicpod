import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/audio_page_header.dart';
import '../../common/view/audio_page_header_html_description.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/command_x.dart';
import '../../extensions/string_x.dart';
import '../../l10n/app_localizations.dart';
import '../../search/manager/search_manager.dart';
import '../manager/podcast_genre_manager.dart';
import '../manager/podcast_short_info_manager.dart';
import 'podcast_page_image.dart';

class PodcastPageHeader extends StatelessWidget with WatchItMixin {
  const PodcastPageHeader({
    super.key,
    required this.feedUrl,
    this.title,
    this.showFallBackOrErrorIcon = true,
  });

  final String feedUrl;
  final String? title;
  final bool showFallBackOrErrorIcon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final genre = watchValue(
      (PodcastGenreManager m) => m.findCommand,
      param1: feedUrl,
    );

    final shortInfo = watchValue(
      (PodcastShortInfoManager m) => m.command,
      param1: feedUrl,
    );

    return AudioPageHeader(
      image: PodcastPageImage(
        imageUrl: shortInfo?.imageUrl,
        showFallBackOrErrorIcon: showFallBackOrErrorIcon,
      ),
      label: genre ?? l10n.podcast,
      subTitle: shortInfo?.artist,
      description: shortInfo?.description == null
          ? null
          : AudioPageHeaderHtmlDescription(
              description: shortInfo!.description!,
              title: shortInfo.name,
            ),
      title: title ?? shortInfo?.name.unEscapeHtml ?? '',
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
    final genres = await di<PodcastLoadGenresManager>().command
        .runRestrictedAsync();

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
