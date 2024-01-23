import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../l10n.dart';
import '../../library.dart';
import '../../local_audio.dart';
import '../../settings.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final libraryModel = context.read<LibraryModel>();
    final localAudioModel = context.read<LocalAudioModel>();

    final useLocalAudioCache =
        context.select((LocalAudioModel m) => m.useLocalAudioCache);

    final Future<void> Function() createLocalAudioCache =
        localAudioModel.createLocalAudioCache;
    final Future<void> Function(bool value) setUseLocalAudioCache =
        localAudioModel.setUseLocalAudioCache;

    Future<void> onDirectorySelected(String? directoryPath) async {
      localAudioModel.setDirectory(directoryPath).then(
            (value) async => await localAudioModel.init(
              forceInit: true,
              onFail: (failedImports) {
                if (libraryModel.neverShowFailedImports) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 10),
                    content: FailedImportsContent(
                      failedImports: failedImports,
                      onNeverShowFailedImports:
                          libraryModel.setNeverShowLocalImports,
                    ),
                  ),
                );
              },
            ),
          );
    }

    final content = [
      Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: ImportantButton(
            onPressed: () async {
              final directoryPath = await getDirectoryPath();

              await onDirectorySelected(directoryPath)
                  .then((value) => Navigator.of(context).pop());
            },
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                context.l10n.pickMusicCollection,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
      const Divider(),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(
            width: 5,
          ),
          Text(context.l10n.useALocalAudioCache),
          CommonSwitch(
            value: useLocalAudioCache == true,
            onChanged: (value) {
              setUseLocalAudioCache(value)
                  .then((_) => Navigator.of(context).pop());
            },
          ),
        ],
      ),
      TextButton.icon(
        onPressed: () {
          createLocalAudioCache();
        },
        icon: Icon(Iconz().refresh),
        label: Text(context.l10n.recreateLocalAudioCache),
      ),
      const AboutTile(),
    ];

    return Center(
      child: PopupMenuButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          Iconz().menu,
        ),
        itemBuilder: (context) {
          return content
              .map(
                (e) => PopupMenuItem(
                  labelTextStyle:
                      MaterialStatePropertyAll(context.t.textTheme.bodyMedium),
                  enabled: false,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: e,
                ),
              )
              .toList();
        },
      ),
    );
  }
}
