import 'package:flutter/material.dart';
import 'package:music/app/common/search_field.dart';
import 'package:music/l10n/l10n.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PodcastsPage extends StatefulWidget {
  const PodcastsPage({super.key});

  @override
  State<PodcastsPage> createState() => _PodcastsPageState();
}

class _PodcastsPageState extends State<PodcastsPage> {
  @override
  Widget build(BuildContext context) {
    final appBar = YaruWindowTitleBar(
      leading: Navigator.of(context).canPop()
          ? const YaruBackButton(
              style: YaruBackButtonStyle.rounded,
            )
          : const SizedBox(
              width: 40,
            ),
      title: const SearchField(),
    );

    return YaruDetailPage(
      appBar: appBar,
      body: Center(
        child: Text(context.l10n.podcasts),
      ),
    );
  }
}
