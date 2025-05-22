import 'package:flutter/material.dart';

import '../../extensions/build_context_x.dart';

class TapAbleText extends StatelessWidget {
  const TapAbleText({
    super.key,
    this.onTap,
    required this.text,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.wrapInFlexible = true,
  });

  final void Function()? onTap;
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;
  final bool wrapInFlexible;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final inkWell = InkWell(
      hoverColor: (style?.color ?? theme.colorScheme.primary).withValues(
        alpha: 0.3,
      ),
      borderRadius: BorderRadius.circular(4),
      onTap: onTap == null ? null : () => onTap!(),
      child: Text(
        text,
        style: style,
        maxLines: maxLines ?? 1,
        overflow: overflow,
      ),
    );

    return wrapInFlexible
        ? Row(
            children: [Flexible(fit: FlexFit.loose, child: inkWell)],
          )
        : inkWell;
  }
}
