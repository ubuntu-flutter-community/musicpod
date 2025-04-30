import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/common_widgets.dart';
import '../../common/view/ui_constants.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import '../settings_model.dart';

class ResourceSection extends StatelessWidget with WatchItMixin {
  const ResourceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return YaruSection(
      margin: const EdgeInsets.only(
        left: kLargestSpace,
        top: kLargestSpace,
        right: kLargestSpace,
      ),
      headline: Text(l10n.resourceSectionTitle),
      child: Column(
        children: [
          YaruTile(
            title: Text(l10n.useMoreAnimationsTitle),
            subtitle: Text(l10n.useMoreAnimationsDescription),
            trailing: CommonSwitch(
              onChanged: di<SettingsModel>().setUseMoreAnimations,
              value:
                  watchPropertyValue((SettingsModel m) => m.useMoreAnimations),
            ),
          ),
          YaruTile(
            title: Text(l10n.enableDataSafeModeSettingTitle),
            subtitle: Text(l10n.enableDataSafeModeSettingDescription),
            trailing: CommonSwitch(
              onChanged: di<PlayerModel>().setDataSafeMode,
              value: watchPropertyValue((PlayerModel m) => m.dataSafeMode),
            ),
          ),
          YaruTile(
            title: Text(l10n.notifyMeAboutDataSafeModeTitle),
            subtitle: Text(l10n.notifyMeAboutDataSafeModeDescription),
            trailing: CommonSwitch(
              onChanged: di<SettingsModel>().setNotifyDataSafeMode,
              value:
                  watchPropertyValue((SettingsModel m) => m.notifyDataSafeMode),
            ),
          ),
        ],
      ),
    );
  }
}
