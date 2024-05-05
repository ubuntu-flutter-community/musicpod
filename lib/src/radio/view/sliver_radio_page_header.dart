import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../../build_context_x.dart';
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
    final smallWindow = context.m.size.width < kMasterDetailBreakPoint;

    return SliverAppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      expandedHeight: size,
      flexibleSpace: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment:
              smallWindow ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            if (!smallWindow)
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
            if (!smallWindow)
              const SizedBox(
                width: kYaruPagePadding,
              ),
            if (!smallWindow)
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
            if (!smallWindow)
              const SizedBox(
                width: kYaruPagePadding,
              ),
          ],
        ),
      ),
    );
  }
}
