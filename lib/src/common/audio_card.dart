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
            padding: EdgeInsets.zero,
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
    this.elevation = 1,
    this.surfaceTintColor,
    required this.child,
    this.padding = const EdgeInsets.all(kYaruPagePadding),
    this.onHover,
    this.selected,
    this.mouseCursor,
  });

  final Widget child;

  final VoidCallback? onTap;

  final ValueChanged<bool>? onHover;

  final Color? color;

  final double elevation;

  final Color? surfaceTintColor;

  final EdgeInsetsGeometry padding;

  final bool? selected;

  final MouseCursor? mouseCursor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final borderRadius = BorderRadius.circular(kYaruBannerRadius);

    return Material(
      color: selected == true
          ? theme.primaryColor.withOpacity(0.8)
          : Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        onHover: onHover,
        borderRadius: borderRadius,
        hoverColor: theme.colorScheme.onSurface.withOpacity(0.1),
        mouseCursor: mouseCursor,
        child: Card(
          color: color ?? theme.cardColor,
          shadowColor: Colors.black.withOpacity(0.5),
          surfaceTintColor: null,
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: dark
                ? BorderSide.none
                : const BorderSide(
                    color: Color.fromARGB(255, 226, 226, 226),
                    width: 0,
                  ),
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
