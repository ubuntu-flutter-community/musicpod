import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/app_config.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../player/manager/mpv_metadata_manager.dart';
import '../manager/settings_manager.dart';
import 'settings_section.dart';

class ResourceSection extends StatelessWidget with WatchItMixin {
  const ResourceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SettingsSection(
      heading: l10n.resourceSectionTitle,
      children: [
        Padding(
          padding: const EdgeInsets.all(kMediumSpace),
          child: Column(
            children: [
              ListTile(
                title: Text(l10n.useMoreAnimationsTitle),
                subtitle: Text(l10n.useMoreAnimationsDescription),
                trailing: CommonSwitch(
                  onChanged: di<SettingsManager>().setUseMoreAnimations,
                  value: watchPropertyValue(
                    (SettingsManager m) => m.useMoreAnimations,
                  ),
                ),
              ),
              ListTile(
                title: Text(l10n.enableDataSafeModeSettingTitle),
                subtitle: Text(l10n.enableDataSafeModeSettingDescription),
                trailing: CommonSwitch(
                  onChanged: (value) =>
                      di<MpvMetadataManager>().dataSafeMode.value = value,
                  value: watchValue((MpvMetadataManager m) => m.dataSafeMode),
                ),
              ),
              ListTile(
                title: Text(l10n.saveWindowSizeTitle),
                subtitle: Text(l10n.saveWindowSizeDescription),
                trailing: CommonSwitch(
                  onChanged: AppConfig.windowManagerImplemented
                      ? di<SettingsManager>().setSaveWindowSize
                      : null,
                  value: watchPropertyValue(
                    (SettingsManager m) => m.saveWindowSize,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
