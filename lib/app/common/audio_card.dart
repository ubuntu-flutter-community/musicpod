import 'package:flutter/material.dart';
import 'package:music/app/common/constants.dart';
import 'package:music/app/common/safe_network_image.dart';
import 'package:music/data/audio.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AudioCard extends StatefulWidget {
  const AudioCard({super.key, required this.audio, this.onTap, this.onPlay});
  final Audio audio;
  final void Function()? onTap;
  final void Function()? onPlay;

  @override
  State<AudioCard> createState() => _AudioCardState();
}

class _AudioCardState extends State<AudioCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var light = theme.brightness == Brightness.light;

    final fallBackLoadingIcon = Shimmer.fromColors(
      baseColor: light ? kShimmerBaseLight : kShimmerBaseDark,
      highlightColor: light ? kShimmerHighLightLight : kShimmerHighLightDark,
      child: Container(
        color: light ? kShimmerBaseLight : kShimmerBaseDark,
        height: 250,
        width: 250,
      ),
    );

    return YaruBanner(
      padding: EdgeInsets.zero,
      onTap: widget.onTap,
      onHover: (value) => setState(() {
        _hovered = value;
      }),
      child: Stack(
        children: [
          ClipRRect(
            clipBehavior: Clip.hardEdge,
            borderRadius: BorderRadius.circular(10),
            child: SafeNetworkImage(
              // TODO add memory image option
              fallBackIcon: fallBackLoadingIcon,
              url: widget.audio.imageUrl,
              fit: BoxFit.contain,
            ),
          ),
          if (_hovered)
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
    );
  }
}
