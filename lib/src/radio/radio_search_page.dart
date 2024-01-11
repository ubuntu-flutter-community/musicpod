import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_browser_api/radio_browser_api.dart' hide State;

import '../../common.dart';
import '../../data.dart';
import '../../globals.dart';
import '../../library.dart';
import '../../player.dart';
import 'radio_model.dart';
import 'radio_search.dart';
import 'station_card.dart';

class RadioSearchPage extends StatefulWidget {
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
  State<RadioSearchPage> createState() => _RadioSearchPageState();
}

class _RadioSearchPageState extends State<RadioSearchPage> {
  late Future<Set<Audio>?> _future;
  @override
  void initState() {
    super.initState();
    final radioModel = context.read<RadioModel>();

    _future = radioModel.getStations(
      tag: widget.radioSearch == RadioSearch.tag
          ? Tag(name: widget.searchQuery ?? 'radio', stationCount: 1)
          : null,
      limit: widget.limit,
      country:
          widget.radioSearch == RadioSearch.country ? widget.searchQuery : null,
      name: widget.radioSearch == RadioSearch.name ? widget.searchQuery : null,
      state:
          widget.radioSearch == RadioSearch.state ? widget.searchQuery : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final libraryModel = context.read<LibraryModel>();
    final playerModel = context.read<PlayerModel>();

    final futureBuilder = FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoadingGrid(limit: widget.limit);
        }
        if (snapshot.data?.isEmpty == true) {
          return const NoSearchResultPage();
        } else {
          return GridView.builder(
            padding: gridPadding,
            gridDelegate: imageGridDelegate,
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.searchQuery ?? '',
            ),
            const SizedBox(
              width: 5,
            ),
            IconButton(
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
