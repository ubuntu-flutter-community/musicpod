import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../manager/episodes_manager.dart';

class PodcastPageSearchButton extends ConsumerWidget {
  const PodcastPageSearchButton({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = context.l10n.search;
    final isSelected =
        ref.watch(episodesManagerProvider(feedUrl)).value?.showSearch ?? false;

    return IconButton(
      tooltip: search,
      isSelected: isSelected,
      onPressed: feedUrl.isEmpty
          ? null
          : () =>
              ref.read(episodesManagerProvider(feedUrl).notifier).toggleShowSearch(),
      icon: Icon(Iconz.search, semanticLabel: search),
    );
  }
}
