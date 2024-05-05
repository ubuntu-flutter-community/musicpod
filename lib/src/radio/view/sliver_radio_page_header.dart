import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../../common.dart';
import '../../../constants.dart';
import '../../../data.dart';
import '../../l10n/l10n.dart';
import 'radio_fall_back_icon.dart';
import 'radio_page_tag_bar.dart';

class SliverRadioPageHeader extends StatelessWidget {
  const SliverRadioPageHeader({
    super.key,
    required this.station,
  });

  final Audio station;

  @override
  Widget build(BuildContext context) {
    const size = kMaxAudioPageHeaderHeight;

    return SliverAppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      expandedHeight: size,
      flexibleSpace: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            SizedBox(
              width: size,
              height: size,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SafeNetworkImage(
                  fallBackIcon: RadioFallBackIcon(
                    iconSize: size / 2,
                    station: station,
                  ),
                  url: station.imageUrl,
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
            const SizedBox(
              width: kYaruPagePadding,
            ),
            Expanded(
              child: SizedBox(
                height: size,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 2,
                      child: AudioPageHeaderTitle(
                        title: station.title ?? '',
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: AudioPageHeaderSubTitle(
                        onLabelTab: (text) {},
                        label: context.l10n.station,
                        subTitle: station.artist,
                        onSubTitleTab: (text) {},
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: RadioPageTagBar(
                        station: station,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: kYaruPagePadding,
            ),
          ],
        ),
      ),
    );
  }
}
