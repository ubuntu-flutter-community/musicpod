import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/common_widgets.dart';
import '../../extensions/build_context_x.dart';
import '../../lyrics/lyrics_service.dart';
import '../settings_manager.dart';

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

    return YaruSection(
      headline: Text(l10n.lyrics),
      child: Column(
        children: [
          YaruTile(
            title: Text(l10n.tryToFetchLyricsOnlineTitle),
            subtitle: Text(l10n.tryToFetchLyricsOnlineDescription),
            trailing: CommonSwitch(
              value: tryToFetchLyricsOnline,
              onChanged: di<SettingsManager>().setTryToFetchLyricsOnline,
            ),
          ),
          if (tryToFetchLyricsOnline)
            YaruTile(
              title: Text(l10n.onlineLyricsSourceTitle),
              subtitle: Text(l10n.onlineLyricsSourceDescription),
              trailing: YaruPopupMenuButton<OnlineLyricsSource>(
                child: Text(onlineLyricsSource?.localize(l10n) ?? ''),
                initialValue: onlineLyricsSource,
                onSelected: di<SettingsManager>().setOnlineLyricsSource,
                itemBuilder: (context) =>
                    OnlineLyricsSource.values.map((source) {
                      return PopupMenuItem<OnlineLyricsSource>(
                        value: source,
                        child: Text(source.localize(l10n)),
                      );
                    }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
