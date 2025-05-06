import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/view/musicpod.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/icons.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_mode_x.dart';
import '../../l10n/l10n.dart';
import '../settings_model.dart';
import 'theme_tile.dart';

class ThemeSection extends StatelessWidget with WatchItMixin {
  const ThemeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final model = di<SettingsModel>();
    final l10n = context.l10n;
    final themeIndex = watchPropertyValue((SettingsModel m) => m.themeIndex);
    final useYaruTheme =
        watchPropertyValue((SettingsModel m) => m.useYaruTheme);
    final useCustomThemeColor =
        watchPropertyValue((SettingsModel m) => m.useCustomThemeColor);
    final customThemeColor =
        watchPropertyValue((SettingsModel m) => m.customThemeColor);

    final color = customThemeColor == null
        ? kMusicPodDefaultColor
        : Color(customThemeColor);
    final iconSetIndex = watchPropertyValue(
      (SettingsModel m) => m.iconSetIndex,
    );
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
            title: Text(l10n.useYaruThemeTitle),
            subtitle: Text(l10n.useYaruThemeDescription),
            trailing: CommonSwitch(
              onChanged: model.setUseYaruTheme,
              value: useYaruTheme,
            ),
          ),
          YaruTile(
            title: Text(l10n.selectIconThemeTitle),
            subtitle: Text(l10n.selectIconThemeDescription),
            trailing: YaruPopupMenuButton(
              itemBuilder: (p0) => IconSet.values
                  .map(
                    (IconSet iconSet) => PopupMenuItem(
                      value: iconSet.index,
                      child: Text(
                        iconSet.name,
                      ),
                    ),
                  )
                  .toList(),
              initialValue: iconSetIndex,
              onSelected: (int? value) {
                if (value != null) {
                  di<SettingsModel>().setIconSetIndex(value);
                  di<SettingsModel>().scrollIndex = 0;
                  appRestartNotifier.value = UniqueKey();
                }
              },
              icon: Icon(Iconz.dropdown),
              child: Text(IconSet.values[iconSetIndex].name),
            ),
          ),
          YaruTile(
            title: Text(l10n.useCustomThemeColorTitle),
            subtitle: Text(l10n.useCustomThemeColorDescription),
            trailing: CommonSwitch(
              onChanged: model.setUseCustomThemeColor,
              value: useCustomThemeColor,
            ),
          ),
          if (useCustomThemeColor)
            YaruTile(
              title: const Text(''),
              subtitle: const Text(''),
              trailing: ElevatedButton.icon(
                icon: Icon(Iconz.color),
                label: Text(l10n.selectColor),
                onPressed: () => ColorPicker(
                  color: color,
                  onColorChanged: (Color color) =>
                      di<SettingsModel>().setCustomThemeColor(color.toARGB32()),
                  width: 40,
                  height: 40,
                  borderRadius: 4,
                  spacing: 5,
                  runSpacing: 5,
                  wheelDiameter: 155,
                  heading: Text(
                    l10n.selectColor,
                    style: theme.textTheme.titleMedium,
                  ),
                  subheading: Text(
                    l10n.selectColorShade,
                    style: theme.textTheme.titleMedium,
                  ),
                  wheelSubheading: Text(
                    l10n.selectColorAndItsShades,
                    style: theme.textTheme.titleMedium,
                  ),
                  showMaterialName: true,
                  showColorName: true,
                  showColorCode: true,
                  copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                    longPressMenu: true,
                  ),
                  materialNameTextStyle: theme.textTheme.bodySmall,
                  colorNameTextStyle: theme.textTheme.bodySmall,
                  colorCodeTextStyle: theme.textTheme.bodyMedium,
                  colorCodePrefixStyle: theme.textTheme.bodySmall,
                  selectedPickerTypeColor: theme.colorScheme.primary,
                  pickersEnabled: const <ColorPickerType, bool>{
                    ColorPickerType.both: false,
                    ColorPickerType.primary: true,
                    ColorPickerType.accent: true,
                    ColorPickerType.bw: false,
                    ColorPickerType.custom: true,
                    ColorPickerType.wheel: true,
                  },
                ).showPickerDialog(
                  context,
                  actionsPadding: const EdgeInsets.all(16),
                  constraints: const BoxConstraints(
                    minHeight: 480,
                    minWidth: 300,
                    maxWidth: 320,
                  ),
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
}
