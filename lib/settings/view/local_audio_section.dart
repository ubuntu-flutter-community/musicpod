import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dependencies.dart';

import '../../common/logging.dart';
import '../../common/view/common_widgets.dart';
import '../../extensions/build_context_x.dart';
import '../../external_path/service/external_path_service.dart';
import '../../external_path/service/secure_bookmark_service.dart';
import '../../local_audio/manager/local_audio_manager.dart';
import '../data/shared_preferences_keys.dart';
import '../manager/settings_manager.dart';
import '../manager/wipe_manager.dart';
import 'settings_list_tile.dart';
import 'settings_section.dart';

class LocalAudioSection extends ConsumerWidget {
  const LocalAudioSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final directory =
        ref.watch(settingsStringManagerProvider(SPKeys.directory)) ?? '';

    final neverShowFailedImports =
        ref.watch(settingsBoolManagerProvider(SPKeys.neverShowImportFails)) ??
        false;

    final groupAlbumsOnlyByAlbumName =
        ref.watch(
          settingsBoolManagerProvider(SPKeys.groupAlbumsOnlyByAlbumName),
        ) ??
        false;

    return SettingsSection(
      heading: l10n.localAudio,
      children: [
        SettingsListTile(
          position: ListTilePosition.first,
          title: Text(l10n.musicCollectionLocation),
          subtitle: Text(directory),
          trailing: ElevatedButton(
            onPressed: () async {
              final directoryPath = await di<ExternalPathService>()
                  .getPathOfDirectory();
              Logger.i('Selected directory: $directoryPath');
              if (directoryPath != null) {
                await di<SecureBookmarkService>().saveBookmarkFor(
                  spKey: SPKeys.directoryBookmark,
                  path: directoryPath,
                );
                await ref.read(wipeManagerProvider.notifier).wipe({
                  WipeType.localAudio,
                });
                unawaited(
                  ref
                      .read(localAudioManagerProvider.notifier)
                      .initAudios(forceInit: true, directory: directoryPath),
                );
              }
            },
            child: Text(
              l10n.select,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        SettingsListTile(
          position: ListTilePosition.middle,
          title: Text(
            l10n.dontShowAgain +
                ': ' +
                '"${l10n.failedToImport.replaceAll(':', '')}"',
          ),
          trailing: CommonSwitch(
            value: neverShowFailedImports,
            onChanged: (v) => ref
                .read(
                  settingsBoolManagerProvider(
                    SPKeys.neverShowImportFails,
                  ).notifier,
                )
                .set(v),
          ),
        ),
        SettingsListTile(
          position: ListTilePosition.last,
          title: Text(l10n.groupAlbumsOnlyByAlbumName),
          subtitle: Text(l10n.groupAlbumsOnlyByAlbumNameDescription),
          trailing: CommonSwitch(
            value: groupAlbumsOnlyByAlbumName,
            onChanged: (v) => ref
                .read(
                  settingsBoolManagerProvider(
                    SPKeys.groupAlbumsOnlyByAlbumName,
                  ).notifier,
                )
                .set(v),
          ),
        ),
      ],
    );
  }
}
