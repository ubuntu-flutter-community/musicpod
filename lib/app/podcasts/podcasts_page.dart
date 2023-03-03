import 'package:flutter/material.dart';
import 'package:music/app/common/audio_card.dart';
import 'package:music/app/common/audio_page.dart';
import 'package:music/app/common/constants.dart';
import 'package:music/app/podcasts/podcast_model.dart';
import 'package:music/app/podcasts/podcast_search_field.dart';
import 'package:music/data/audio.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PodcastsPage extends StatefulWidget {
  const PodcastsPage({super.key});

  @override
  State<PodcastsPage> createState() => _PodcastsPageState();
}

class _PodcastsPageState extends State<PodcastsPage> {
  @override
  void initState() {
    super.initState();
    context.read<PodcastModel>().init();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PodcastModel>();

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
      body: model.charts == null
          ? const Center(
              child: YaruCircularProgressIndicator(),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(kYaruPagePadding),
              itemCount: model.charts!.isEmpty ? 30 : model.charts!.length,
              gridDelegate: kImageGridDelegate,
              itemBuilder: (context, index) {
                final audio = model.charts!.isEmpty
                    ? Audio()
                    : model.charts!.elementAt(index);
                return AudioCard(
                  onTap: () {
                    model.search(searchQuery: audio.name).then((value) {
                      if (model.searchResult.isEmpty) {
                        return;
                      }

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            final album = model.searchResult.where(
                              (a) =>
                                  a.metadata != null &&
                                  a.metadata!.album != null &&
                                  a.metadata?.album == audio.metadata?.album,
                            );

                            return AudioPage(
                              title: const PodcastSearchField(),
                              deletable: false,
                              audioPageType: audio.metadata?.album != null
                                  ? AudioPageType.albumList
                                  : AudioPageType.list,
                              editableName: false,
                              audios: album.isNotEmpty == true
                                  ? Set.from(album)
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
                  audio: audio,
                );
              },
            ),
    );
  }
}
