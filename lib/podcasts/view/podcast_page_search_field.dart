import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/icons.dart';
import '../../common/view/sliver_app_bar_bottom_space.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../data/podcast_episode_filter.dart';
import '../manager/episodes_manager.dart';

class PodcastPageSearchField extends ConsumerStatefulWidget {
  const PodcastPageSearchField({
    super.key,
    required this.feedUrl,
    this.sliver = true,
  });

  final String feedUrl;
  final bool sliver;

  @override
  ConsumerState<PodcastPageSearchField> createState() =>
      _PodcastPageSearchFieldState();
}

class _PodcastPageSearchFieldState
    extends ConsumerState<PodcastPageSearchField> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    final initialQuery =
        ref.read(episodesManagerProvider(widget.feedUrl)).value?.searchQuery ??
        '';
    _textEditingController = TextEditingController(text: initialQuery);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final episodesState = ref
        .watch(episodesManagerProvider(widget.feedUrl))
        .value;
    final filter = (episodesState?.filter ?? PodcastEpisodeFilter.title)
        .localize(l10n);

    final field = Padding(
      padding: const EdgeInsets.symmetric(horizontal: kLargestSpace),
      child: SizedBox(
        width: 300,
        child: TextField(
          controller: _textEditingController,
          autofocus: true,
          decoration: InputDecoration(
            label: Text(l10n.search),
            prefix: InkWell(
              onTap: ref
                  .read(episodesManagerProvider(widget.feedUrl).notifier)
                  .setFilter,
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
              onPressed: ref
                  .read(episodesManagerProvider(widget.feedUrl).notifier)
                  .toggleShowSearch,
              icon: Icon(Iconz.search, semanticLabel: context.l10n.search),
            ),
          ),
          onChanged: ref
              .read(episodesManagerProvider(widget.feedUrl).notifier)
              .setSearchQuery,
        ),
      ),
    );

    if (!widget.sliver) {
      return Padding(
        padding: const EdgeInsets.only(top: kLargestSpace),
        child: field,
      );
    }

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
        title: field,
      ),
    );
  }
}
