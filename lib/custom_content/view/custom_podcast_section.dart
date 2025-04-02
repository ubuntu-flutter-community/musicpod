import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/common_widgets.dart';
import '../../common/view/ui_constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../podcasts/podcast_model.dart';
import '../../podcasts/view/podcast_page.dart';

class CustomPodcastSection extends StatefulWidget {
  const CustomPodcastSection({super.key});

  @override
  State<CustomPodcastSection> createState() => _CustomPodcastSectionState();
}

class _CustomPodcastSectionState extends State<CustomPodcastSection> {
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
  }

  @override
  void dispose() {
    _urlController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextField(
          autofocus: true,
          controller: _urlController,
          decoration: InputDecoration(label: Text(context.l10n.podcastFeedUrl)),
        ),
        const SizedBox(
          height: kLargestSpace,
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ListenableBuilder(
                listenable: _urlController,
                builder: (context, _) => ImportantButton(
                  onPressed: _urlController.text.isEmpty
                      ? null
                      : () {
                          di<PodcastModel>().loadPodcast(
                            feedUrl: _urlController.text,
                            onFind: (podcast) => di<LibraryModel>().push(
                              builder: (_) => PodcastPage(
                                imageUrl: podcast.firstOrNull?.imageUrl,
                                preFetchedEpisodes: podcast,
                                feedUrl: _urlController.text,
                                title: podcast.firstOrNull?.album ??
                                    podcast.firstOrNull?.title ??
                                    _urlController.text,
                              ),
                              pageId: _urlController.text,
                            ),
                          );
                        },
                  child: Text(
                    context.l10n.search,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
