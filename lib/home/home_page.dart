import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../app/view/routing_manager.dart';
import '../common/data/audio_type.dart';
import '../common/page_ids.dart';
import '../common/view/adaptive_container.dart';
import '../common/view/header_bar.dart';
import '../common/view/icons.dart';
import '../common/view/search_button.dart';
import '../common/view/theme.dart';
import '../common/view/ui_constants.dart';
import '../extensions/country_x.dart';
import '../l10n/l10n.dart';
import '../library/library_model.dart';
import '../local_audio/local_audio_model.dart';
import '../local_audio/local_audio_view.dart';
import '../local_audio/view/playlists_view.dart';
import '../search/search_model.dart';
import '../search/search_type.dart';
import '../search/view/sliver_podcast_search_results.dart';
import '../search/view/sliver_radio_country_grid.dart';

class HomePage extends StatelessWidget with WatchItMixin {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final playlists = watchPropertyValue((LibraryModel m) => m.playlistIDs);
    const textPadding = EdgeInsets.only(
      right: kMediumSpace,
      left: kSmallestSpace,
    );

    final country =
        watchPropertyValue((SearchModel m) => m.country?.localize(l10n));

    return Scaffold(
      appBar: HeaderBar(
        title: Text(l10n.home),
        adaptive: false,
        actions: [
          const SearchButton(),
          IconButton(
            selectedIcon: Icon(Iconz.settingsFilled),
            icon: Icon(Iconz.settings),
            tooltip: l10n.settings,
            onPressed: () =>
                di<RoutingManager>().push(pageId: PageIDs.settings),
          ),
          const SizedBox(
            width: kSmallestSpace,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final padding = getAdaptiveHorizontalPadding(
            constraints: constraints,
          );
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: padding,
                sliver: SliverToBoxAdapter(
                  child: ListTile(
                    contentPadding: textPadding,
                    title: Text(
                      '${l10n.podcast} ${l10n.charts} ${country ?? ''}',
                      // style: style,
                    ),
                    trailing: Icon(Iconz.goNext),
                    onTap: () {
                      di<RoutingManager>().push(pageId: PageIDs.searchPage);
                      di<SearchModel>()
                        ..setAudioType(AudioType.podcast)
                        ..setSearchType(SearchType.podcastTitle)
                        ..search();
                    },
                  ),
                ),
              ),
              SliverPadding(
                padding: padding,
                sliver: const SliverPodcastSearchCountryChartsResults(
                  expand: false,
                  take: 3,
                ),
              ),
              SliverPadding(
                padding: padding,
                sliver: SliverToBoxAdapter(
                  child: ListTile(
                    contentPadding: textPadding,
                    title: Text(
                      '${l10n.radio} ${l10n.charts} ${country ?? ''}',
                    ),
                    onTap: () {
                      di<RoutingManager>().push(pageId: PageIDs.searchPage);
                      di<SearchModel>()
                        ..setAudioType(AudioType.radio)
                        ..setSearchType(SearchType.radioCountry)
                        ..search();
                    },
                    trailing: Icon(Iconz.goNext),
                  ),
                ),
              ),
              SliverPadding(
                padding: padding,
                sliver: const SliverRadioCountryGrid(),
              ),
              SliverPadding(
                padding: padding,
                sliver: SliverToBoxAdapter(
                  child: ListTile(
                    contentPadding: textPadding,
                    title: Text(l10n.playlists),
                    trailing: Icon(Iconz.goNext),
                    onTap: () {
                      di<LocalAudioModel>()
                          .setLocalAudioindex(LocalAudioView.playlists.index);
                      di<RoutingManager>().push(pageId: PageIDs.localAudio);
                    },
                  ),
                ),
              ),
              SliverPadding(
                padding: padding.copyWith(
                  bottom: bottomPlayerPageGap,
                ),
                sliver: PlaylistsView(playlists: playlists),
              ),
            ],
          );
        },
      ),
    );
  }
}
