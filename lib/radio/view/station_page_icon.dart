import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/icons.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/side_bar_fall_back_image.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../manager/station_manager.dart';

class StationPageIcon extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final imageResult = ref.watch(stationImageManagerProvider(uuid));

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        color: context.theme.cardColor,
        height: dimension ?? sideBarImageSize,
        width: dimension ?? sideBarImageSize,
        child: imageResult.when(
          loading: () => _getIcon(context.colorScheme, selected),
          error: (error, _) => _getIcon(context.theme.colorScheme, selected),
          data: (url) => url == null
              ? _getIcon(context.colorScheme, selected)
              : SafeNetworkImage(
                  errorWidget: _getIcon(context.theme.colorScheme, selected),
                  height: dimension ?? sideBarImageSize,
                  width: dimension ?? sideBarImageSize,
                  loadingWidget: Center(
                    child: _getIcon(context.theme.colorScheme, selected),
                  ),
                  cacheHeight: ((dimension ?? sideBarImageSize) * 2).toInt(),
                  cacheWidth: ((dimension ?? sideBarImageSize) * 2).toInt(),
                  fit: BoxFit.fitHeight,
                  url: url,
                  filterQuality: FilterQuality.medium,
                ),
        ),
      ),
    );
  }

  SideBarFallBackImage _getIcon(ColorScheme colorScheme, bool selected) =>
      SideBarFallBackImage(
        height: dimension ?? sideBarImageSize,
        width: dimension ?? sideBarImageSize,
        color: getAlphabetColor(uuid),
        child: Icon(
          selected ? Iconz.starFilled : Iconz.star,
          size: dimension != null ? dimension! * 0.5 : null,
        ),
      );
}
