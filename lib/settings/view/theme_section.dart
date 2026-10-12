import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

import '../../app/view/musicpod.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/icons.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/platform_x.dart';
import '../../extensions/theme_mode_x.dart';
import '../data/shared_preferences_keys.dart';
import '../manager/settings_manager.dart';
import 'settings_list_tile.dart';
import 'settings_section.dart';
import 'theme_tile.dart';

class ThemeSection extends ConsumerWidget {
  const ThemeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final l10n = context.l10n;
    final themeIndex =
        ref.watch(settingsIntManagerProvider(SPKeys.themeIndex)) ?? 0;
    final useYaruTheme =
        ref.watch(settingsBoolManagerProvider(SPKeys.useYaruTheme)) ?? isLinux;

    final useCustomThemeColor =
        ref.watch(settingsBoolManagerProvider(SPKeys.useCustomThemeColor)) ??
        false;
    final customThemeColor = ref.watch(
      settingsIntManagerProvider(SPKeys.customThemeColor),
    );

    final usePlayerColor =
        ref.watch(settingsBoolManagerProvider(SPKeys.usePlayerColor)) ?? false;

    final color = customThemeColor == null
        ? kMusicPodDefaultColor
        : Color(customThemeColor);
    final iconSetIndex =
        ref.watch(settingsIntManagerProvider(SPKeys.iconSetIndex)) ?? 0;
    final showPositionDuration =
        ref.watch(settingsBoolManagerProvider(SPKeys.showPositionDuration)) ??
        false;
    return SettingsSection(
      heading: l10n.theme,
      children: [
        SettingsListTile(
          position: ListTilePosition.first,
          includeChevron: false,
          title: Wrap(
            alignment: WrapAlignment.start,
            spacing: kLargestSpace,
            children: [
              for (var i = 0; i < ThemeMode.values.length; ++i)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    YaruSelectableContainer(
                      padding: const EdgeInsets.all(1),
                      borderRadius: BorderRadius.circular(15),
                      selected: themeIndex == i,
                      onTap: () => ref
                          .read(
                            settingsIntManagerProvider(
                              SPKeys.themeIndex,
                            ).notifier,
                          )
                          .set(i),
                      selectionColor: context.theme.colorScheme.primary,
                      child: ThemeTile(ThemeMode.values[i]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(ThemeMode.values[i].localize(context.l10n)),
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (!isMobile) ...[
          SettingsListTile(
            position: ListTilePosition.middle,
            title: Text(l10n.useYaruThemeTitle),
            subtitle: Text(l10n.useYaruThemeDescription),
            trailing: CommonSwitch(
              onChanged: (v) => ref
                  .read(
                    settingsBoolManagerProvider(SPKeys.useYaruTheme).notifier,
                  )
                  .set(v),
              value: useYaruTheme,
            ),
          ),
          SettingsListTile(
            position: ListTilePosition.middle,
            title: Text(l10n.selectIconThemeTitle),
            subtitle: Text(l10n.selectIconThemeDescription),
            trailing: YaruPopupMenuButton(
              itemBuilder: (p0) => IconSet.values
                  .map(
                    (IconSet iconSet) => PopupMenuItem(
                      value: iconSet.index,
                      child: Text(iconSet.name),
                    ),
                  )
                  .toList(),
              initialValue: iconSetIndex,
              onSelected: (int? value) {
                if (value != null) {
                  ref
                      .read(
                        settingsIntManagerProvider(
                          SPKeys.iconSetIndex,
                        ).notifier,
                      )
                      .set(value);
                  ref.read(settingsScrollIndexProvider.notifier).set(0);
                  appRestartNotifier.value = UniqueKey();
                }
              },
              icon: Icon(Iconz.dropdown),
              child: Text(IconSet.values[iconSetIndex].name),
            ),
          ),
        ],
        SettingsListTile(
          position: ListTilePosition.middle,
          title: Text(l10n.usePlayerColorTitle),
          subtitle: Text(l10n.usePlayerColorDescription),
          trailing: CommonSwitch(
            onChanged: (v) => ref
                .read(
                  settingsBoolManagerProvider(SPKeys.usePlayerColor).notifier,
                )
                .set(v),
            value: usePlayerColor,
          ),
        ),
        SettingsListTile(
          position: ListTilePosition.middle,
          title: Text(l10n.useCustomThemeColorTitle),
          subtitle: Text(l10n.useCustomThemeColorDescription),
          trailing: CommonSwitch(
            onChanged: usePlayerColor
                ? null
                : (v) => ref
                      .read(
                        settingsBoolManagerProvider(
                          SPKeys.useCustomThemeColor,
                        ).notifier,
                      )
                      .set(v),
            value: useCustomThemeColor,
          ),
        ),
        if (useCustomThemeColor)
          SettingsListTile(
            position: ListTilePosition.middle,
            title: const Text(''),
            subtitle: const Text(''),
            trailing: ElevatedButton.icon(
              icon: Icon(Iconz.color),
              label: Text(l10n.selectColor),
              onPressed: () =>
                  ColorPicker(
                    color: color,
                    onColorChanged: (Color color) => ref
                        .read(
                          settingsIntManagerProvider(
                            SPKeys.customThemeColor,
                          ).notifier,
                        )
                        .set(color.toARGB32()),
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
        SettingsListTile(
          position: ListTilePosition.last,
          title: Text(l10n.showPositionDurationTitle),
          subtitle: Text(l10n.showPositionDurationDescription),
          trailing: CommonSwitch(
            onChanged: (v) => ref
                .read(
                  settingsBoolManagerProvider(
                    SPKeys.showPositionDuration,
                  ).notifier,
                )
                .set(v),
            value: showPositionDuration,
          ),
        ),
      ],
    );
  }
}
