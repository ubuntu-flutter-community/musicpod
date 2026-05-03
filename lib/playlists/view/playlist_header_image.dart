import 'package:flutter/material.dart';

import '../../common/view/fall_back_header_image.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';

class PlaylistHeaderImage extends StatelessWidget {
  const PlaylistHeaderImage({super.key, required this.pageId});

  final String pageId;

  @override
  Widget build(BuildContext context) => FallBackHeaderImage(
    color: getAlphabetColor(pageId),
    child: Icon(Iconz.playlist, size: 65),
  );
}
