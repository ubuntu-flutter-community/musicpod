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
    this.dimension,
  });

  final String uuid;
  final bool selected;
  final double? dimension;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(6),
    child: Container(
      color: context.theme.cardColor,
      height: dimension ?? sideBarImageSize,
      width: dimension ?? sideBarImageSize,
      child:
          watchValue(
            (StationImageManager m) => m.command.results,
            param1: uuid,
          ).toWidget(
            onError: (error, lastResult, param) =>
                _getIcon(context.theme.colorScheme, selected),
            whileRunning: (lastResult, param) =>
                _getIcon(context.colorScheme, selected),
            onData: (url, param) => url == null
                ? _getIcon(context.colorScheme, selected)
                : SafeNetworkImage(
                    errorWidget: _getIcon(context.theme.colorScheme, selected),
                    height: dimension ?? sideBarImageSize,
                    width: dimension ?? sideBarImageSize,
                    cacheHeight: ((dimension ?? sideBarImageSize) * 2).toInt(),
                    cacheWidth: ((dimension ?? sideBarImageSize) * 2).toInt(),
                    fit: BoxFit.fitHeight,
                    url: url,
                    filterQuality: FilterQuality.medium,
                  ),
          ),
    ),
  );

  SideBarFallBackImage _getIcon(ColorScheme colorScheme, bool selected) =>
      SideBarFallBackImage(
        height: dimension ?? audioCardDimension,
        width: dimension ?? audioCardDimension,
        color: getAlphabetColor(uuid),
        child: Icon(
          selected ? Iconz.starFilled : Iconz.star,
          size: dimension != null ? dimension! * 0.5 : null,
        ),
      );
}
