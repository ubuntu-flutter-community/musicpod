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
    this.background,
  });
  final Widget? image;
  final Widget? background;
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
    final theme = context.theme;
    final light = theme.isLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AudioCard(
          width: widget.width,
          height: widget.height,
          showBorder: widget.showBorder,
          color: widget.color ?? theme.cardColor,
          onTap: widget.onTap,
          onHover: (value) => setState(() {
            _hovered = value;
          }),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                if (widget.background != null) widget.background!,
                if (widget.image == null)
                  Shimmer.fromColors(
                    baseColor: theme.cardColor,
                    highlightColor: light
                        ? theme.cardColor.scale(lightness: -0.01)
                        : theme.cardColor.scale(lightness: 0.01),
                    child: Container(color: theme.cardColor),
                  ),
                if (widget.image != null) widget.image!,
                if (_hovered && widget.onPlay != null)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: FloatingActionButton.small(
                      onPressed: widget.onPlay,
                      elevation: 0.5,
                      backgroundColor: Colors.white,
                      child: Icon(Iconz.playFilled, color: Colors.black),
                    ),
                  ),
              ],
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
    final theme = context.theme;
    final light = theme.isLight;

    return SizedBox(
      height: height ?? audioCardDimension,
      width: width ?? audioCardDimension,
      child: InkWell(
        onTap: onTap,
        onHover: onHover,
        borderRadius: BorderRadius.circular(12),
        hoverColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(11),
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
