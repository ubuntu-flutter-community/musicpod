import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yaru/yaru.dart';

import '../../build_context_x.dart';
import '../../constants.dart';
import '../../theme.dart';
import '../../theme_data_x.dart';
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
    this.showBorder = true,
  });
  final Widget? image;
  final void Function()? onTap;
  final void Function()? onPlay;
  final Widget? bottom;
  final double? height;
  final double? width;
  final Color? color;
  final bool showBorder;

  @override
  State<AudioCard> createState() => _AudioCardState();
}

class _AudioCardState extends State<AudioCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final light = theme.isLight;

    return Column(
      children: [
        _AudioCard(
          width: widget.width,
          height: widget.height,
          showBorder: widget.showBorder,
          color: widget.color ?? (light ? kCardColorLight : kCardColorDark),
          onTap: widget.onTap,
          onHover: (value) => setState(() {
            _hovered = value;
          }),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                if (widget.image == null)
                  Shimmer.fromColors(
                    baseColor: light ? kCardColorLight : kCardColorDark,
                    highlightColor: light
                        ? kCardColorLight.scale(lightness: -0.01)
                        : kCardColorDark.scale(lightness: 0.01),
                    child: Container(
                      color: light ? kCardColorLight : kCardColorDark,
                    ),
                  )
                else
                  widget.image!,
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
        if (widget.bottom != null) widget.bottom!,
      ],
    );
  }
}

class _AudioCard extends StatelessWidget {
  const _AudioCard({
    this.onTap,
    this.color,
    required this.showBorder,
    required this.child,
    this.onHover,
    this.height,
    this.width,
  });

  final Widget child;

  final VoidCallback? onTap;

  final ValueChanged<bool>? onHover;

  final Color? color;

  final bool showBorder;

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final light = theme.isLight;

    return SizedBox(
      height: height ?? kAudioCardDimension,
      width: width ?? kAudioCardDimension,
      child: InkWell(
        onTap: onTap,
        onHover: onHover,
        borderRadius: BorderRadius.circular(12),
        hoverColor: theme.colorScheme.onSurface.withOpacity(0.1),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(11),
            border: showBorder
                ? Border.all(
                    width: 1,
                    color: light
                        ? theme.colorScheme.onSurface.withOpacity(0.05)
                        : Colors.white.withOpacity(0.005),
                  )
                : null,
          ),
          width: double.infinity,
          height: double.infinity,
          child: child,
        ),
      ),
    );
  }
}
