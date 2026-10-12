import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/icons.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/side_bar_fall_back_image.dart';
import '../../common/view/theme.dart';
import '../manager/podcast_short_info_manager.dart';

class PodcastPageSideBarIcon extends ConsumerWidget {
  const PodcastPageSideBarIcon({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = ref
        .watch(podcastShortInfoManagerProvider(feedUrl))
        .value
        ?.imageUrl;
    if (imageUrl == null) {
      return SideBarFallBackImage(child: Icon(Iconz.podcast));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox(
        width: sideBarImageSize,
        height: sideBarImageSize,
        child: SafeNetworkImage(
          url: imageUrl,
          height: sideBarImageSize,
          width: sideBarImageSize,
          cacheHeight: (sideBarImageSize * 2).toInt(),
          cacheWidth: (sideBarImageSize * 2).toInt(),
          fit: BoxFit.fitHeight,
          filterQuality: FilterQuality.medium,
          loadingWidget: Icon(Iconz.podcast),
          errorWidget: Icon(Iconz.podcast),
        ),
      ),
    );
  }
}
