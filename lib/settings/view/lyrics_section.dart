import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/common_widgets.dart';
import '../../extensions/build_context_x.dart';
import '../../lyrics/data/online_lyrics_source.dart';
import '../data/shared_preferences_keys.dart';
import '../manager/settings_manager.dart';
import 'settings_list_tile.dart';
import 'settings_section.dart';

class LyricsSection extends ConsumerWidget {
  const LyricsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    final tryToFetchLyricsOnline =
        ref.watch(settingsBoolManagerProvider(SPKeys.tryToFetchLyricsOnline)) ??
        true;

    final sourceName = ref.watch(
      settingsStringManagerProvider(SPKeys.onlineLyricsSource),
    );
    final onlineLyricsSource =
        OnlineLyricsSource.values.firstWhereOrNull(
          (e) => e.name == sourceName,
        ) ??
        OnlineLyricsSource.lrcLib;

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
            onChanged: (v) => ref
                .read(
                  settingsBoolManagerProvider(
                    SPKeys.tryToFetchLyricsOnline,
                  ).notifier,
                )
                .set(v),
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
              onSelected: (source) => ref
                  .read(
                    settingsStringManagerProvider(
                      SPKeys.onlineLyricsSource,
                    ).notifier,
                  )
                  .set(source.name),
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
