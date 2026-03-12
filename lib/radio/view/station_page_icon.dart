import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/connectivity_model.dart';
import '../../common/view/icons.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/side_bar_fall_back_image.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../radio_model.dart';

class StationPageIcon extends StatelessWidget with WatchItMixin {
  const StationPageIcon({
    super.key,
    required this.uuid,
    required this.selected,
  });

  final String uuid;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    watchPropertyValue((ConnectivityModel m) => m.isOnline);
    if (di<RadioModel>().getStationByUUID(uuid) == null) {
      callOnceAfterThisBuild(
        (_) => di<RadioModel>().getStationByUUIDCommand(uuid).run(),
      );
    }
    final stationResults = watchValue(
      (RadioModel m) => m.getStationByUUIDCommand(uuid).results,
    );

    final station = stationResults.data;

    final fallBackColor = getAlphabetColor(uuid);

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        color: context.theme.cardColor,
        height: sideBarImageSize,
        width: sideBarImageSize,
        child: SafeNetworkImage(
          fallBackIcon: SideBarFallBackImage(
            color: fallBackColor,
            child: selected ? Icon(Iconz.starFilled) : Icon(Iconz.star),
          ),
          errorIcon: SideBarFallBackImage(
            color: fallBackColor,
            child: selected ? Icon(Iconz.starFilled) : Icon(Iconz.star),
          ),
          fit: BoxFit.fitHeight,
          url: station?.imageUrl,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}
