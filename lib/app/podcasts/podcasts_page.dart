import 'package:flutter/material.dart';
import 'package:music/app/common/audio_card.dart';
import 'package:music/app/common/audio_page.dart';
import 'package:music/app/common/constants.dart';
import 'package:music/app/podcasts/podcast_model.dart';
import 'package:music/app/podcasts/podcast_search_field.dart';
import 'package:music/data/audio.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PodcastsPage extends StatelessWidget {
  const PodcastsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PodcastModel>();

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

                      return AudioPage(
                        imageUrl: audio.imageUrl,
                        title: const PodcastSearchField(),
                        deletable: false,
                        audioPageType: audio.metadata?.album != null
                            ? AudioPageType.albumList
                            : AudioPageType.list,
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

    final page = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 20),
          child: SizedBox(
            height: 40,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(model.podcastGenre.id),
                    selected: true,
                    onSelected: (value) {},
                  ),
                ),
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final genre in model.notSelectedGenres)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Text(genre.id),
                            selected: model.podcastGenre == genre,
                            onSelected: (value) {
                              model.podcastGenre = genre;
                              model.loadCharts();
                            },
                          ),
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
          child: SizedBox(
            height: 40,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(model.getLocalizedCountry(model.country)),
                    selected: true,
                    onSelected: (value) {
                      // model.country = country;
                      // model.loadCharts();
                    },
                  ),
                ),
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final country in model.notSelectedCountries)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Text(model.getLocalizedCountry(country)),
                            selected: model.country == country,
                            onSelected: (value) {
                              model.country = country;
                              model.loadCharts();
                            },
                          ),
                        ),
                      const Divider(
                        height: 9,
                        thickness: 0.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
