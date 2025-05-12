import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../l10n/l10n.dart';
import 'theme.dart';

class AudioCardVignette extends StatefulWidget {
  const AudioCardVignette({
    super.key,
    this.onTap,
    required this.iconData,
  });

  final void Function()? onTap;
  final IconData iconData;

  @override
  State<AudioCardVignette> createState() => _AudioCardVignetteState();
}

class _AudioCardVignetteState extends State<AudioCardVignette> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    const borderRadius = BorderRadius.only(
      bottomLeft: Radius.circular(kYaruContainerRadius),
      topRight: Radius.circular(kYaruContainerRadius),
    );
    return Tooltip(
      message: context.l10n.unPinAlbum,
      child: InkWell(
        borderRadius: borderRadius,
        onHover: (v) => setState(() => _focused = v),
        onFocusChange: (v) => setState(() => _focused = v),
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _focused ? colorScheme.primary : colorScheme.inverseSurface,
            borderRadius: borderRadius,
          ),
          width: audioCardDimension / (isMobile ? 3 : 4),
          height: audioCardDimension / (isMobile ? 3 : 4),
          child: Icon(
            widget.iconData,
            color:
                _focused ? colorScheme.onPrimary : colorScheme.onInverseSurface,
            semanticLabel: context.l10n.unPinAlbum,
          ),
        ),
      ),
    );
  }
}
