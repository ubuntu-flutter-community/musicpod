import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/common_widgets.dart';
import '../../common/view/ui_constants.dart';
import '../../external_path/external_path_service.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../local_audio/local_audio_manager.dart';
import '../settings_model.dart';

class LocalAudioSection extends StatelessWidget with WatchItMixin {
  const LocalAudioSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final directory = watchPropertyValue(
      (SettingsModel m) => m.directory ?? '',
    );

    final groupAlbumsOnlyByAlbumName = watchPropertyValue(
      (SettingsModel m) => m.groupAlbumsOnlyByAlbumName,
    );
    return YaruSection(
      headline: Text(l10n.localAudio),
      margin: const EdgeInsets.symmetric(horizontal: kLargestSpace),
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
                    extraAudios: di<LibraryModel>().externalPlaylistAudios,
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
                (SettingsModel m) => m.neverShowFailedImports,
              ),
              onChanged: di<SettingsModel>().setNeverShowFailedImports,
            ),
          ),
          YaruTile(
            title: Text(l10n.groupAlbumsOnlyByAlbumName),
            trailing: CommonSwitch(
              value: groupAlbumsOnlyByAlbumName,
              onChanged: di<SettingsModel>().setGroupAlbumsOnlyByAlbumName,
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
