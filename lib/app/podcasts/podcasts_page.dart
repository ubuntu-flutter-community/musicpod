import 'package:flutter/material.dart';
import 'package:music/app/common/search_field.dart';
import 'package:music/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PodcastsPage extends StatefulWidget {
  const PodcastsPage({super.key});

  @override
  State<PodcastsPage> createState() => _PodcastsPageState();
}

class _PodcastsPageState extends State<PodcastsPage> {
  bool _searchActive = false;
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
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Center(
            child: YaruIconButton(
              isSelected: _searchActive,
              icon: const Icon(YaruIcons.search),
              onPressed: () => setState(() {
                _searchActive = !_searchActive;
              }),
            ),
          ),
        )
      ],
      title: _searchActive
          ? const SearchField()
          : Center(child: Text(context.l10n.podcasts)),
    );

    return YaruDetailPage(
      appBar: appBar,
      body: Center(
        child: Text(context.l10n.podcasts),
      ),
    );
  }
}
