import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

import '../../app.dart';
import '../../common.dart';
import '../../data.dart';
import '../../globals.dart';
import '../../l10n.dart';
import '../../library.dart';
import '../../player.dart';
import 'radio_model.dart';
import 'radio_search.dart';
import 'station_card.dart';

class RadioSearchPage extends ConsumerStatefulWidget {
  const RadioSearchPage({
    super.key,
    this.limit = 100,
    this.searchQuery,
    this.includeHeader = true,
    required this.radioSearch,
  });

  final int limit;
  final String? searchQuery;

  final bool includeHeader;
  final RadioSearch radioSearch;

  @override
  ConsumerState<RadioSearchPage> createState() => _RadioSearchPageState();
}

class _RadioSearchPageState extends ConsumerState<RadioSearchPage> {
  late Future<Set<Audio>?> _future;
  @override
  void initState() {
    super.initState();
    final radioModel = ref.read(radioModelProvider);
    _future = radioModel.getStations(
      radioSearch: widget.radioSearch,
      query: widget.searchQuery,
    );
  }

  @override
  Widget build(BuildContext context) {
    final libraryModel = ref.read(libraryModelProvider);
    final playerModel = ref.read(playerModelProvider);
    final showWindowControls =
        ref.watch(appModelProvider.select((a) => a.showWindowControls));

    final futureBuilder = FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoadingGrid(limit: widget.limit);
        }
        if (snapshot.data?.isEmpty == true) {
          return NoSearchResultPage(
            icons: const AnimatedEmoji(AnimatedEmojis.dog),
            message: Text(context.l10n.noStationFound),
          );
        } else {
          return GridView.builder(
            padding: gridPadding,
            gridDelegate: audioCardGridDelegate,
            itemCount: snapshot.data?.length,
            itemBuilder: (context, index) {
              final station = snapshot.data?.elementAt(index);
              return StationCard(
                station: station,
                startPlaylist: playerModel.startPlaylist,
                isStarredStation: libraryModel.isStarredStation,
                unstarStation: libraryModel.unStarStation,
                starStation: libraryModel.addStarredStation,
              );
            },
          );
        }
      },
    );

    if (widget.includeHeader == false) {
      return futureBuilder;
    }

    final isFavTag = libraryModel.favTags.contains(widget.searchQuery);

    return Scaffold(
      appBar: HeaderBar(
        style: showWindowControls
            ? YaruTitleBarStyle.normal
            : YaruTitleBarStyle.undecorated,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: context.l10n.addToCollection,
              onPressed: widget.searchQuery == null
                  ? null
                  : () {
                      if (isFavTag) {
                        libraryModel.removeFavTag(widget.searchQuery!);
                      } else {
                        libraryModel.addFavTag(widget.searchQuery!);
                      }
                    },
              icon: Icon(
                isFavTag ? Iconz().starFilled : Iconz().star,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              widget.searchQuery ?? '',
            ),
          ],
        ),
        leading: navigatorKey.currentState?.canPop() == true
            ? const NavBackButton()
            : const SizedBox.shrink(),
      ),
      body: futureBuilder,
    );
  }
}
