import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routing_manager.dart';
import '../../common/view/ui_constants.dart';
import '../../dependencies.dart';
import '../../extensions/build_context_x.dart';
import '../../podcasts/service/podcast_service.dart';
import '../../podcasts/view/podcast_page.dart';

class CustomPodcastSection extends ConsumerStatefulWidget {
  const CustomPodcastSection({super.key});

  @override
  ConsumerState<CustomPodcastSection> createState() =>
      _CustomPodcastSectionState();
}

class _CustomPodcastSectionState extends ConsumerState<CustomPodcastSection> {
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
                          di<PodcastService>()
                              .findEpisodes(
                                feedUrl: _urlController.text,
                                tryFromDbOnly: false,
                              )
                              .then((episodes) {
                                if (episodes.isEmpty && context.mounted) {
                                  context.toast(
                                    Text(context.l10n.noPodcastFound),
                                  );
                                } else if (context.mounted) {
                                  ref
                                      .read(routingManagerProvider.notifier)
                                      .push(
                                        pageId: _urlController.text,
                                        builder: (context) => PodcastPage(
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
