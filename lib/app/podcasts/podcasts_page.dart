import 'package:flutter/material.dart';
import 'package:music/app/common/audio_card.dart';
import 'package:music/app/common/audio_page.dart';
import 'package:music/app/common/constants.dart';
import 'package:music/app/podcasts/podcast_model.dart';
import 'package:music/app/podcasts/podcast_search_field.dart';
import 'package:music/data/audio.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PodcastsPage extends StatefulWidget {
  const PodcastsPage({super.key});

  @override
  State<PodcastsPage> createState() => _PodcastsPageState();
}

class _PodcastsPageState extends State<PodcastsPage> {
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
          padding: kHeaderPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Science Top 20',
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(fontWeight: FontWeight.w100),
              ),
              const SizedBox(
                height: kYaruPagePadding,
              ),
              Wrap(
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.start,
                spacing: 10,
                children: [
                  ChoiceChip(
                    label: const Text('Germany'),
                    selected: model.country == Country.GERMANY,
                    onSelected: (value) {
                      model.country = Country.GERMANY;
                      model.loadCharts();
                    },
                  ),
                  ChoiceChip(
                    label: const Text('USA'),
                    selected: model.country == Country.UNITED_STATES,
                    onSelected: (value) {
                      model.country = Country.UNITED_STATES;
                      model.loadCharts();
                    },
                  ),
                  ChoiceChip(
                    label: const Text('UK'),
                    selected: model.country == Country.UNITED_KINGDOM,
                    onSelected: (value) {
                      model.country = Country.UNITED_KINGDOM;
                      model.loadCharts();
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Denmark'),
                    selected: model.country == Country.DENMARK,
                    onSelected: (value) {
                      model.country = Country.DENMARK;
                      model.loadCharts();
                    },
                  ),
                ],
              ),
            ],
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
