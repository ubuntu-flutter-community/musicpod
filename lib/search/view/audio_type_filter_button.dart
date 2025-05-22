import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio_type.dart';
import '../../common/view/modals.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../settings/settings_model.dart';
import '../search_model.dart';

class AudioTypeFilterButton extends StatelessWidget {
  const AudioTypeFilterButton({super.key, required OverlayMode mode})
    : _mode = mode;

  final OverlayMode _mode;

  @override
  Widget build(BuildContext context) => switch (_mode) {
    OverlayMode.bottomSheet => const AudioTypeFilterBottomSheetButton(),
    OverlayMode.popup => const AudioTypeFilterSwitcher(),
  };
}

class AudioTypeFilterSwitcher extends StatelessWidget with WatchItMixin {
  const AudioTypeFilterSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;
    final searchModel = di<SearchModel>();
    final audioType = watchPropertyValue((SearchModel m) => m.audioType);
    final useYaruTheme = watchPropertyValue(
      (SettingsModel m) => m.useYaruTheme,
    );
    final searchBarBorderRadius = getSearchBarBorderRadius(useYaruTheme);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: AudioType.values.mapIndexed((i, e) {
        final selected = audioType == e;
        return IconButton(
          style: IconButton.styleFrom(
            backgroundColor: audioFilterBackgroundColor(
              theme: theme,
              selected: selected,
              useYaruTheme: useYaruTheme,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: i == AudioType.values.length - 1
                    ? Radius.circular(searchBarBorderRadius)
                    : Radius.zero,
                bottomRight: i == AudioType.values.length - 1
                    ? Radius.circular(searchBarBorderRadius)
                    : Radius.zero,
              ),
            ),
          ),
          isSelected: selected,
          tooltip: e.localize(l10n),
          padding: EdgeInsets.zero,
          onPressed: () => searchModel
            ..setAudioType(e)
            ..search(clear: true),
          icon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kSmallestSpace),
            child: Icon(
              e.iconData,
              size: 20,
              color: audioFilterForegroundColor(
                theme: theme,
                selected: selected,
                useYaruTheme: useYaruTheme,
              ),
              semanticLabel: e.localize(l10n),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class AudioTypeFilterBottomSheetButton extends StatelessWidget
    with WatchItMixin {
  const AudioTypeFilterBottomSheetButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final searchModel = di<SearchModel>();
    final audioType = watchPropertyValue((SearchModel m) => m.audioType);

    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: () => showModalBottomSheet(
        context: context,
        builder: (context) => BottomSheet(
          onClosing: () {},
          builder: (context) => ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(10),
            children: AudioType.values
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Icon(e.iconData),
                      onTap: () async {
                        Navigator.of(context).pop();
                        searchModel
                          ..setAudioType(e)
                          ..search(clear: true);
                      },
                      title: Text(
                        '${l10n.search}: ${e.localize(context.l10n)}',
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
      icon: Icon(audioType.iconData),
    );
  }
}
