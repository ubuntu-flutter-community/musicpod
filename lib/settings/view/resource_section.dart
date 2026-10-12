import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_config.dart';
import '../../common/view/common_widgets.dart';
import '../../extensions/build_context_x.dart';
import '../data/shared_preferences_keys.dart';
import '../manager/settings_manager.dart';
import 'settings_list_tile.dart';
import 'settings_section.dart';

class ResourceSection extends ConsumerWidget {
  const ResourceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    final useMoreAnimations =
        ref.watch(settingsBoolManagerProvider(SPKeys.useMoreAnimations)) ??
        false;

    final dataSafeMode =
        ref.watch(settingsBoolManagerProvider(SPKeys.dataSafeMode)) ?? false;

    final saveWindowSize =
        ref.watch(settingsBoolManagerProvider(SPKeys.saveWindowSize)) ?? false;

    return SettingsSection(
      heading: l10n.resourceSectionTitle,
      children: [
        SettingsListTile(
          position: ListTilePosition.first,
          title: Text(l10n.useMoreAnimationsTitle),
          subtitle: Text(l10n.useMoreAnimationsDescription),
          trailing: CommonSwitch(
            onChanged: (v) => ref
                .read(
                  settingsBoolManagerProvider(
                    SPKeys.useMoreAnimations,
                  ).notifier,
                )
                .set(v),
            value: useMoreAnimations,
          ),
        ),
        SettingsListTile(
          position: ListTilePosition.middle,
          title: Text(l10n.enableDataSafeModeSettingTitle),
          subtitle: Text(l10n.enableDataSafeModeSettingDescription),
          trailing: CommonSwitch(
            onChanged: (value) => ref
                .read(settingsBoolManagerProvider(SPKeys.dataSafeMode).notifier)
                .set(value),
            value: dataSafeMode,
          ),
        ),
        SettingsListTile(
          position: ListTilePosition.last,
          title: Text(l10n.saveWindowSizeTitle),
          subtitle: Text(l10n.saveWindowSizeDescription),
          trailing: CommonSwitch(
            onChanged: AppConfig.windowManagerImplemented
                ? (v) => ref
                      .read(
                        settingsBoolManagerProvider(
                          SPKeys.saveWindowSize,
                        ).notifier,
                      )
                      .set(v)
                : null,
            value: saveWindowSize,
          ),
        ),
      ],
    );
  }
}
