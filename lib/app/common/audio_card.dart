import 'package:flutter/material.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AudioCard extends StatefulWidget {
  const AudioCard({
    super.key,
    this.image,
    this.onTap,
    this.onPlay,
    this.bottom,
  });
  final Widget? image;
  final void Function()? onTap;
  final void Function()? onPlay;
  final Widget? bottom;

  @override
  State<AudioCard> createState() => _AudioCardState();
}

class _AudioCardState extends State<AudioCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;

    return YaruBanner(
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
                  highlightColor:
                      light ? kShimmerHighLightLight : kShimmerHighLightDark,
                  child: Container(
                    color: light ? kShimmerBaseLight : kShimmerBaseDark,
                  ),
                ),
            if (widget.bottom != null) widget.bottom!,
            if (_hovered && widget.onPlay != null)
              Positioned(
                bottom: 15,
                right: 15,
                child: CircleAvatar(
                  backgroundColor: theme.primaryColor,
                  child: IconButton(
                    onPressed: widget.onPlay,
                    icon: Icon(
                      YaruIcons.media_play,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
