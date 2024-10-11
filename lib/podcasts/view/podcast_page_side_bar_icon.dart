import 'package:flutter/material.dart';

import '../../common/view/icons.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/side_bar_fall_back_image.dart';
import '../../common/view/theme.dart';

class PodcastPageSideBarIcon extends StatelessWidget {
  const PodcastPageSideBarIcon({super.key, this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return SideBarFallBackImage(
        child: Icon(Iconz.podcast),
      );
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
          fallBackIcon: Icon(
            Iconz.podcast,
            size: sideBarImageSize,
          ),
          errorIcon: Icon(
            Iconz.podcast,
            size: sideBarImageSize,
          ),
        ),
      ),
    );
  }
}
