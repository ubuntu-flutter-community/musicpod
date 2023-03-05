import 'package:flutter/material.dart';
import 'package:music/app/common/audio_card.dart';
import 'package:music/app/common/audio_page.dart';
import 'package:music/app/common/constants.dart';
import 'package:music/app/player_model.dart';
import 'package:music/app/playlists/playlist_model.dart';
import 'package:music/app/podcasts/podcast_model.dart';
import 'package:music/app/podcasts/podcast_search_field.dart';
import 'package:music/data/audio.dart';
import 'package:music/utils.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PodcastsPage extends StatelessWidget {
  const PodcastsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PodcastModel>();
    final playerModel = context.watch<PlayerModel>();
    final playListModel = context.watch<PlaylistModel>();

    Widget grid;
    if (model.chartsPodcasts == null) {
      grid = GridView(
        gridDelegate: kImageGridDelegate,
        padding: kGridPadding,
        children: List.generate(30, (index) => Audio())
            .map((e) => const AudioCard())
            .toList(),
      );
    } else if (model.chartsPodcasts!.isEmpty == true) {
      grid = const SizedBox.shrink();
    } else {
      grid = GridView.builder(
        padding: kGridPadding,
        itemCount: model.chartsPodcasts!.length,
        gridDelegate: kImageGridDelegate,
        itemBuilder: (context, index) {
          final podcast = model.chartsPodcasts!.elementAt(index);
          final starred = playListModel.playlists
              .containsKey(podcast.first.metadata?.album);
          return AudioCard(
            imageUrl: podcast.first.imageUrl,
            onPlay: () => playerModel.startPlaylist(podcast),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return AudioPage(
                      sort: false,
                      showTrack: false,
                      likeButton: YaruIconButton(
                        icon: Icon(
                          starred ? YaruIcons.star_filled : YaruIcons.star,
                        ),
                        onPressed: starred
                            ? () => playListModel
                                .removePlaylist(podcast.first.metadata!.album!)
                            : () {
                                playListModel.addPlaylist(
                                  podcast.first.metadata!.album!,
                                  podcast,
                                );
                              },
                      ),
                      imageUrl: podcast.first.imageUrl,
                      title: const PodcastSearchField(),
                      deletable: false,
                      audioPageType: AudioPageType.albumList,
                      editableName: false,
                      audios: podcast,
                      pageName: podcast.first.metadata?.album ??
                          podcast.first.metadata?.title ??
                          podcast.first.name ??
                          '',
                    );
                  },
                ),
              );
            },
          );
        },
      );
    }

    var textStyle = Theme.of(context)
        .textTheme
        .bodyLarge
        ?.copyWith(fontWeight: FontWeight.w100);
    var buttonStyle = TextButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    );

    final chartsEnqueued =
        model.chartsPodcasts == null || model.chartsPodcasts!.isEmpty
            ? false
            : listsAreEqual(
                playerModel.queue,
                model.chartsPodcasts!.first.toList(),
              );

    final page = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 20),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.inverseSurface,
                child: IconButton(
                  onPressed: () {
                    if (playerModel.isPlaying && chartsEnqueued) {
                      playerModel.pause();
                    } else {
                      if (model.chartsPodcasts?.first.isNotEmpty == true) {
                        playerModel.startPlaylist(model.chartsPodcasts!.first);
                      }
                    }
                  },
                  icon: Icon(
                    playerModel.isPlaying && chartsEnqueued
                        ? YaruIcons.media_pause
                        : YaruIcons.media_play,
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              YaruPopupMenuButton<PodcastGenre>(
                style: buttonStyle,
                onSelected: (value) {
                  model.podcastGenre = value;
                  model.loadCharts();
                },
                initialValue: model.podcastGenre,
                child: Text(
                  model.podcastGenre.id,
                  style: textStyle,
                ),
                itemBuilder: (context) {
                  return [
                    for (final genre in model.sortedGenres)
                      PopupMenuItem(
                        value: genre,
                        child: Text(genre.id),
                      )
                  ];
                },
              ),
              const SizedBox(
                width: 10,
              ),
              YaruPopupMenuButton<Country>(
                style: buttonStyle,
                onSelected: (value) {
                  model.country = value;
                  model.loadCharts();
                },
                initialValue: model.country,
                child: Text(
                  model.country.countryCode,
                  style: textStyle,
                ),
                itemBuilder: (context) {
                  return [
                    for (final c in model.sortedCountries)
                      PopupMenuItem(
                        value: c,
                        child: Text(c.countryCode),
                      )
                  ];
                },
              ),
            ],
          ),
        ),
        const Divider(
          height: 0,
        ),
        const SizedBox(
          height: 15,
        ),
        Expanded(child: grid),
      ],
    );

    return YaruDetailPage(
      appBar: YaruWindowTitleBar(
        leading: Navigator.canPop(context)
            ? const YaruBackButton(
                style: YaruBackButtonStyle.rounded,
              )
            : const SizedBox(
                width: 40,
              ),
        title: PodcastSearchField(
          onPlay: playerModel.startPlaylist,
        ),
      ),
      body: page,
    );
  }
}
