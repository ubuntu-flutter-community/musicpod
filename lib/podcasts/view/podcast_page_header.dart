import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/audio_page_header.dart';
import '../../common/view/audio_page_header_html_description.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/string_x.dart';
import '../../l10n/app_localizations.dart';
import '../../search/manager/search_manager.dart';
import '../manager/podcast_genre_manager.dart';
import '../manager/podcast_load_genres_manager.dart';
import '../manager/podcast_short_info_manager.dart';
import 'podcast_page_image.dart';

class PodcastPageHeader extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    final shortInfo =
        ref.watch(podcastShortInfoManagerProvider(feedUrl)).value;
    final genre = ref.watch(podcastGenreManagerProvider(feedUrl)).value;

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
      onLabelTab: (text) => _onGenreTap(l10n: l10n, text: text, ref: ref),
      onSubTitleTab: (text) => _onArtistTap(l10n: l10n, text: text, ref: ref),
    );
  }

  void _onArtistTap({
    required AppLocalizations l10n,
    required String text,
    required WidgetRef ref,
  }) {
    ref.read(routingManagerProvider.notifier).push(pageId: PageIDs.searchPage);
    ref.read(searchManagerProvider.notifier)
      ..setAudioType(AudioType.podcast)
      ..setSearchQuery(text)
      ..search();
  }

  Future<void> _onGenreTap({
    required AppLocalizations l10n,
    required String text,
    required WidgetRef ref,
  }) async {
    final genres = await ref.read(podcastLoadGenresManagerProvider.future);

    final genreOrNull = genres.firstWhereOrNull(
      (e) =>
          e.localize(l10n).toLowerCase() == text.toLowerCase() ||
          e.id.toLowerCase() == text.toLowerCase() ||
          e.name.toLowerCase() == text.toLowerCase(),
    );

    if (genreOrNull != null) {
      ref.read(searchManagerProvider.notifier)
        ..setAudioType(AudioType.podcast)
        ..setPodcastGenre(genreOrNull)
        ..search();
    } else {
      _onArtistTap(l10n: l10n, text: text, ref: ref);
    }

    await Future.delayed(const Duration(milliseconds: 100));

    await ref
        .read(routingManagerProvider.notifier)
        .push(pageId: PageIDs.searchPage);
  }
}
