import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yaru/yaru.dart';

import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import 'icons.dart';
import 'theme.dart';

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
    this.playIcon,
    this.seleted = false,
    this.overlay,
  });
  final Widget? image;
  final void Function()? onTap;
  final void Function()? onPlay;
  final Widget? bottom;
  final double? height;
  final double? width;
  final Color? color;
  final bool showBorder;
  final IconData? playIcon;
  final bool seleted;
  final Widget? overlay;

  @override
  State<AudioCard> createState() => _AudioCardState();
}

class _AudioCardState extends State<AudioCard> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final light = theme.isLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            (theme.isLight ? Colors.black : Colors.white).withValues(
              alpha: (_focused || _hovered) ? 0.2 : 0,
            ),
            BlendMode.srcATop,
          ),
          child: _AudioCard(
            width: widget.width,
            height: widget.height,
            showBorder: widget.showBorder,
            color: widget.color ?? theme.cardColor,
            onTap: widget.onTap,
            onHover: (value) => setState(() {
              _hovered = value;
            }),
            onFocusChange: (value) => setState(() {
              _focused = value;
            }),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  if (widget.image == null)
                    Shimmer.fromColors(
                      baseColor: theme.cardColor,
                      highlightColor: light
                          ? theme.cardColor.scale(lightness: -0.01)
                          : theme.cardColor.scale(lightness: 0.01),
                      child: Container(color: theme.cardColor),
                    ),
                  if (widget.image != null) widget.image!,
                  if ((_hovered || widget.seleted) && widget.onPlay != null)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: FloatingActionButton.small(
                        onPressed: widget.onPlay,
                        elevation: 0.5,
                        backgroundColor: Colors.white,
                        hoverColor: theme.colorScheme.primary,
                        child: Icon(
                          widget.playIcon ?? Iconz.playFilled,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  if (widget.overlay != null) widget.overlay!,
                ],
              ),
            ),
          ),
        ),
        if (widget.bottom != null)
          Align(alignment: Alignment.centerLeft, child: widget.bottom!),
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
    this.onFocusChange,
  });

  final Widget child;

  final VoidCallback? onTap;

  final ValueChanged<bool>? onHover;

  final Color? color;

  final bool showBorder;

  final double? height;
  final double? width;
  final void Function(bool)? onFocusChange;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final light = theme.isLight;

    return SizedBox(
      height: height ?? audioCardDimension,
      width: width ?? audioCardDimension,
      child: InkWell(
        onTap: onTap,
        onHover: onHover,
        onFocusChange: onFocusChange,
        borderRadius: BorderRadius.circular(12),
        hoverColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: showBorder
                ? Border.all(
                    width: 1,
                    color: light
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.05)
                        : Colors.white.withValues(alpha: 0.005),
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
