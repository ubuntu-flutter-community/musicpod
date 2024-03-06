import 'dart:convert';

import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/yaru.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../globals.dart';
import '../../l10n.dart';
import '../../library.dart';
import '../../player.dart';
import '../../radio.dart';
import '../../theme.dart';
import '../data/mpv_meta_data.dart';
import 'open_radio_discover_page_button.dart';
import 'radio_search.dart';
import 'radio_search_page.dart';
import 'station_card.dart';

import 'package:http/http.dart' as http;

class RadioLibPage extends ConsumerWidget {
  const RadioLibPage({
    super.key,
    required this.isOnline,
  });

  final bool isOnline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isOnline) {
      return const OfflinePage();
    }

    final theme = context.t;
    final radioCollectionView =
        ref.watch(radioModelProvider.select((m) => m.radioCollectionView));
    final radioModel = ref.read(radioModelProvider);

    return Column(
      children: [
        Row(
          children: [
            const SizedBox(
              width: 25,
            ),
            YaruChoiceChipBar(
              chipBackgroundColor: chipColor(theme),
              selectedChipBackgroundColor: chipSelectionColor(theme, false),
              borderColor: chipBorder(theme, false),
              selectedFirst: false,
              clearOnSelect: false,
              onSelected: (index) => radioModel
                  .setRadioCollectionView(RadioCollectionView.values[index]),
              yaruChoiceChipBarStyle: YaruChoiceChipBarStyle.wrap,
              labels: [
                Text(context.l10n.station),
                Text(context.l10n.tags),
                Text(context.l10n.hearingHistory),
              ],
              isSelected: RadioCollectionView.values
                  .map((e) => e == radioCollectionView)
                  .toList(),
            ),
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        Expanded(
          child: switch (radioCollectionView) {
            RadioCollectionView.stations => const StationGrid(),
            RadioCollectionView.tags => const TagGrid(),
            RadioCollectionView.history => const RadioHistoryList(),
          },
        ),
      ],
    );
  }
}

