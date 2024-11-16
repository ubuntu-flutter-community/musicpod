import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/common_widgets.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_mode_x.dart';
import '../../l10n/l10n.dart';
import '../settings_model.dart';
import 'theme_tile.dart';

class ThemeSection extends StatelessWidget with WatchItMixin {
  const ThemeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final model = di<SettingsModel>();
    final l10n = context.l10n;
    final themeIndex = watchPropertyValue((SettingsModel m) => m.themeIndex);
    return YaruSection(
      margin: const EdgeInsets.only(
        left: kYaruPagePadding,
        top: kYaruPagePadding,
        right: kYaruPagePadding,
      ),
      headline: Text(l10n.theme),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: kYaruPagePadding),
              child: Wrap(
                spacing: kYaruPagePadding,
                children: [
                  for (var i = 0; i < ThemeMode.values.length; ++i)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        YaruSelectableContainer(
                          padding: const EdgeInsets.all(1),
                          borderRadius: BorderRadius.circular(15),
                          selected: themeIndex == i,
                          onTap: () => model.setThemeIndex(i),
                          selectionColor: context.theme.colorScheme.primary,
                          child: ThemeTile(ThemeMode.values[i]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              Text(ThemeMode.values[i].localize(context.l10n)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          YaruTile(
            title: Text(l10n.useMoreAnimationsTitle),
            subtitle: Text(l10n.useMoreAnimationsDescription),
            trailing: CommonSwitch(
              onChanged: di<SettingsModel>().setUseMoreAnimations,
              value:
                  watchPropertyValue((SettingsModel m) => m.useMoreAnimations),
            ),
          ),
        ],
      ),
    );
  }
}
