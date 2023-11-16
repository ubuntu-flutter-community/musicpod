import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../constants.dart';
import '../../l10n.dart';
import '../../local_audio.dart';
import '../../settings.dart';
import '../../utils.dart';
import '../common/icons.dart';
import '../common/spaced_divider.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.onDirectorySelected,
    required this.createLocalAudioCache,
  });

  final Future<void> Function(String? directoryPath) onDirectorySelected;
  final Future<void> Function() createLocalAudioCache;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PopupMenuButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          Iconz().menu,
        ),
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem(
              enabled: false,
              child: Column(
                children: [
                  const SizedBox(
                    height: kYaruPagePadding,
                  ),
                  ElevatedButton(
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
                  TextButton.icon(
                    onPressed: () {
                      createLocalAudioCache();
                      writeSetting(kCacheSuggestionDisposed, 'false');
                    },
                    icon: Icon(Iconz().refresh),
                    label: Text(context.l10n.recreateLocalAudioCache),
                  ),
                  const AboutTile(),
                ],
              ),
            ),
          ];
        },
      ),
    );
  }
}
