import '../../../build_context_x.dart';
import '../../../common.dart';
import 'package:flutter/material.dart';

class StationPageIcon extends StatelessWidget {
  const StationPageIcon({
    super.key,
    this.imageUrl,
    required this.selected,
    required this.fallBackColor,
  });

  final String? imageUrl;
  final bool selected;
  final Color fallBackColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        color: context.t.cardColor,
        height: sideBarImageSize,
        width: sideBarImageSize,
        child: SafeNetworkImage(
          fallBackIcon: SideBarFallBackImage(
            color: fallBackColor,
            child: selected
                ? Icon(Iconz().starFilled)
                : Icon(
                    Iconz().star,
                  ),
          ),
          errorIcon: SideBarFallBackImage(
            color: fallBackColor,
            child: selected
                ? Icon(Iconz().imageMissingFilled)
                : Icon(
                    Iconz().imageMissing,
                  ),
          ),
          fit: BoxFit.fitHeight,
          url: imageUrl,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}
