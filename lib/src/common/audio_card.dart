import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

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
            color:
                widget.color ?? (light ? theme.dividerColor : kShimmerBaseDark),
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
                        baseColor: light ? kShimmerBaseLight : kShimmerBaseDark,
                        highlightColor: light
                            ? kShimmerHighLightLight
                            : kShimmerHighLightDark,
                        child: Container(
                          color: light ? kShimmerBaseLight : kShimmerBaseDark,
                        ),
                      ),
                  if (widget.image != null) widget.image!,
                  if (_hovered && widget.onPlay != null)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: _PlayButton(onPlay: widget.onPlay),
                    ),
                ],
              ),
            ),
          ).translateOnHover,
        ),
        if (widget.bottom != null) widget.bottom!,
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    this.onPlay,
  });

  final void Function()? onPlay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CircleAvatar(
      radius: avatarIconSize,
      backgroundColor: theme.colorScheme.primary,
      child: IconButton(
        onPressed: onPlay,
        icon: Padding(
          padding:
              appleStyled ? const EdgeInsets.only(left: 3) : EdgeInsets.zero,
          child: Icon(
            Iconz().playFilled,
            color: contrastColor(theme.colorScheme.primary),
          ),
        ),
      ),
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
    final borderRadius = BorderRadius.circular(kYaruBannerRadius);

    return InkWell(
      onTap: onTap,
      onHover: onHover,
      borderRadius: borderRadius,
      mouseCursor: mouseCursor,
      child: Card(
        margin: EdgeInsets.zero,
        color: color ?? theme.cardColor,
        surfaceTintColor: null,
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
        child: child,
      ),
    );
  }
}

extension HoverExtension on Widget {
  Widget get translateOnHover {
    return TranslateOnHover(child: this);
  }
}

class TranslateOnHover extends StatefulWidget {
  final Widget child;
  const TranslateOnHover({super.key, required this.child});

  @override
  State<TranslateOnHover> createState() => _TranslateOnHoverState();
}

class _TranslateOnHoverState extends State<TranslateOnHover> {
  double scale = 1.0;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) => _mouseEnter(true),
      onExit: (e) => _mouseEnter(false),
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 200),
        tween: Tween<double>(begin: 1.0, end: scale),
        builder: (BuildContext context, double value, _) {
          return Transform.scale(scale: value, child: widget.child);
        },
      ),
    );
  }

  void _mouseEnter(bool hover) {
    setState(() {
      if (hover) {
        scale = 1.03;
      } else {
        scale = 1.0;
      }
    });
  }
}
