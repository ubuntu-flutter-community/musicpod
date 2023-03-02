import 'package:flutter/material.dart';
import 'package:music/app/common/audio_page.dart';
import 'package:music/app/podcasts/podcast_model.dart';
import 'package:music/l10n/l10n.dart';
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

    return model.podcasts.isEmpty
        ? const Center(
            child: YaruCircularProgressIndicator(),
          )
        : AudioPage(
            audioPageType: AudioPageType.albumList,
            title: Text(context.l10n.podcasts), //TODO: add search
            audios: model.podcasts,
            pageName: context.l10n.podcasts,
            editableName: false,
            deletable: false,
          );
  }
}
