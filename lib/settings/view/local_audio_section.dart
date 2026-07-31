import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/logging.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../external_path/service/external_path_service.dart';
import '../../local_audio/manager/local_audio_manager.dart';
import '../manager/settings_manager.dart';
import '../manager/wipe_manager.dart';
import 'settings_section.dart';

class LocalAudioSection extends StatelessWidget with WatchItMixin {
  const LocalAudioSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final directory = watchPropertyValue(
      (SettingsManager m) => m.directory ?? '',
    );

    final groupAlbumsOnlyByAlbumName = watchPropertyValue(
      (SettingsManager m) => m.groupAlbumsOnlyByAlbumName,
    );
    return SettingsSection(
      heading: l10n.localAudio,
      children: [
        ListTile(
          title: Text(l10n.musicCollectionLocation),
          subtitle: Text(directory),
          trailing: ElevatedButton(
            onPressed: () async {
              final directoryPath = await di<ExternalPathService>()
                  .getPathOfDirectory();
              Logger.i('Selected directory: $directoryPath');
              if (directoryPath != null) {
                await di<WipeManager>().command.runAsync({WipeType.localAudio});
                di<LocalAudioManager>().initAudiosCommand.run((
                  forceInit: true,
                  directory: directoryPath,
                ));
              }
            },
            child: Text(
              l10n.select,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        ListTile(
          title: Text(
            l10n.dontShowAgain +
                ': ' +
                '"${l10n.failedToImport.replaceAll(':', '')}"',
          ),
          trailing: CommonSwitch(
            value: watchPropertyValue(
              (SettingsManager m) => m.neverShowFailedImports,
            ),
            onChanged: di<SettingsManager>().setNeverShowFailedImports,
          ),
        ),
        ListTile(
          title: Text(l10n.groupAlbumsOnlyByAlbumName),
          trailing: CommonSwitch(
            value: groupAlbumsOnlyByAlbumName,
            onChanged: di<SettingsManager>().setGroupAlbumsOnlyByAlbumName,
          ),
        ),
        if (groupAlbumsOnlyByAlbumName)
          Padding(
            padding: const EdgeInsets.only(
              top: kSmallestSpace,
              right: kSmallestSpace,
            ),
            child: YaruInfoBox(
              yaruInfoType: YaruInfoType.warning,
              subtitle: Text(l10n.groupAlbumsOnlyByAlbumNameDescription),
            ),
          ),
      ],
    );
  }
}
