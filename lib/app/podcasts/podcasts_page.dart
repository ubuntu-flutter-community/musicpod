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

    final GridView grid;
    if (model.charts?.isNotEmpty == true) {
      grid = GridView.builder(
        padding: kGridPadding,
        itemCount: model.charts!.length,
        gridDelegate: kImageGridDelegate,
        itemBuilder: (context, index) {
          final audio = model.charts!.elementAt(index);
          return AudioCard(
            audio: audio,
            onPlay: () {
              final album = model.charts?.where(
                (a) =>
                    a.metadata != null &&
                    a.metadata!.album != null &&
                    a.metadata?.album == audio.metadata?.album,
              );
              if (album != null) {
                playerModel.startPlaylist(album.toSet());
              }
            },
            onTap: () {
              model.search(searchQuery: audio.name).then((value) {
                if (model.searchResult?.isEmpty == true) {
                  return;
                }

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      final album = model.searchResult?.where(
                        (a) =>
                            a.metadata != null &&
                            a.metadata!.album != null &&
                            a.metadata?.album == audio.metadata?.album,
                      );
                      final starred = audio.metadata?.title == null
                          ? false
                          : playListModel.playlists
                              .containsKey(audio.metadata!.title!);

                      return AudioPage(
                        likeButton: YaruIconButton(
                          icon: Icon(
                            starred ? YaruIcons.star_filled : YaruIcons.star,
                          ),
                          onPressed: starred
                              ? () => playListModel
                                  .removePlaylist(audio.metadata!.title!)
                              : () {
                                  model
                                      .search(searchQuery: audio.name)
                                      .then((value) {
                                    if (model.searchResult?.isEmpty == true) {
                                      return;
                                    }
                                    final album = model.searchResult?.where(
                                      (a) =>
                                          a.metadata != null &&
                                          a.metadata!.album != null &&
                                          a.metadata?.album ==
                                              audio.metadata?.album,
                                    );
                                    if (album?.isNotEmpty == true &&
                                        audio.metadata?.title != null) {
                                      playListModel.addPlaylist(
                                        audio.metadata!.title!,
                                        album!.toSet(),
                                      );
                                    }
                                  });
                                },
                        ),
                        imageUrl: audio.imageUrl,
                        title: const PodcastSearchField(),
                        deletable: false,
                        audioPageType: AudioPageType.albumList,
                        editableName: false,
                        audios: album?.isNotEmpty == true
                            ? Set.from(album!)
                            : {audio},
                        pageName: audio.metadata?.album ??
                            audio.metadata?.title ??
                            audio.name ??
                            '',
                      );
                    },
                  ),
                );
              });
            },
          );
        },
      );
    } else {
      grid = GridView(
        gridDelegate: kImageGridDelegate,
        padding: kGridPadding,
        children: [
          for (final dummy in List.generate(30, (index) => Audio()))
            AudioCard(audio: dummy)
        ],
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
        listsAreEqual(playerModel.queue, model.charts?.toList());

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
                      if (model.charts?.isNotEmpty == true) {
                        playerModel.startPlaylist(model.charts!);
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
        title: const PodcastSearchField(),
      ),
      body: page,
    );
  }
}
