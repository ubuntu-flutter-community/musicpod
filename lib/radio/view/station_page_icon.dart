import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/icons.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/side_bar_fall_back_image.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../manager/station_manager.dart';

class StationPageIcon extends StatelessWidget with WatchItMixin {
  const StationPageIcon({
    super.key,
    required this.uuid,
    required this.selected,
  });

  final String uuid;
  final bool selected;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(6),
    child: Container(
      color: context.theme.cardColor,
      height: sideBarImageSize,
      width: sideBarImageSize,
      child: SafeNetworkImage(
        fallbackWidget: SideBarFallBackImage(
          color: getAlphabetColor(uuid),
          child: selected ? Icon(Iconz.starFilled) : Icon(Iconz.star),
        ),
        errorWidget: SideBarFallBackImage(
          color: getAlphabetColor(uuid),
          child: selected ? Icon(Iconz.starFilled) : Icon(Iconz.star),
        ),
        fit: BoxFit.fitHeight,
        url: watchValue(
          (StationManager m) => m.command.select((audio) => audio?.imageUrl),
          param1: uuid,
        ),
        filterQuality: FilterQuality.medium,
      ),
    ),
  );
}
