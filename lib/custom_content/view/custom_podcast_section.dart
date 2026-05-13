import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/routing_manager.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../podcasts/podcast_manager.dart';
import '../../podcasts/view/lazy_podcast_page.dart';

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
        const SizedBox(height: kLargestSpace),
        Align(
          alignment: Alignment.bottomRight,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ListenableBuilder(
                listenable: _urlController,
                builder: (context, _) => ElevatedButton(
                  onPressed:
                      _urlController.text.isEmpty ||
                          !_urlController.text.startsWith('http')
                      ? null
                      : () {
                          di<PodcastManager>()
                              .getEpisodesCommand(_urlController.text)
                              .runAsync((
                                item: null,
                                feedUrl: _urlController.text,
                              ))
                              .then((v) {
                                if (v.isEmpty && context.mounted) {
                                  context.toast(
                                    Text(context.l10n.noPodcastFound),
                                  );
                                } else {
                                  di<RoutingManager>().push(
                                    pageId: _urlController.text,
                                    builder: (context) => LazyPodcastPage(
                                      imageUrl: v.firstOrNull?.imageUrl,
                                      feedUrl: _urlController.text,
                                    ),
                                  );
                                }
                              });
                        },
                  child: Text(context.l10n.search),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
