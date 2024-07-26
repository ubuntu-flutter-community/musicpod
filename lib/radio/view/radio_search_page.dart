import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/icons.dart';
import '../../common/view/loading_grid.dart';
import '../../common/view/no_search_result_page.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../radio_model.dart';
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
    final radioModel = di<RadioModel>();
    _future = radioModel.getStations(
      radioSearch: widget.radioSearch,
      query: widget.searchQuery,
    );
  }

  @override
  Widget build(BuildContext context) {
    final libraryModel = di<LibraryModel>();
    final playerModel = di<PlayerModel>();
    final radioModel = di<RadioModel>();

    final futureBuilder = FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoadingGrid(limit: widget.limit);
        } else {
          if (snapshot.data?.isEmpty == true) {
            return NoSearchResultPage(
              icons: AnimatedEmoji(
                widget.searchQuery?.isNotEmpty == true
                    ? AnimatedEmojis.dog
                    : AnimatedEmojis.drum,
              ),
              message: Text(
                widget.searchQuery?.isNotEmpty == true
                    ? context.l10n.noStationFound
                    : '',
              ),
            );
          } else {
            return LayoutBuilder(
              builder: (context, constraints) {
                return GridView.builder(
                  padding: getAdaptiveHorizontalPadding(constraints),
                  gridDelegate: audioCardGridDelegate,
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, index) {
                    final station = snapshot.data?.elementAt(index);
                    return StationCard(
                      station: station,
                      startPlaylist: ({
                        required audios,
                        index,
                        required listName,
                      }) {
                        return playerModel
                            .startPlaylist(
                              audios: audios,
                              listName: listName,
                            )
                            .then((_) => radioModel.clickStation(station));
                      },
                    );
                  },
                );
              },
            );
          }
        }
      },
    );

    if (widget.includeHeader == false) {
      return futureBuilder;
    }

    final isFavTag = libraryModel.favRadioTags.contains(widget.searchQuery);

    return Scaffold(
      appBar: HeaderBar(
        adaptive: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: context.l10n.addToCollection,
              onPressed: widget.searchQuery == null
                  ? null
                  : () {
                      if (isFavTag) {
                        libraryModel.removeRadioFavTag(widget.searchQuery!);
                      } else {
                        libraryModel.addFavRadioTag(widget.searchQuery!);
                      }
                    },
              icon: Icon(
                isFavTag ? Iconz().starFilled : Iconz().star,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Flexible(
              child: Text(
                widget.searchQuery ?? '',
              ),
            ),
          ],
        ),
      ),
      body: futureBuilder,
    );
  }
}
