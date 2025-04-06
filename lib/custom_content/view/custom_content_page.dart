import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/header_bar.dart';
import '../../common/view/ui_constants.dart';
import '../../l10n/l10n.dart';
import 'custom_playlists_section.dart';
import 'custom_podcast_section.dart';
import 'custom_station_section.dart';

class CustomContentPage extends StatelessWidget {
  const CustomContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: HeaderBar(
        title: Text(l10n.customContentTitle),
        adaptive: true,
        actions: [
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(kLargestSpace),
        child: Center(
          child: SizedBox(
            width: 600,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: kLargestSpace,
                    bottom: kLargestSpace,
                  ),
                  child: Text(
                    l10n.customContentDescription,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                Flexible(
                  child: YaruExpansionPanel(
                    shrinkWrap: true,
                    // margin: const EdgeInsets.all(kLargestSpace),
                    headers: [
                      Text(context.l10n.playlist),
                      Text(context.l10n.station),
                      Text(context.l10n.podcast),
                    ],
                    children: const [
                      CustomPlaylistsSection(),
                      CustomPodcastSection(),
                      CustomStationSection(),
                    ]
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.all(kLargestSpace),
                            child: e,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
