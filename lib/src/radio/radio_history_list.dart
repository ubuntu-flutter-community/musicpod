import 'dart:convert';

import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/yaru.dart';

import '../../common.dart';
import '../../l10n.dart';
import '../../library.dart';
import '../../player.dart';
import '../../radio.dart';
import '../data/mpv_meta_data.dart';
import 'radio_search.dart';

class RadioHistoryList extends ConsumerWidget {
  const RadioHistoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radioHistory =
        ref.watch(libraryModelProvider.select((l) => l.radioHistory));
    final current = ref.watch(playerModelProvider.select((p) => p.mpvMetaData));

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
            selected: current?.icyTitle != null &&
                current?.icyTitle == e.value.icyTitle,
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
    final icyTitle = widget.e.value.icyTitle;
    _imageUrl = fetchAlbumArt(icyTitle);
  }

  @override
  Widget build(BuildContext context) {
    final bR = BorderRadius.circular(5);
    final storedUrl = UrlStore().get(widget.e.key);

    return Tooltip(
      message: context.l10n.metadata,
      child: ClipRRect(
        borderRadius: bR,
        child: InkWell(
          borderRadius: bR,
          onTap: () => showDialog(
            context: context,
            builder: (context) {
              final image = UrlStore().get(widget.e.key);
              return SimpleDialog(
                titlePadding: EdgeInsets.zero,
                contentPadding: const EdgeInsets.only(bottom: 10),
                children: [
                  if (image != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(kYaruContainerRadius),
                        topRight: Radius.circular(kYaruContainerRadius),
                      ),
                      child: SizedBox(
                        width: 250,
                        child: SafeNetworkImage(
                          fit: BoxFit.fitHeight,
                          url: image,
                        ),
                      ),
                    ),
                  ...widget.e.value
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
                      .toList()
                      .reversed,
                ],
              );
            },
          ),
          child: SizedBox.square(
            dimension: 40,
            child: storedUrl != null
                ? SafeNetworkImage(url: storedUrl)
                : FutureBuilder(
                    future: _imageUrl,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Icon(Iconz().info);
                      }

                      return SafeNetworkImage(
                        url: UrlStore().put(
                          icyTitle: widget.e.value.icyTitle,
                          imageUrl: snapshot.data!,
                        ),
                        filterQuality: FilterQuality.medium,
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Future<String?> fetchAlbumArt(String icyTitle) async {
    return UrlStore().get(icyTitle) ?? await _fetchAlbumArt(icyTitle);
  }

  Future<String?> _fetchAlbumArt(String icyTitle) async {
    String? songName;
    String? artist;
    var split = icyTitle.split(' - ');

    songName = split.lastOrNull;
    artist = split.elementAtOrNull(split.indexOf(split.last) - 1);

    if (artist == null || songName == null) return null;

    final searchUrl = Uri.parse(
      'https://musicbrainz.org/ws/2/recording/?query=recording:"$songName"%20AND%20artist:"$artist"',
    );

    try {
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
    } on Exception catch (_) {
      return null;
    }

    return null;
  }

  Future<String?> _fetchAlbumArtUrlFromReleaseId(String releaseId) async {
    final url = Uri.parse(
      'https://coverartarchive.org/release/$releaseId',
    );
    try {
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

          return (artwork['image']) as String?;
        }
      }
    } on Exception catch (_) {
      return null;
    }

    return null;
  }
}
