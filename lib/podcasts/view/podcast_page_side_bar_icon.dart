import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/icons.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/side_bar_fall_back_image.dart';
import '../../common/view/theme.dart';
import '../../library/library_model.dart';

class PodcastPageSideBarIcon extends StatefulWidget {
  const PodcastPageSideBarIcon({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  State<PodcastPageSideBarIcon> createState() => _PodcastPageSideBarIconState();
}

class _PodcastPageSideBarIconState extends State<PodcastPageSideBarIcon> {
  late final String? imageUrl;

  @override
  void initState() {
    super.initState();
    final podcast = di<LibraryModel>().getPodcast(widget.feedUrl);
    imageUrl =
        podcast?.firstOrNull?.albumArtUrl ?? podcast?.firstOrNull?.imageUrl;
  }

  @override
  Widget build(BuildContext context) {
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
          fit: BoxFit.fitHeight,
          filterQuality: FilterQuality.medium,
          fallBackIcon: Icon(Iconz.podcast, size: sideBarImageSize),
          errorIcon: Icon(Iconz.podcast, size: sideBarImageSize),
        ),
      ),
    );
  }
}
