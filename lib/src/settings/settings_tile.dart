import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

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

    final content = Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          const SizedBox(
            height: kYaruPagePadding,
          ),
          ImportantButton(
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
          const SpacedDivider(
            top: 0,
            bottom: 0,
          ),
          const ShopRecommendations(),
          const SizedBox(
            height: kYaruPagePadding,
          ),
          const SpacedDivider(
            bottom: 10,
            top: 0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
        ],
      ),
    );

    return Center(
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          Iconz().menu,
        ),
        onPressed: () =>
            showStyledPopover(context: context, content: content, height: 430),
      ),
    );
  }
}
