import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/search_button.dart';
import '../../common/view/theme.dart';
import '../../dependencies.dart';
import '../../extensions/build_context_x.dart';
import '../../search/data/search_type.dart';
import '../../search/manager/search_manager.dart';
import 'podcasts_collection_body.dart';

class PodcastsPage extends ConsumerWidget {
  const PodcastsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: HeaderBar(
      titleSpacing: 0,
      actions: [
        Padding(
          padding: appBarSingleActionSpacing,
          child: SearchButton(
            onPressed: () {
              final searchManager = di<SearchManager>();
              ref
                  .read(routingManagerProvider.notifier)
                  .push(pageId: PageIDs.searchPage);
              if (searchManager.audioType != AudioType.podcast) {
                searchManager
                  ..setAudioType(AudioType.podcast)
                  ..setSearchType(SearchType.podcastTitle)
                  ..search();
              }
            },
          ),
        ),
      ],
      title: Text('${context.l10n.podcasts} ${context.l10n.collection}'),
    ),
    body: const PodcastsCollectionBody(),
  );
}
