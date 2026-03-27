import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/app_config.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/ui_constants.dart';
import '../../l10n/l10n.dart';
import '../../player/mpv_metadata_manager.dart';
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
              value: watchPropertyValue(
                (SettingsModel m) => m.useMoreAnimations,
              ),
            ),
          ),
          YaruTile(
            title: Text(l10n.useBlurredPlayerBackgroundTitle),
            subtitle: Text(l10n.useBlurredPlayerBackgroundDescription),
            trailing: CommonSwitch(
              onChanged: di<SettingsModel>().setBlurredPlayerBackground,
              value: watchPropertyValue(
                (SettingsModel m) => m.blurredPlayerBackground,
              ),
            ),
          ),
          YaruTile(
            title: Text(l10n.enableDataSafeModeSettingTitle),
            subtitle: Text(l10n.enableDataSafeModeSettingDescription),
            trailing: CommonSwitch(
              onChanged: (value) =>
                  di<MpvMetadataManager>().dataSafeMode.value = value,
              value: watchValue((MpvMetadataManager m) => m.dataSafeMode),
            ),
          ),
          YaruTile(
            title: Text(l10n.saveWindowSizeTitle),
            subtitle: Text(l10n.saveWindowSizeDescription),
            trailing: CommonSwitch(
              onChanged: AppConfig.windowManagerImplemented
                  ? di<SettingsModel>().setSaveWindowSize
                  : null,
              value: watchPropertyValue((SettingsModel m) => m.saveWindowSize),
            ),
          ),
        ],
      ),
    );
  }
}
