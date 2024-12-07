import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio_type.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/icons.dart';
import '../../common/view/search_button.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/country_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../local_audio/view/playlists_view.dart';
import '../../search/search_model.dart';
import '../../search/search_type.dart';
import '../../search/view/sliver_podcast_search_results.dart';
import '../../search/view/sliver_radio_country_grid.dart';

class HomePage extends StatelessWidget with WatchItMixin {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final l10n = context.l10n;
    final playlists = watchPropertyValue(
      (LibraryModel m) => m.playlists.keys.toList(),
    );
    final style = textTheme.headlineSmall;
    const textPadding = EdgeInsets.only(
      left: kSmallestSpace,
      bottom: kSmallestSpace,
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
            onPressed: () => di<LibraryModel>().push(pageId: kSettingsPageId),
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
                  child: Padding(
                    padding: textPadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${l10n.podcast} ${l10n.charts} ${country ?? ''}',
                          style: style,
                        ),
                        IconButton(
                          onPressed: () {
                            di<LibraryModel>().push(pageId: kSearchPageId);
                            di<SearchModel>()
                              ..setAudioType(AudioType.podcast)
                              ..setSearchType(SearchType.podcastTitle)
                              ..search();
                          },
                          icon: Icon(Iconz.goNext),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: padding,
                sliver: const SliverPodcastSearchResults(
                  take: 3,
                ),
              ),
              SliverPadding(
                padding: padding,
                sliver: SliverToBoxAdapter(
                  child: Padding(
                    padding: textPadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${l10n.radio} ${l10n.charts} ${country ?? ''}',
                          style: style,
                        ),
                        IconButton(
                          onPressed: () {
                            di<LibraryModel>().push(pageId: kSearchPageId);
                            di<SearchModel>()
                              ..setAudioType(AudioType.radio)
                              ..setSearchType(SearchType.radioCountry)
                              ..search();
                          },
                          icon: Icon(Iconz.goNext),
                        ),
                      ],
                    ),
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
                  child: Padding(
                    padding: textPadding,
                    child: Text(
                      '${l10n.playlists} ',
                      style: style,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: padding.copyWith(
                  bottom: bottomPlayerPageGap,
                ),
                sliver: PlaylistsView(
                  playlists: playlists,
                  take: 2,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
