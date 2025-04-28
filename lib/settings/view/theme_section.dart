import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/common_widgets.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_mode_x.dart';
import '../../l10n/l10n.dart';
import '../settings_model.dart';
import 'theme_tile.dart';
import 'custom_theme_dialog.dart';

class ThemeSection extends StatelessWidget with WatchItMixin {
  const ThemeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final model = di<SettingsModel>();
    final l10n = context.l10n;
    final themeIndex = watchPropertyValue((SettingsModel m) => m.themeIndex);
    final customModes = [
      ThemeMode.system,
      ThemeMode.dark,
      ThemeMode.light,
      ThemeMode.light
    ]; // 第四个作为自定义主题

    return YaruSection(
      margin: const EdgeInsets.only(
        left: kLargestSpace,
        top: kLargestSpace,
        right: kLargestSpace,
      ),
      headline: Text(l10n.theme),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: kLargestSpace),
              child: Wrap(
                spacing: kLargestSpace,
                children: [
                  for (var i = 0; i < customModes.length; ++i)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        YaruSelectableContainer(
                          padding: const EdgeInsets.all(1),
                          borderRadius: BorderRadius.circular(15),
                          selected: themeIndex == i,
                          onTap: () => i == 3
                              ? _showCustomThemeDialog(context, model)
                              : model.setThemeIndex(i),
                          selectionColor: context.theme.colorScheme.primary,
                          child: i == 3
                              ? const CustomThemeTile() // 自定义主题预览
                              : ThemeTile(customModes[i]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: i == 3
                              ? const Text('自定义') // 可以根据需要替换为本地化字符串
                              : Text(customModes[i].localize(context.l10n)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          YaruTile(
            title: Text(l10n.showPositionDurationTitle),
            subtitle: Text(l10n.showPositionDurationDescription),
            trailing: CommonSwitch(
              onChanged: di<SettingsModel>().setShowPositionDuration,
              value: watchPropertyValue(
                (SettingsModel m) => m.showPositionDuration,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomThemeDialog(BuildContext context, SettingsModel model) {
    model.setThemeIndex(3); // 设置为自定义主题索引
    showDialog(
      context: context,
      builder: (context) => const CustomThemeDialog(),
    );
  }
}
