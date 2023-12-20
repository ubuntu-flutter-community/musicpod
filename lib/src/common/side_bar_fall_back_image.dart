import '../../build_context_x.dart';
import '../../common.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

class SideBarFallBackImage extends StatelessWidget {
  const SideBarFallBackImage({
    super.key,
    required this.child,
    this.color,
  });

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? context.t.colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor.scale(lightness: 0.1).withOpacity(0.4),
            baseColor.scale(lightness: 0.6).withOpacity(0.4),
          ],
        ),
      ),
      width: sideBarImageSize,
      height: sideBarImageSize,
      child: child,
    );
  }
}
