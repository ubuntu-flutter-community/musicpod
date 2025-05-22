import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/view/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/page_ids.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/search_button.dart';
import '../../common/view/theme.dart';
import '../../l10n/l10n.dart';
import '../../search/search_model.dart';
import '../../search/search_type.dart';
import '../podcast_model.dart';
import 'podcasts_collection_body.dart';

class PodcastsPage extends StatefulWidget {
  const PodcastsPage({super.key});

  @override
  State<PodcastsPage> createState() => _PodcastsPageState();
}

class _PodcastsPageState extends State<PodcastsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      di<PodcastModel>().init(updateMessage: context.l10n.newEpisodeAvailable);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderBar(
        titleSpacing: 0,
        adaptive: true,
        actions: [
          Padding(
            padding: appBarSingleActionSpacing,
            child: SearchButton(
              onPressed: () {
                final searchModel = di<SearchModel>();
                di<RoutingManager>().push(pageId: PageIDs.searchPage);
                if (searchModel.audioType != AudioType.podcast) {
                  searchModel
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
}
