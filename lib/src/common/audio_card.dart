import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yaru/yaru.dart';

import '../../constants.dart';
import '../../theme.dart';
import 'common_widgets.dart';
import 'icons.dart';

class AudioCard extends StatefulWidget {
  const AudioCard({
    super.key,
    this.image,
    this.onTap,
    this.onPlay,
    this.bottom,
    this.height,
    this.width,
    this.color,
    this.elevation = 1,
  });
  final Widget? image;
  final void Function()? onTap;
  final void Function()? onPlay;
  final Widget? bottom;
  final double? height;
  final double? width;
  final Color? color;
  final double elevation;

  @override
  State<AudioCard> createState() => _AudioCardState();
}

class _AudioCardState extends State<AudioCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;

    return Column(
      children: [
        SizedBox(
          height: widget.height ?? kSmallCardHeight,
          width: widget.width ?? kSmallCardHeight,
          child: Banner(
            elevation: widget.elevation,
            color: widget.color ?? (light ? kCardColorLight : kCardColorDark),
            onTap: widget.onTap,
            onHover: (value) => setState(() {
              _hovered = value;
            }),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  widget.image ??
                      Shimmer.fromColors(
                        baseColor: light ? kCardColorLight : kCardColorDark,
                        highlightColor: light
                            ? kCardColorLight.scale(lightness: -0.03)
                            : kCardColorDark.scale(lightness: 0.01),
                        child: Container(
                          color: light ? kCardColorLight : kCardColorDark,
                        ),
                      ),
                  if (widget.image != null) widget.image!,
                  if (_hovered && widget.onPlay != null)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: CircleAvatar(
                        radius: avatarIconSize,
                        backgroundColor: theme.colorScheme.primary,
                        child: IconButton(
                          onPressed: widget.onPlay,
                          icon: Padding(
                            padding: appleStyled
                                ? const EdgeInsets.only(left: 3)
                                : EdgeInsets.zero,
                            child: Icon(
                              Iconz().playFilled,
                              color: contrastColor(theme.colorScheme.primary),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (widget.bottom != null) widget.bottom!,
      ],
    );
  }
}

class Banner extends StatelessWidget {
  const Banner({
    super.key,
    this.onTap,
    this.color,
    required this.elevation,
    this.surfaceTintColor,
    required this.child,
    this.onHover,
    this.mouseCursor,
  });

  final Widget child;

  final VoidCallback? onTap;

  final ValueChanged<bool>? onHover;

  final Color? color;

  final double elevation;

  final Color? surfaceTintColor;

  final MouseCursor? mouseCursor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;

    return InkWell(
      onTap: onTap,
      onHover: onHover,
      borderRadius: BorderRadius.circular(12),
      hoverColor: theme.colorScheme.onSurface.withOpacity(0.1),
      mouseCursor: mouseCursor,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(11),
          border: elevation == 0
              ? null
              : Border.all(
                  width: light ? 0.8 : 0.5,
                  color: theme.colorScheme.onSurface.withOpacity(0.01),
                ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: child,
      ),
    );
  }
}
