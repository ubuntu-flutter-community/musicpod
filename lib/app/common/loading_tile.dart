import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yaru_widgets/constants.dart';

import 'constants.dart';

class LoadingTile extends StatelessWidget {
  const LoadingTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;
    return Shimmer.fromColors(
      baseColor: light ? kShimmerBaseLight : kShimmerBaseDark,
      highlightColor: light ? kShimmerHighLightLight : kShimmerHighLightDark,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface,
          borderRadius: BorderRadius.circular(
            kYaruButtonRadius,
          ),
        ),
      ),
    );
  }
}
