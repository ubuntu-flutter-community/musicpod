import 'package:animated_emoji/animated_emoji.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../common/data/audio.dart';
import '../common/view/adaptive_container.dart';
import '../common/view/audio_card.dart';
import '../common/view/audio_card_bottom.dart';
import '../common/view/audio_page_type.dart';
import '../common/view/common_widgets.dart';
import '../common/view/no_search_result_page.dart';
import '../common/view/safe_network_image.dart';
import '../common/view/sliver_audio_tile_list.dart';
import '../constants.dart';
import '../extensions/build_context_x.dart';
import '../l10n/l10n.dart';
import '../player/player_model.dart';
import '../podcasts/podcast_service.dart';
import '../podcasts/podcast_utils.dart';
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
    final audioType = watchPropertyValue((SearchModel m) => m.audioType);

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
                    if (audioType != AudioType.podcast)
                      SliverPadding(
                        padding: getAdaptiveHorizontalPadding(constraints),
                        sliver: SliverSearchResults(
                          key: ValueKey(searchResult?.length),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: getAdaptiveHorizontalPadding(constraints),
                        sliver: const SliverPodcastSearchResults(),
                      )
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

    final searchTypes = watchPropertyValue((SearchModel m) => m.searchTypes);

    return Material(
      color: context.t.scaffoldBackgroundColor,
      child: YaruChoiceChipBar(
        yaruChoiceChipBarStyle: YaruChoiceChipBarStyle.wrap,

        clearOnSelect: false,
        selectedFirst: false,
        onSelected: (i) {
          searchModel.searchType = searchTypes.elementAt(i);
          searchModel.search();
        },
        // TODO: if offline disable podcast and radio labels
        labels: searchTypes.map((e) => Text(e.localize(context.l10n))).toList(),
        isSelected: searchTypes.none((e) => e == searchType)
            ? List.generate(
                searchTypes.length,
                (index) => index == 0 ? true : false,
              )
            : searchTypes.map((e) => e == searchType).toList(),
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
      onSelected: (v) => searchModel.audioType = v,
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

class SliverPodcastSearchResults extends StatelessWidget with WatchItMixin {
  const SliverPodcastSearchResults({super.key});

  @override
  Widget build(BuildContext context) {
    final searchResult =
        watchPropertyValue((SearchModel m) => m.podcastSearchResult);

    watchPropertyValue((SearchModel m) => m.audioType);

    if (searchResult == null || searchResult.items.isEmpty) {
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

    return SliverGrid.builder(
      itemCount: searchResult.resultCount,
      gridDelegate: audioCardGridDelegate,
      itemBuilder: (context, index) {
        final podcastItem = searchResult.items.elementAt(index);

        final art = podcastItem.artworkUrl600 ?? podcastItem.artworkUrl;
        final image = SafeNetworkImage(
          url: art,
          fit: BoxFit.cover,
          height: kAudioCardDimension,
          width: kAudioCardDimension,
        );

        return AudioCard(
          bottom: AudioCardBottom(
            text: podcastItem.collectionName ?? podcastItem.trackName,
          ),
          image: image,
          onPlay: () => searchAndPushPodcastPage(
            context: context,
            feedUrl: podcastItem.feedUrl,
            itemImageUrl: art,
            genre: podcastItem.primaryGenreName,
            play: true,
          ),
          onTap: () => searchAndPushPodcastPage(
            context: context,
            feedUrl: podcastItem.feedUrl,
            itemImageUrl: art,
            genre: podcastItem.primaryGenreName,
            play: false,
          ),
        );
      },
    );
  }
}

class SliverSearchResults extends StatelessWidget with WatchItMixin {
  const SliverSearchResults({super.key});

  @override
  Widget build(BuildContext context) {
    final searchResult = watchPropertyValue((SearchModel m) => m.searchResult);
    watchPropertyValue((SearchModel m) => m.audioType);
    watchPropertyValue((SearchModel m) => m.searchQuery);

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
    _setSearchTypes(audioType);
  }

  Set<SearchType> _searchTypes = {};
  Set<SearchType> get searchTypes => _searchTypes;
  void _setSearchTypes(AudioType audioType) {
    _searchTypes =
        SearchType.values.where((e) => e.name.contains(audioType.name)).toSet();
    setSearchQuery(null);
    notifyListeners();
    search();
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

  SearchResult? _podcastSearchResult;
  SearchResult? get podcastSearchResult => _podcastSearchResult;
  void setPodcastSearchResult(SearchResult? value) {
    _podcastSearchResult = value;
    notifyListeners();
  }

  List<Audio>? _searchResult;
  List<Audio>? get searchResult => _searchResult;
  void setSearchResult(List<Audio>? value) {
    _searchResult = value;
    notifyListeners();
  }

  void setSearchQuery(String? value) {
    if (value == null || value == _searchQuery) return;
    _searchQuery = value;
    notifyListeners();
  }

  Future<void> search() async {
    setSearchResult(null);
    switch (_searchType) {
      case SearchType.radioName:
        await di<RadioService>().getStations(name: _searchQuery).then(
              (v) =>
                  setSearchResult(v?.map((e) => Audio.fromStation(e)).toList()),
            );
      case SearchType.podcastTitle:
        await di<PodcastService>()
            .search(searchQuery: _searchQuery)
            .then((v) => setPodcastSearchResult(v));
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
