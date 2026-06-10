import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/common_widgets.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../external_path/external_path_service.dart';

import '../../local_audio/local_audio_manager.dart';
import '../settings_manager.dart';

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
    return YaruSection(
      headline: Text(l10n.localAudio),
      child: Column(
        children: [
          YaruTile(
            title: Text(l10n.musicCollectionLocation),
            subtitle: Text(directory),
            trailing: ElevatedButton(
              onPressed: () async {
                final directoryPath = await di<ExternalPathService>()
                    .getPathOfDirectory();
                if (directoryPath != null) {
                  di<LocalAudioManager>().initAudiosCommand.run((
                    forceInit: true,
                    directory: directoryPath,
                    forceDbOnly: false,
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
          YaruTile(
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
          YaruTile(
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
      ),
    );
  }
}
