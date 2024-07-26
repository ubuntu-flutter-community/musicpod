import 'package:animated_emoji/animated_emoji.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../common/data/audio.dart';
import '../common/view/adaptive_container.dart';
import '../common/view/audio_page_type.dart';
import '../common/view/common_widgets.dart';
import '../common/view/no_search_result_page.dart';
import '../common/view/sliver_audio_tile_list.dart';
import '../constants.dart';
import '../extensions/build_context_x.dart';
import '../l10n/l10n.dart';
import '../player/player_model.dart';
import '../radio/radio_model.dart';
import '../radio/radio_service.dart';
import '../radio/view/radio_reconnect_button.dart';

class SearchPage extends StatefulWidget with WatchItStatefulWidgetMixin {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    super.initState();
    di<RadioModel>().init();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = watchPropertyValue((PlayerModel m) => m.isOnline);
    final connectedHost = watchPropertyValue(
      (RadioModel m) => m.connectedHost != null && isOnline,
    );
    final searchModel = di<SearchModel>();
    final searchQuery = watchPropertyValue((SearchModel m) => m.searchQuery);
    final searchResult = watchPropertyValue((SearchModel m) => m.searchResult);

    return Scaffold(
      appBar: HeaderBar(
        adaptive: true,
        title: SizedBox(
          width: kSearchBarWidth,
          child: SearchingBar(
            text: searchQuery,
            key: ValueKey(searchQuery ?? 'ya'),
            hintText: context.l10n.search,
            onSubmitted: (v) {
              if (v != null) {
                searchModel.setSearchQuery(v);
                searchModel.search();
              }
            },
            suffixIcon: const AudioTypFilterButton(),
          ),
        ),
        actions: [
          if (!connectedHost) const RadioReconnectButton(),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Padding(
                padding: getAdaptiveHorizontalPadding(constraints)
                    .copyWith(bottom: 20, top: 10),
                child: const SearchTypeFilterBar(),
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: getAdaptiveHorizontalPadding(constraints),
                      sliver: SliverSearchResults(
                        key: ValueKey(searchResult?.length),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SearchTypeFilterBar extends StatelessWidget with WatchItMixin {
  const SearchTypeFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final searchModel = di<SearchModel>();

    final searchType = watchPropertyValue((SearchModel m) => m.searchType);
    final audioType = watchPropertyValue((SearchModel m) => m.audioType);

    final filteredSearchTypes =
        SearchType.values.where((e) => e.name.contains(audioType.name));
    return Material(
      color: context.t.scaffoldBackgroundColor,
      child: YaruChoiceChipBar(
        yaruChoiceChipBarStyle: YaruChoiceChipBarStyle.wrap,

        clearOnSelect: false,
        selectedFirst: false,
        onSelected: (i) {
          searchModel.searchType = filteredSearchTypes.elementAt(i);
          searchModel.search();
        },
        // TODO: if offline disable podcast and radio labels
        labels: filteredSearchTypes
            .map((e) => Text(e.localize(context.l10n)))
            .toList(),
        isSelected: filteredSearchTypes.none((e) => e == searchType)
            ? List.generate(
                filteredSearchTypes.length,
                (index) => index == 0 ? true : false,
              )
            : filteredSearchTypes.map((e) => e == searchType).toList(),
      ),
    );
  }
}

class AudioTypFilterButton extends StatelessWidget with WatchItMixin {
  const AudioTypFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final searchModel = di<SearchModel>();

    // TODO: switch search type
    final audioType = watchPropertyValue((SearchModel m) => m.audioType);

    return PopupMenuButton<AudioType>(
      initialValue: audioType,
      onSelected: (v) {
        searchModel.audioType = v;
      },
      itemBuilder: (context) => AudioType.values
          .map(
            (e) => PopupMenuItem<AudioType>(
              value: e,
              child: Text(
                e.localize(
                  context.l10n,
                ),
              ),
            ),
          )
          .toList(),
      icon: Padding(
        padding: const EdgeInsets.only(right: 5),
        child: Text(
          audioType.localize(context.l10n),
          style: context.t.textTheme.labelSmall?.copyWith(
            color: context.t.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class SliverSearchResults extends StatelessWidget with WatchItMixin {
  const SliverSearchResults({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: switch grid/list depending on filter
    final searchResult = watchPropertyValue((SearchModel m) => m.searchResult);

    if (searchResult == null || searchResult.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: NoSearchResultPage(
          icons: searchResult == null
              ? const AnimatedEmoji(AnimatedEmojis.drum)
              : const AnimatedEmoji(AnimatedEmojis.eyes),
          message: Text(
            searchResult == null
                ? context.l10n.search
                : context.l10n.nothingFound,
          ),
        ),
      );
    }

    return SliverAudioTileList(
      audios: Set.from(searchResult),
      pageId: kSearchPageId,
      audioPageType: AudioPageType.allTitlesView,
    );
  }
}

class SearchModel extends SafeChangeNotifier {
  AudioType _audioType = AudioType.radio;
  AudioType get audioType => _audioType;
  set audioType(AudioType value) {
    if (value == _audioType) return;
    _audioType = value;
    notifyListeners();
  }

  SearchType _searchType = SearchType.radioName;
  SearchType get searchType => _searchType;
  set searchType(SearchType value) {
    if (value == _searchType) return;
    _searchType = value;
    notifyListeners();
  }

  String? _searchQuery;
  String? get searchQuery => _searchQuery;

  List<Audio>? _searchResult;
  List<Audio>? get searchResult => _searchResult;
  void setSearchQuery(String? value) {
    if (value == null || value == _searchQuery) return;
    _searchQuery = value;
    notifyListeners();
  }

  Future<void> search() async {
    _searchResult = null;
    notifyListeners();
    switch (_searchType) {
      case SearchType.radioName:
        di<RadioService>()
            .getStations(name: _searchQuery)
            .then(
              (v) =>
                  _searchResult = v?.map((e) => Audio.fromStation(e)).toList(),
            )
            .then((_) => notifyListeners());
      default:
    }
  }
}

enum SearchType {
  localTitle,
  localArtist,
  localAlbum,
  localGenreName,
  radioName,
  radioTag,
  radioCountry,
  radioLanguage,
  podcastTitle,
  podcastGenre,
  podcastCountry,
  podcastLanguage;

  String localize(AppLocalizations l10n) => switch (this) {
        localTitle => l10n.titles,
        localArtist => l10n.artists,
        localAlbum => l10n.albums,
        localGenreName => l10n.genres,
        radioName => l10n.name,
        radioTag => l10n.tag,
        podcastTitle => l10n.podcasts,
        podcastGenre => l10n.genres,
        radioCountry => l10n.country,
        radioLanguage => l10n.language,
        podcastCountry => l10n.country,
        podcastLanguage => l10n.language,
      };
}
