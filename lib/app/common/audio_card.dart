import 'package:flutter/material.dart';
import 'package:music/app/common/constants.dart';
import 'package:music/app/common/safe_network_image.dart';
import 'package:music/data/audio.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AudioCard extends StatelessWidget {
  const AudioCard({super.key, required this.audio, this.onTap});
  final Audio audio;
  final void Function()? onTap;

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
      onTap: onTap,
      onHover: (value) {},
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: SizedBox(
                width: 250,
                child: SafeNetworkImage(
                  // TODO add memory image option
                  fallBackIcon: fallBackLoadingIcon,
                  url: audio.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          YaruTile(
            style: YaruTileStyle.banner,
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
              top: 6,
              bottom: 5,
            ),
            title: Text(
              audio.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }
}
