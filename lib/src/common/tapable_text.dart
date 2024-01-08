import 'package:flutter/material.dart';

import '../../build_context_x.dart';

class TapAbleText extends StatelessWidget {
  const TapAbleText({
    super.key,
    this.onTap,
    required this.text,
    this.style,
  });

  final void Function()? onTap;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;

    return Row(
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: InkWell(
            hoverColor: theme.colorScheme.primary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
            onTap: onTap == null ? null : () => onTap!(),
            child: Text(
              text,
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
