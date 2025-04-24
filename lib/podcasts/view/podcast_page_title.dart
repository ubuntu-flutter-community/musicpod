import 'package:html/parser.dart';

import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

class PodcastPageTitle extends StatefulWidget with WatchItStatefulWidgetMixin {
  const PodcastPageTitle({
    super.key,
    required this.feedUrl,
  });

  final String feedUrl;

  @override
  State<PodcastPageTitle> createState() => _PodcastPageTitleState();
}

class _PodcastPageTitleState extends State<PodcastPageTitle> {
  late String title;

  @override
  void initState() {
    super.initState();
    final podcast = di<LibraryModel>().getPodcast(widget.feedUrl);
    title = podcast?.firstOrNull?.album ??
        podcast?.firstOrNull?.title ??
        podcast?.firstOrNull.toString() ??
        context.l10n.podcasts;
  }

  @override
  Widget build(BuildContext context) {
    watchPropertyValue((LibraryModel m) => m.podcastUpdatesLength);
    final visible = di<LibraryModel>().podcastUpdateAvailable(widget.feedUrl);
    return Badge(
      backgroundColor: context.theme.colorScheme.primary,
      isLabelVisible: visible,
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(right: visible ? 10 : 0),
        child: Text(HtmlParser(title).parseFragment().text ?? title),
      ),
    );
  }
}

class PodcastPageSubTitle extends StatefulWidget {
  const PodcastPageSubTitle({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  State<PodcastPageSubTitle> createState() => _PodcastPageSubTitleState();
}

class _PodcastPageSubTitleState extends State<PodcastPageSubTitle> {
  late String subtitle;

  @override
  void initState() {
    super.initState();
    final podcast = di<LibraryModel>().getPodcast(widget.feedUrl);
    subtitle = podcast?.firstOrNull?.artist ?? context.l10n.podcast;
  }

  @override
  Widget build(BuildContext context) => Text(subtitle);
}
