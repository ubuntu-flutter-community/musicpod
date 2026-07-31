import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/common_widgets.dart';
import '../../extensions/build_context_x.dart';
import '../../lyrics/data/online_lyrics_source.dart';
import '../manager/settings_manager.dart';
import 'settings_list_tile.dart';
import 'settings_section.dart';

class LyricsSection extends StatelessWidget with WatchItMixin {
  const LyricsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final tryToFetchLyricsOnline = watchPropertyValue(
      (SettingsManager m) => m.tryToFetchLyricsOnline,
    );

    final onlineLyricsSource = watchPropertyValue(
      (SettingsManager m) => m.onlineLyricsSource,
    );

    return SettingsSection(
      heading: l10n.lyrics,
      children: [
        SettingsListTile(
          position: tryToFetchLyricsOnline
              ? ListTilePosition.first
              : ListTilePosition.single,
          title: Text(l10n.tryToFetchLyricsOnlineTitle),
          subtitle: Text(l10n.tryToFetchLyricsOnlineDescription),
          trailing: CommonSwitch(
            value: tryToFetchLyricsOnline,
            onChanged: di<SettingsManager>().setTryToFetchLyricsOnline,
          ),
        ),
        if (tryToFetchLyricsOnline)
          SettingsListTile(
            position: ListTilePosition.last,
            title: Text(l10n.onlineLyricsSourceTitle),
            subtitle: Text(l10n.onlineLyricsSourceDescription),
            trailing: YaruPopupMenuButton<OnlineLyricsSource>(
              child: Text(onlineLyricsSource.localize(l10n)),
              initialValue: onlineLyricsSource,
              onSelected: di<SettingsManager>().setOnlineLyricsSource,
              itemBuilder: (context) => OnlineLyricsSource.values.map((source) {
                return PopupMenuItem<OnlineLyricsSource>(
                  value: source,
                  child: Text(source.localize(l10n)),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
