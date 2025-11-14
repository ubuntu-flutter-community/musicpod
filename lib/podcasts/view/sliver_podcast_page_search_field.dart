import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/icons.dart';
import '../../common/view/sliver_app_bar_bottom_space.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../podcast_model.dart';

class SliverPodcastPageSearchField extends StatefulWidget
    with WatchItStatefulWidgetMixin {
  const SliverPodcastPageSearchField({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  State<SliverPodcastPageSearchField> createState() =>
      _SliverPodcastPageSearchFieldState();
}

class _SliverPodcastPageSearchFieldState
    extends State<SliverPodcastPageSearchField> {
  late TextEditingController _textEditingController;
  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(
      text: di<PodcastModel>().getSearchQuery(widget.feedUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filter = watchPropertyValue(
      (PodcastModel m) => m.filter.localize(l10n),
    );

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 10),
      sliver: SliverAppBar(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        elevation: 0,
        backgroundColor: context.theme.scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        pinned: true,
        centerTitle: true,
        titleSpacing: 0,
        bottom: const SliverAppBarBottomSpace(),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kLargestSpace),
          child: SizedBox(
            width: 300,
            child: TextField(
              controller: _textEditingController,
              autofocus: true,
              decoration: InputDecoration(
                label: Text(l10n.search),
                prefix: InkWell(
                  onTap: di<PodcastModel>().setFilter,
                  child: Text('$filter: '),
                ),
                suffixIcon: IconButton(
                  isSelected: true,
                  style: IconButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(kYaruButtonRadius),
                        topRight: Radius.circular(kYaruButtonRadius),
                      ),
                    ),
                  ),
                  onPressed: () => di<PodcastModel>().toggleShowSearch(
                    feedUrl: widget.feedUrl,
                  ),
                  icon: Icon(Iconz.search, semanticLabel: context.l10n.search),
                ),
              ),
              onChanged: (v) => di<PodcastModel>().setSearchQuery(
                feedUrl: widget.feedUrl,
                value: v,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
