import 'package:flutter/material.dart';
import '../../common/view/icons.dart';
import '../../common/view/safe_network_image.dart';
import '../../extensions/build_context_x.dart';

class PodcastPageImage extends StatelessWidget {
  const PodcastPageImage({super.key, required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final safeNetworkImage = SafeNetworkImage(
      fallBackIcon: Icon(Iconz.podcast, size: 80, color: theme.hintColor),
      errorIcon: Icon(Iconz.podcast, size: 80, color: theme.hintColor),
      url: imageUrl,
      fit: BoxFit.fitHeight,
      filterQuality: FilterQuality.medium,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      child: safeNetworkImage,
      onTap: () => showDialog(
        context: context,
        builder: (context) => SimpleDialog(
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: safeNetworkImage,
            ),
          ],
        ),
      ),
    );
  }
}