class StationGrid extends ConsumerWidget {
  const StationGrid({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stations =
        ref.watch(libraryModelProvider.select((m) => m.starredStations));
    final length =
        ref.watch(libraryModelProvider.select((m) => m.starredStationsLength));
    final libraryModel = ref.read(libraryModelProvider);
    final playerModel = ref.read(playerModelProvider);

    if (length == 0) {
      return NoSearchResultPage(
        message: Column(
          children: [
            Text(context.l10n.noStarredStations),
            const SizedBox(
              height: kYaruPagePadding,
            ),
            const OpenRadioDiscoverPageButton(),
          ],
        ),
        icons: const AnimatedEmoji(AnimatedEmojis.glowingStar),
      );
    }

    return GridView.builder(
      padding: gridPadding,
      gridDelegate: audioCardGridDelegate,
      itemCount: length,
      itemBuilder: (context, index) {
        final station = stations.entries.elementAt(index).value.firstOrNull;
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
}

class TagGrid extends ConsumerWidget {
  const TagGrid({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favTagsLength =
        ref.watch(libraryModelProvider.select((m) => m.favTags.length));
    final favTags = ref.watch(libraryModelProvider.select((m) => m.favTags));

    if (favTagsLength == 0) {
      return NoSearchResultPage(
        message: Column(
          children: [
            Text(context.l10n.noStarredTags),
            const SizedBox(
              height: kYaruPagePadding,
            ),
            const OpenRadioDiscoverPageButton(),
          ],
        ),
        icons: const AnimatedEmoji(AnimatedEmojis.glowingStar),
      );
    }

    return GridView.builder(
      padding: gridPadding,
      gridDelegate: audioCardGridDelegate,
      itemCount: favTagsLength,
      itemBuilder: (context, index) {
        final tag = favTags.elementAt(index);
        return AudioCard(
          image: SideBarFallBackImage(
            color: getAlphabetColor(tag),
            width: double.infinity,
            height: double.infinity,
            child: Icon(
              getIconForTag(tag),
              size: 65,
            ),
          ),
          bottom: AudioCardBottom(text: tag),
          onTap: () {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) {
                  return RadioSearchPage(
                    searchQuery: tag,
                    radioSearch: RadioSearch.tag,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class RadioHistoryList extends ConsumerWidget {
  const RadioHistoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radioHistory =
        ref.watch(libraryModelProvider.select((l) => l.radioHistory));
    ref.watch(playerModelProvider.select((p) => p.mpvMetaData));

    if (radioHistory.isEmpty) {
      return NoSearchResultPage(
        icons: const AnimatedEmoji(AnimatedEmojis.crystalBall),
        message: Text(context.l10n.emptyHearingHistory),
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ListView.builder(
        reverse: true,
        shrinkWrap: true,
        padding: const EdgeInsets.only(
          left: 10,
          bottom: kYaruPagePadding,
        ),
        itemCount: radioHistory.length,
        itemBuilder: (context, index) {
          final e = radioHistory.entries.elementAt(index);
          return ListTile(
            leading: HistoryLead(e: e),
            title: Text(e.value.icyTitle),
            subtitle: TapAbleText(
              text: e.value.icyName,
              onTap: () {
                ref
                    .read(radioModelProvider)
                    .getStations(
                      radioSearch: RadioSearch.name,
                      query: e.value.icyName,
                    )
                    .then((stations) {
                  if (stations != null && stations.isNotEmpty) {
                    onArtistTap(
                      audio: stations.first,
                      artist: e.value.icyTitle,
                      context: context,
                      ref: ref,
                    );
                  }
                });
              },
            ),
            trailing: SizedBox(
              width: 120,
              child: StreamProviderRow(
                text: e.value.icyTitle,
              ),
            ),
          );
        },
      ),
    );
  }
}

class HistoryLead extends StatefulWidget {
  const HistoryLead({
    super.key,
    required this.e,
  });

  final MapEntry<String, MpvMetaData> e;

  @override
  State<HistoryLead> createState() => _HistoryLeadState();
}

class _HistoryLeadState extends State<HistoryLead> {
  late Future<String?> _imageUrl;

  @override
  void initState() {
    super.initState();
    _imageUrl = fetchAlbumArtFromMusicBrainz(widget.e.value.icyTitle);
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.l10n.metadata,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: () => showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                children: widget.e.value
                    .toMap()
                    .entries
                    .map(
                      (e) => ListTile(
                        onTap: e.key == 'icy-url'
                            ? () => launchUrl(Uri.parse(e.value))
                            : null,
                        dense: true,
                        title: Text(e.key),
                        subtitle: Text(e.value),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          child: SizedBox.square(
            dimension: 40,
            child: FutureBuilder(
              future: _imageUrl,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Icon(Iconz().info);
                }
                return Image.network(
                  snapshot.data!,
                  filterQuality: FilterQuality.medium,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> fetchAlbumArtFromMusicBrainz(String icyTitle) async {
    String? songName;
    String? artist;
    final split = widget.e.value.icyTitle.split(' - ');

    if (split.length == 2) {
      artist = split[0];
      songName = split[1];
    } else if (split.length == 3) {
      songName = split[2].trim();
      artist = split[1].trim();
    }
    if (artist == null || songName == null) return null;

    final searchUrl = Uri.parse(
      'https://musicbrainz.org/ws/2/recording/?query=recording:"$songName"%20AND%20artist:"$artist"',
    );
    final searchResponse = await http.get(
      searchUrl,
      headers: {
        'Accept': 'application/json',
        'User-Agent':
            'MusicPod (https://github.com/ubuntu-flutter-community/musicpod)',
      },
    );

    if (searchResponse.statusCode == 200) {
      final searchData = jsonDecode(searchResponse.body);
      final recordings = searchData['recordings'] as List;

      final firstRecording = recordings.first;

      final releaseId = firstRecording['releases'][0]['id'];

      final imageUrl = await _fetchAlbumArtUrlFromReleaseId(releaseId);
      return imageUrl;
    }

    return null;
  }

  Future<String?> _fetchAlbumArtUrlFromReleaseId(String releaseId) async {
    final url = Uri.parse(
      'https://coverartarchive.org/release/$releaseId',
    );
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'User-Agent':
            'MusicPod (https://github.com/ubuntu-flutter-community/musicpod)',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final images = data['images'] as List;

      if (images.isNotEmpty) {
        final artwork = images[0];

        var artwork2 = artwork['image'] as String;
        return artwork2;
      }
    }

    return null;
  }
}
